//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/5.
 */
package kof.game.gm.event {

import flash.events.Event;

public class CGmEvent extends Event {
    public static const EVENT_SELECT_HERO_DATA:String = "select_hero_data";

    public function CGmEvent(type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false) {
        super(type, bubbles, cancelable);
        _data = data;
    }

    public function get data() : Object {
        return _data;
    }
    private var _data:Object;
}
}
