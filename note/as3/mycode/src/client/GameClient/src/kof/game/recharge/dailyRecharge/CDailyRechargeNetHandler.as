//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/17.
 * Modified by Lune on 2018/09/11
 */
package kof.game.recharge.dailyRecharge {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.recharge.event.CDailyRechargeEvent;
import kof.message.Activity.EverydayRechargeRequest;
import kof.message.Activity.EverydayRechargeResponse;
import kof.message.Activity.EverydayRechargeRewardRequest;
import kof.message.Activity.EverydayRechargeRewardResponse;
import kof.message.CAbstractPackMessage;

public class CDailyRechargeNetHandler extends CNetHandlerImp{
    public function CDailyRechargeNetHandler()
    {
        super ();
    }
    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        this.bind( EverydayRechargeResponse,_onRechargeStateResponseHandler);
        this.bind( EverydayRechargeRewardResponse,_onRechargeRewardResponseHandler);
        initialRechargeRequest();
        return ret;
    }

    private function _onRechargeStateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean):void
    {
        if (isError) return;

        var response : EverydayRechargeResponse = message as EverydayRechargeResponse;
        rechargeManager.updateRechargeStateData( response );
        system.dispatchEvent(new CDailyRechargeEvent(CDailyRechargeEvent.StateChange, response.everydayRecharge));
    }

    private function _onRechargeRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean):void
    {
        if (isError) return;

        var response : EverydayRechargeRewardResponse = message as EverydayRechargeRewardResponse;
        rechargeManager.updateReward( response );
        if ( _mainView.isViewShow )
        {
            _mainView.flyItem();
            _mainView.updateView();
        }
    }

    public function initialRechargeRequest() : void
    {
        var request : EverydayRechargeRequest = new EverydayRechargeRequest();
        request.id = 1;
        networking.post( request );
    }
    public function rewardRequest( rechargeValue : int) : void
    {
        var request : EverydayRechargeRewardRequest = new EverydayRechargeRewardRequest();
        request.rechargeType = rechargeValue;
        networking.post( request );
    }

    private function get _mainView() : CDailyRechargeViewHandler
    {
        return system.getBean( CDailyRechargeViewHandler ) as CDailyRechargeViewHandler;;
    }
    public function get rechargeManager() : CDailyRechargeManager
    {
        return system.getBean( CDailyRechargeManager ) as CDailyRechargeManager;
    }
}
}
