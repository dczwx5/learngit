//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/10.
 */
package kof.game.recruitRank {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.data.CActivityState;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.recruitRank.view.CRecruitRankView;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.Activity.RecruitRankActivityDataRequest;
import kof.message.Activity.RecruitRankActivityDataResponse;
import kof.message.Activity.RecruitRankActivityRankDataRequest;
import kof.message.Activity.RecruitRankActivityRankDataResponse;
import kof.message.Activity.RecruitRankActivityScoreRewardReceiveRequest;
import kof.message.Activity.RecruitRankActivityScoreRewardReceiveResponse;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CUISystem;

/*系统控制器*/
public class CRecruitRankHandler extends CNetHandlerImp{

    private var _isDispose : Boolean;

    public function CRecruitRankHandler()
    {
        super();

        _isDispose = false;
    }

    override public function dispose() : void
    {
        if( _isDispose ) return;
        super.dispose();
        networking.unbind(RecruitRankActivityDataResponse);
        networking.unbind(RecruitRankActivityRankDataResponse);
        networking.unbind(RecruitRankActivityScoreRewardReceiveResponse);
        _isDispose = true;
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();
        this.bind(RecruitRankActivityDataResponse, _receiveTimesResponse);
        this.bind(RecruitRankActivityRankDataResponse, _inRankListResponse);
        this.bind(RecruitRankActivityScoreRewardReceiveResponse, _receiveRewardResponse);
        _addEventListener();
        return true;
    }
    private function _addEventListener() : void {
        activityHallSystem.addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);

    }
    /******************************C2S**************************************/
    /**
     * 请求活动数据，全服次数
     */
    public function onActivityDataRequest() : void
    {
        var request:RecruitRankActivityDataRequest = new RecruitRankActivityDataRequest();
        request.flag = 1;

        networking.post(request);
    }
    /**
     * Request
     * 请求排行信息
     */
    public function onRankListRequest() : void
    {
        var request:RecruitRankActivityRankDataRequest = new RecruitRankActivityRankDataRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 请求领取奖励
     * @param id 奖励id
     */
    public function onRewardRequest( id : int) : void
    {
        var request:RecruitRankActivityScoreRewardReceiveRequest = new RecruitRankActivityScoreRewardReceiveRequest();
        request.timesId = id;

        networking.post(request);
    }

    /******************************S2C**************************************/

    /**
     * 请求活动状态返回
     */
    //================================================
    private function _onActivityStateRespone(event:CActivityHallEvent):void{
        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
        if(!response) return;

        var activityType:int = recruitManager.getActivityType(response.activityID);
        if(activityType == CActivityHallActivityType.RECRUIT)
        {

            recruitManager.curActivityId = response.activityID;
            recruitManager.curActivityState = response.state;
            if(response.params){
                recruitManager.startTime = response.params.startTick;
                recruitManager.endTime = response.params.endTick;
            }

            //1准备中2进行中3已完成4已结束5已关闭/
            if(response.state >= CActivityState.ACTIVITY_START && response.state <= CActivityState.ACTIVITY_END)
            {
                recruitManager.openActivity();
                if(response.state == CActivityState.ACTIVITY_START)
                {
                    recruitManager.firstOpen = true;
                }
            }
            else if(response.state == CActivityState.ACTIVITY_CLOSE)
            {
                recruitManager.closeActivity();
                recruitManager.curActivityId = 0;
            }
        }
    }
    /**
     * 全服次数返回
     */
    private final function _receiveTimesResponse(net:INetworking,message:CAbstractPackMessage,isError:Boolean):void
    {
        var response:RecruitRankActivityDataResponse = message as RecruitRankActivityDataResponse;
        recruitManager.setTotaltimes(response.totalTimes,response.selfTimes,response.received);
        recruitManager.updateRedPoint();
        recruitRankView.refreshView();
    }
    /**
     * Response
     * 解析排名
     * 活动倒计时
     */
    private final function _inRankListResponse(net:INetworking,message:CAbstractPackMessage,isError:Boolean):void
    {
        var response:RecruitRankActivityRankDataResponse = message as RecruitRankActivityRankDataResponse;
        recruitManager.setRankInfo(response.selfTimes,response.rankInfos);
        recruitRankView.refreshView();
    }

    /**
     * 领奖返回
     */
    private final function _receiveRewardResponse(net:INetworking,message:CAbstractPackMessage,isError:Boolean):void
    {
        var response:RecruitRankActivityScoreRewardReceiveResponse = message as RecruitRankActivityScoreRewardReceiveResponse;
        var proStr:String = getGamePromptStr(response.gamePromptID);
        if( proStr != null){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
        }

        var newRewardId:int;
        for each(var id:int in response.received)
        {
            if(recruitManager.received && recruitManager.received.indexOf(id) == -1)
            {
                newRewardId = id;
                recruitManager.received = response.received;
                recruitManager.updateRedPoint();
                recruitRankView.refreshView();
                break;
            }
        }
        if(newRewardId > 0)
        {
            var rewardId:int = recruitManager.getRewardByID(newRewardId).reward;
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage,rewardId);
            (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
        }
    }
    //===============================================

    public function get recruitManager():CRecruitRankManager
    {
        return system.getBean(CRecruitRankManager) as CRecruitRankManager;
    }
    public function get recruitRankView():CRecruitRankView
    {
        return system.getBean(CRecruitRankView) as CRecruitRankView;
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
