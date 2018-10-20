//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/13.
 */
package kof.game.recharge.event {

import flash.events.Event;

public class CDailyRechargeEvent extends Event {

    public static const StateChange:String = "StateChange";// 首充状态变更

    public var data:Object;

    public function CDailyRechargeEvent( type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
    }
}
}
