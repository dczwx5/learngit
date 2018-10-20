//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.game.limitActivity.enum.ELimitActivityState;
import kof.game.limitActivity.event.CLimitActivityEvent;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.Activity.ActivityStateDataRequest;
import kof.message.Activity.LimitTimeConsumeActivityRankDataRequest;
import kof.message.Activity.LimitTimeConsumeActivityRankDataResponse;
import kof.message.Activity.LimitTimeConsumeActivityScoreDataRequest;
import kof.message.Activity.LimitTimeConsumeActivityScoreDataResponse;
import kof.message.Activity.LimitTimeConsumeActivityScoreRewardReceiveRequest;
import kof.message.Activity.LimitTimeConsumeActivityScoreRewardReceiveResponse;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CUISystem;

public class CLimitActivityHandler extends CNetHandlerImp {
    public function CLimitActivityHandler() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret:Boolean = super.onSetup();
        this.bind(LimitTimeConsumeActivityScoreDataResponse,_onActivityScoreDataResponse);//IP:10.10.17.107
        this.bind(LimitTimeConsumeActivityRankDataResponse,_onActivityRankDataResponse);
        this.bind(LimitTimeConsumeActivityScoreRewardReceiveResponse,_onGetScoreRewardResponse);

        activityHallSystem.addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);

        return ret;
    }

    override protected function enterSystem(system:CAppSystem):void {
        super.enterSystem(system);
        onActivityStateReques();
        onActivityScoreDataRequest();
        onActivityRankDataRequest();
    }

    /******************************S2C**************************************/
    private function _onActivityScoreDataResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;
        var response:LimitTimeConsumeActivityScoreDataResponse = message as LimitTimeConsumeActivityScoreDataResponse;
        limitManager.mySroce = response.curScore;
        limitManager.receiverList = response.received;

        limitManager.updateRedPoint();
        system.dispatchEvent(new CLimitActivityEvent(CLimitActivityEvent.ACTIVITY_MYSCORE_UPDATE));
    }

    public function _onActivityRankDataResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;
        var response:LimitTimeConsumeActivityRankDataResponse = message as LimitTimeConsumeActivityRankDataResponse;
        limitManager.myRank = response.curRank;
        limitManager.updateRankInfo(response.rankInfos);

        system.dispatchEvent(new CLimitActivityEvent(CLimitActivityEvent.ACTIVITY_RANK_UPDATE));
    }

    private function _onGetScoreRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;
        var response:LimitTimeConsumeActivityScoreRewardReceiveResponse = message as LimitTimeConsumeActivityScoreRewardReceiveResponse;

        var oldList:Array = limitManager.receiverList;
        var newList:Array = response.received;
        var index:int = 0;
        var addId:int = 0;
        for each(var newRewardId:int in newList){
            index = oldList.indexOf(newRewardId);
            if(index == -1){
                addId = newRewardId;
            }
        }

        limitManager.receiverList = newList;
        var proStr:String = getGamePromptStr(response.gamePromptID);
        if( proStr != null){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
        }

        limitManager.updateRedPoint();

        system.dispatchEvent(new CLimitActivityEvent(CLimitActivityEvent.ACTIVITY_REWARD_UPDATE,addId));
    }

    /******************************C2S**************************************/

    public function onActivityScoreDataRequest():void{
        var request:LimitTimeConsumeActivityScoreDataRequest = new LimitTimeConsumeActivityScoreDataRequest();
        request.flag = 1;
        networking.post(request);
    }

    public function onActivityRankDataRequest():void{
        var request:LimitTimeConsumeActivityRankDataRequest = new LimitTimeConsumeActivityRankDataRequest();
        request.flag = 1;
        networking.post(request);
    }

    public function onGetScoreRewardRequest(rewardId:int):void{
        var request:LimitTimeConsumeActivityScoreRewardReceiveRequest = new LimitTimeConsumeActivityScoreRewardReceiveRequest();
        request.scoreID = rewardId;
        networking.post(request);
    }

    /**
     * 请求活动状态
     */
    public function onActivityStateReques():void{
        var request:ActivityStateDataRequest = new ActivityStateDataRequest();
        request.flag = 1;
        networking.post(request);
    }


    //================================================
    /**
     * 活动状态变更
     * @param event
     */
    private function _onActivityStateRespone(event:CActivityHallEvent):void{
        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
        if(!response) return;

        limitManager.updateActivityState(response);

        var activityType:int = limitManager.getActivityType(response.activityID);
        if(activityType == CActivityHallActivityType.LIMIT)
        {
            //1准备中2进行中3已完成4已结束5已关闭/
            limitManager.curActivityId = response.activityID;
            limitManager.curActivityState = response.state;
            if(response.params){
                limitManager.startTime = response.params.startTick;
                limitManager.endTime = response.params.endTick;
            }

            if(response.state >= ELimitActivityState.ACTIVITY_STATE_PREPARE && response.state <= ELimitActivityState.ACTIVITY_STATE_END){
                limitManager.openLimitActivity();
            }else if(response.state == ELimitActivityState.ACTIVITY_STATE_CLOSE){
                limitManager.closeLimitActivity();
                limitManager.curActivityId = 0;
            }
        }
    }

    //===============================================

    public function get limitManager():CLimitActivityManager
    {
        return system.getBean(CLimitActivityManager) as CLimitActivityManager;
    }

    private function get activityHallSystem() : CActivityHallSystem {
        return system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
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
