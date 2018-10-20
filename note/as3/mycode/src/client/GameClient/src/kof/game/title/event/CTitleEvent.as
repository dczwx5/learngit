//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.event {

import flash.events.Event;
public class CTitleEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netUpdateData"; // 更新数据
    public static const NET_EVENT_WEAR:String = "netWear"; //

    public static const FRIEND_DATA_EVENT:String = "FriendDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    // data event
    public static const DATA_EVENT:String = "StoryDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CTitleEvent( type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
