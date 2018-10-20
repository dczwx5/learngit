//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/1/4.
 */
package kof.game.rechargerebate {

import flash.events.Event;

public class CRechargeRebateEvent extends Event {

    public static const RECHARGE_REBATE_INFO_RESPONSE:String = "recharge_rebate_info_response";
    public static const SHOW_RECHARGE_REBATE_VIEW:String = "show_recharge_rebate_view";
    public static const RECEIVE_REBATE_REWARD_RESPONSE:String = "receive_rebate_reward_response";

    public function CRechargeRebateEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
