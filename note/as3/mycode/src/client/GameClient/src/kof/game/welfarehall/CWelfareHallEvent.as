//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/21.
 */
package kof.game.welfarehall {

import flash.events.Event;

public class CWelfareHallEvent extends Event{

    public static const WELFAREHALL_VIEW_CLOSE:String = 'welfarehall_view_close';

    public static const ACTIVATION_CODE_RESPONSE:String = "activation_code_response";
    public static const TAKE_REWARD_SUCC:String = "TAKE_REWARD_SUCC";
    public static const ANNOUNCEMENT_UPDATE:String = "ANNOUNCEMENT_UPDATE";
    public static const ADVERTISING_UPDATE:String = "ADVERTISING_UPDATE";
    public static const CARDMONTHINFO_RESPONSE:String = "cardmonthinfo_response";
    public static const GETCARDMONTHREWARD_RESPONSE:String = "getcardmonthreward_response";
    public static const UPDATE_RECOVERY_VIEW : String = "update_recovery_view";
    public static const UPDATE_RED_POINT : String = "update_red_point";
    public function CWelfareHallEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
