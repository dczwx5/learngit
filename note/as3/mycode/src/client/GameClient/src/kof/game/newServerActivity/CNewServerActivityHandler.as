//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/25.
 */
package kof.game.newServerActivity {

import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.game.newServerActivity.event.CNewServerActivityEvent;
import kof.message.Activity.NewServerRankActivityStateRequest;
import kof.message.Activity.NewServerRankActivityStateResponse;
import kof.message.Activity.ServerActivityPrizeRequest;
import kof.message.Activity.ServerActivityPrizeResponse;
import kof.message.Activity.ServerActivityRankRequest;
import kof.message.Activity.ServerActivityRankResponse;
import kof.message.Activity.ServerActivityRequest;
import kof.message.Activity.ServerActivityResponse;
import kof.message.Activity.ServerActivityTipsRequest;
import kof.message.Activity.ServerActivityTipsResponse;
import kof.message.CAbstractPackMessage;


/**
 * 新服活动请求处理
 * **/
public class CNewServerActivityHandler extends CNetHandlerImp {

    public function CNewServerActivityHandler() {
        super();
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        this.bind( ServerActivityPrizeResponse , _getStageRewardResponse );
        this.bind( ServerActivityResponse , _getActivityDataResponse );
        this.bind( ServerActivityRankResponse , _getActivityRankResponse );
        this.bind( NewServerRankActivityStateResponse , _onNewServerRankActivityStateResponse );
        //this.bind( ServerActivityTipsResponse , _getNewServerActivityTips );

        //主动请求一次tips数据
        //getNewServerActivityTips();
        onNewServerRankActivityStateRequest();
        return ret;
    }

    /**************************S2C****************************/
    private function _getStageRewardResponse( net:INetworking, message:CAbstractPackMessage,isError : Boolean ) : void
    {
        if( isError ) return;
        var response : ServerActivityPrizeResponse = message as ServerActivityPrizeResponse;
        newServerActivityManager.updataStageReward(response);
    }
    private function _getActivityDataResponse( net:INetworking, message:CAbstractPackMessage , isError : Boolean ) : void
    {
        if( isError ) return;
        var response : ServerActivityResponse = message as ServerActivityResponse;
        newServerActivityManager.activityData.updateDataByData(response);
        system.dispatchEvent( new CNewServerActivityEvent(CNewServerActivityEvent.NEW_SERVER_ACTIVITY_UPDATE) );
    }
    private function _getActivityRankResponse( net : INetworking, message : CAbstractPackMessage ,isError : Boolean ) : void
    {
        if( isError ) return;
        var response : ServerActivityRankResponse = message as ServerActivityRankResponse;
        newServerActivityManager.updateActivityRank( response );
        system.dispatchEvent( new CNewServerActivityEvent( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_RANK_UPDATA ) );
    }
    private function _getNewServerActivityTips( net : INetworking, message : CAbstractPackMessage ,isError : Boolean ) : void
    {
        if( isError ) return;
        var response : ServerActivityTipsResponse = message as ServerActivityTipsResponse;
        newServerActivityManager.updateRedPointData( response.activityList );
    }

    private function _onNewServerRankActivityStateResponse( net : INetworking, message : CAbstractPackMessage ,isError : Boolean ) : void
    {
        if( isError ) return;
        var response : NewServerRankActivityStateResponse = message as NewServerRankActivityStateResponse;

//        optional int32 activityId = 1;//活动id
//        optional int32 state = 2;//状态 1进行中 2已结束
//        optional int64 startTick = 3;//开始时间
//        optional int64 endTick = 4;//结束时间
        if( response.activityId == 7 && response.state == 2 ){
            newServerActivityManager.m_allFinishFlg = true;
        }

        system.dispatchEvent( new CNewServerActivityEvent(CNewServerActivityEvent.NEWSERVERRANKACTIVITYSTATERESPONSE) );
        //=============add by Lune 0627======================================
        //用于收集活动开启预览数据
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = response.state;
        args.endTime = response.endTick;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
    }

    /**************************C2S******************************/
    public function getStageRewardRequest( activityID : int, stage : int) : void
    {
        var request : ServerActivityPrizeRequest = new ServerActivityPrizeRequest();
        request.activityId = activityID;
        request.stage = stage;
        networking.post( request );
    }
    public function getActivityDataRequest( activityID : int ) : void
    {
        var request : ServerActivityRequest = new ServerActivityRequest();
        request.activityId = activityID;
        networking.post( request );
    }
    public function getActivityRankRequest( activityID : int ) : void
    {
        var request : ServerActivityRankRequest = new ServerActivityRankRequest();
        request.activityId = activityID;
        networking.post( request );
    }
    public function getNewServerActivityTips() : void
    {
        var request : ServerActivityTipsRequest = new ServerActivityTipsRequest();
        request.id = 1;
        networking.post( request );
    }
    public function onNewServerRankActivityStateRequest() : void
    {
        var request : NewServerRankActivityStateRequest = new NewServerRankActivityStateRequest();
        request.decode( [ 1 ] );
        networking.post( request );
    }

    public function get newServerActivityManager() : CNewServerActivityManager
    {
        return system.getBean( CNewServerActivityManager ) as CNewServerActivityManager;
    }
    private function get _system() : CNewServerActivitySystem
    {
        return system as CNewServerActivitySystem;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
