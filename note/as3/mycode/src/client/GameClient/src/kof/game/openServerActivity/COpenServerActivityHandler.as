//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/10/19.
 */
package kof.game.openServerActivity {

import QFLib.Foundation.CTime;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.game.openServerActivity.enum.EOpenServerActivityState;
import kof.game.openServerActivity.event.COpenServerActivityEvent;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Carnival.CarnivalActivityOpenResponse;
import kof.message.Carnival.CarnivalCompleteNumRewardObtainRequest;
import kof.message.Carnival.CarnivalCompleteNumRewardObtainResponse;
import kof.message.Carnival.CarnivalDataRequest;
import kof.message.Carnival.CarnivalDataResponse;
import kof.message.Carnival.CarnivalTargetChangeResponse;
import kof.message.Carnival.CarnivalTargetRewardObtainRequest;
import kof.message.Carnival.CarnivalTargetRewardObtainResponse;
import kof.table.GamePrompt;

public class COpenServerActivityHandler extends CNetHandlerImp {
    public function COpenServerActivityHandler() {
        super();
    }
    private var _isRequest : Boolean;//是否已经请求过数据
    override protected function onSetup() : Boolean {
        var ret:Boolean = super.onSetup();
        this.bind(CarnivalDataResponse,_onActivityDataResponse);//IP:10.10.17.107
        this.bind(CarnivalActivityOpenResponse,_onActivityOpenResponse);
        this.bind(CarnivalTargetChangeResponse,_onActivityTargetChangeResponse);
        this.bind(CarnivalTargetRewardObtainResponse,_onActivityGetTargetRewardResponse);
        this.bind(CarnivalCompleteNumRewardObtainResponse,_onActivityGetCompleteRewardResponse);

        _onActivityDataRequest();
        return ret;
    }

    /******************************S2C**************************************/

    /**
     * 活动数据返回
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityDataResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CarnivalDataResponse = message as CarnivalDataResponse;
        var state : int = 1;
        var curTime:Number = CTime.getCurrServerTimestamp();
        if( openServerManager.endTime && openServerManager.endTime <= CTime.getCurrServerTimestamp()
                ||(response.goingActivityIds == null || response.goingActivityIds.length <= 0))
        {
            //活动未开启
            openServerManager.closeOpenActivity();
            state = 2;
        }
        else
        {
            //活动已开启，列表
            openServerManager.openActivity();
            openServerManager.openActivityIds = response.goingActivityIds;
            openServerManager.isGetRewardList = response.obtainedCompleteNumList;
            openServerManager.updateTargetInfoList(response.targetInfos);
            openServerManager.endTime = response.endTick;//活动结束时间
            state = 1;
        }
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = state;
        args.endTime = response.endTick;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
        openServerManager.updateRedPoint();
    }

    /**
     * 活动开启返回
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityOpenResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CarnivalActivityOpenResponse = message as CarnivalActivityOpenResponse;

        openServerManager.openActivity();
        openServerManager.addActivityId(response.activityId);
        openServerManager.addTargetInfoToList(response.targetInfos);

        system.dispatchEvent(new COpenServerActivityEvent(COpenServerActivityEvent.ACTIVITY_START));
    }

    /**
     * 活动目标数据更新返回
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityTargetChangeResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CarnivalTargetChangeResponse = message as CarnivalTargetChangeResponse;
        openServerManager.updateTargetInfo(response.targetInfos);

        openServerManager.updateRedPoint();
        system.dispatchEvent(new COpenServerActivityEvent(COpenServerActivityEvent.ACTIVITY_TARGET_UPDATE));
    }

    /**
     * 领取【活动目标】奖励返回
     */
    private function _onActivityGetTargetRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CarnivalTargetRewardObtainResponse = message as CarnivalTargetRewardObtainResponse;
        openServerManager.updateTargetById(response.targetId);

        openServerManager.updateRedPoint();

        system.dispatchEvent(new COpenServerActivityEvent(COpenServerActivityEvent.ACTIVITY_TARGET_REWARD));

        ((system as COpenServerActivitySystem).getBean( COpenServerActivityViewHandler ) as COpenServerActivityViewHandler).flyTargetItem(response.targetId);
    }

    /**
     * 领取【活动完成数量】奖励返回
     */
    private function _onActivityGetCompleteRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CarnivalCompleteNumRewardObtainResponse = message as CarnivalCompleteNumRewardObtainResponse;
        openServerManager.isGetRewardList.push(response.id);
        system.dispatchEvent(new COpenServerActivityEvent(COpenServerActivityEvent.ACTIVITY_COMPLETE_REWARD,response.id));
    }



    /******************************C2S**************************************/

    public function _onActivityDataRequest():void{
        if(_isRequest) return;
        var request:CarnivalDataRequest = new CarnivalDataRequest();
        request.flag = 1;
        networking.post(request);
        _isRequest = true;
    }

    public function onGetTargetRewardRequest(targetId:int):void{
        var request:CarnivalTargetRewardObtainRequest = new CarnivalTargetRewardObtainRequest();
        request.targetId = targetId;
        networking.post(request);
    }

    public function onGetCompleteRewardRequest(id:int):void{
        var request:CarnivalCompleteNumRewardObtainRequest = new CarnivalCompleteNumRewardObtainRequest();
        request.id = id;
        networking.post(request);
    }


//    private function _onActivityStateRespone(event:CActivityHallEvent):void{
//        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
//        if(!response) return;
//
//        var activityType:int = openServerManager.getActivityType(response.activityID);
//        if(activityType == CActivityHallActivityType.LIMIT)
//        {
//            //1准备中2进行中3已完成4已结束5已关闭/
//            openServerManager.curActivityId = response.activityID;
//            openServerManager.curActivityState = response.state;
//            if(response.params){
//                openServerManager.startTime = response.params.startTick;
//                openServerManager.endTime = response.params.endTick;
//            }
//
//            if(response.state >= EOpenServerActivityState.ACTIVITY_STATE_PREPARE && response.state <= EOpenServerActivityState.ACTIVITY_STATE_END){
//                openServerManager.openLimitActivity();
//            }else if(response.state == EOpenServerActivityState.ACTIVITY_STATE_CLOSE){
//                openServerManager.closeLimitActivity();
//                openServerManager.curActivityId = 0;
//            }
//        }
//    }

    //===============================================

    public function get openServerManager():COpenServerActivityManager
    {
        return system.getBean(COpenServerActivityManager) as COpenServerActivityManager;
    }
    private function get _system() : COpenServerActivitySystem
    {
        return system as COpenServerActivitySystem;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }


    /******************************table**************************************/
    private function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }

}
}
