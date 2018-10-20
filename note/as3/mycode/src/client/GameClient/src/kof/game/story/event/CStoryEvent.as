//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.event {

import flash.events.Event;
public class CStoryEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netStoryData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netStoryUpdateData"; // 更新数据
    public static const NET_EVENT_SETTLEMENT_DATA:String = "netStorySettlementData"; // 整场结算
    public static const NET_EVENT_BUY_FIGHT_COUNT:String = "netStoryBuyFightCount";
    public static const NET_EVENT_FIGHT:String = "netStoryFight"; //

    // data event
    public static const DATA_EVENT:String = "StoryDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CStoryEvent( type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
