//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/21.
 */
package kof.game.playerCard.event {

import flash.events.Event;

public class CPlayerCardEvent extends Event {

    public static const SubPoolInfo:String = "SubPoolInfo";// 子卡池信息
    public static const PumpCard:String = "PumpCard";// 抽卡

    public var data:Object;

    public function CPlayerCardEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
