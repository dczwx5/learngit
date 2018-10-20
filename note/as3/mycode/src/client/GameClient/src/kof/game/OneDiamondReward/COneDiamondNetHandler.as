//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/14.
 */
package kof.game.OneDiamondReward {

import flash.events.Event;

import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.message.Activity.ActivityMessageRequest;
import kof.message.Activity.ActivityMessageResponse;
import kof.message.Activity.OneDiamondActivityNoticeResponse;
import kof.message.Activity.OneDiamondActivityRewardRequest;
import kof.message.Activity.OneDiamondActivityRewardResponse;
import kof.message.CAbstractPackMessage;

public class COneDiamondNetHandler extends CNetHandlerImp
{
    public function COneDiamondNetHandler()
    {
        super ();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        this.bind(ActivityMessageResponse, oneDiamondInitialStateResponseHandler);
        oneDiamondInitialStateRequest();
        this.bind( OneDiamondActivityRewardResponse, _onOneDiamondResponseHandler);
        this.bind(OneDiamondActivityNoticeResponse, _onSystemOpenResponseHandler);
        return ret;
    }

    public function get oneDiamondManager() : COneDiamondManager
    {
        return system.getBean( COneDiamondManager ) as COneDiamondManager;
    }

    public function oneDiamondInitialStateRequest() : void
    {
        var request : ActivityMessageRequest = new ActivityMessageRequest();
        request.info = 1;
        networking.post(request);
    }
    public function oneDiamondInitialStateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean) : void
    {
        if (isError) return;

        var response : ActivityMessageResponse = message as ActivityMessageResponse;
        oneDiamondManager.updateInitialState( response );
        //获取活动预览数据
        //==========add by Lune 0702===================================
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = response.OneDiamondActivityState  < 2 ? 1 : 2;//0未完成1已完成2已领取（01开启2关闭）
        args.endTime = response.endTime;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
        //==========add by Lune 0702===================================
    }

    public function oneDiamondRewardRequest() : void
    {
        var request : OneDiamondActivityRewardRequest = new OneDiamondActivityRewardRequest();
        request.info = 1;
        networking.post( request );
    }

    private function _onOneDiamondResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean):void
    {
        if (isError) return;

        var response : OneDiamondActivityRewardResponse = message as OneDiamondActivityRewardResponse;
        oneDiamondManager.updateRewardState( response );
        _system.dispatchEvent(new COneDiamondEvent(COneDiamondEvent.StateChange, response.OneDiamondActivityState));
    }

    private function _onSystemOpenResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean):void
    {
        if (isError) return;

        var response : OneDiamondActivityNoticeResponse = message as OneDiamondActivityNoticeResponse;
        if (response.OneDiamondActivityState == 1)
            oneDiamondManager.openOneDiamondSystem(response.endTime);
        //获取活动预览数据
        //==========add by Lune 0702===================================
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = response.OneDiamondActivityState  < 2 ? 1 : 2;//0未完成1已完成2已领取（01开启2关闭）
        args.endTime = response.endTime;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
        //==========add by Lune 0702===================================
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
    private function get _system() : COneDiamondSystem
    {
        return system as COneDiamondSystem;
    }
}
}
