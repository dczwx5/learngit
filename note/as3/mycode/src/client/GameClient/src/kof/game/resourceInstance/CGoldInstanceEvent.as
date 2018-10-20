//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/2.
 */
package kof.game.resourceInstance {

import flash.events.Event;

public class CGoldInstanceEvent extends Event {
    public static const ADD_GOLD : String = "addGold";
    public static const UPDATE_DAMAGE : String = "update_damage";
    public static const START_TIME: String = "start_time";

    public function CGoldInstanceEvent( type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
