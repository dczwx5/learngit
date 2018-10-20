//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.event {

import flash.events.Event;
public class CStrengthenEvent extends Event {
    // data event
    public static const DATA_EVENT:String = "StoryDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CStrengthenEvent( type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
