//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate.event {

import flash.events.Event;
public class CCultivateEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "CultivatenetData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "CultivatenetUpdateData"; // 更新数据
    public static const NET_EVENT_RESET_DATA:String = "CultivatenetResetData"; // 重置数据

    public static const NET_EVENT_RESULT_DATA:String = "CultivatenetResultData"; // 结算
    public static const NET_EVENT_REWARD_BOX_DATA:String = "CultivatenetRewardBoxData"; // 领宝箱

    // data event
    public static const DATA_EVENT:String = "CultivateDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CCultivateEvent(type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
