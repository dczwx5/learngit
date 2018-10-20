//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/3.
 */
package kof.game.recharge.firstRecharge {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.recharge.event.CFirstRechargeEvent;
import kof.message.Activity.FirstRechargeRewardRequest;
import kof.message.Activity.FirstRechargeRewardResponse;
import kof.message.CAbstractPackMessage;

public class CFirstRechargeNetHandler extends CNetHandlerImp
{
    public function CFirstRechargeNetHandler()
    {
        super ();
    }

    override protected function onSetup():Boolean

    {
        var ret:Boolean = super.onSetup();
        this.bind( FirstRechargeRewardResponse,_onFirstRechargeResponseHandler);
        return ret;
    }

    /**获取首充状态**/
    private function _onFirstRechargeResponseHandler(net:INetworking, message:CAbstractPackMessage, isError : Boolean):void
    {
        if (isError) return;

        var response : FirstRechargeRewardResponse = message as FirstRechargeRewardResponse;
        firstRechargeManager.updateFirstRechargeManager( response );
        //system.dispatchEvent( new CViewEvent( ERechargeType.RechargeImmediately ) );
        system.dispatchEvent(new CFirstRechargeEvent(CFirstRechargeEvent.StateChange, response.firstRechargeState));
    }

    public function get firstRechargeManager() : CFirstRechargeManager
    {
        return system.getBean( CFirstRechargeManager ) as CFirstRechargeManager;
    }

    public function firstRechargeRequest() : void
    {
        var request : FirstRechargeRewardRequest = new FirstRechargeRewardRequest();
        request.id = 1;
        networking.post( request );
    }
}
}
