//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/22.
 */
package kof.game.sevenkHall.event {

import flash.events.Event;

public class C7K7KEvent extends Event {

    public static const UpdateAllRewardInfo:String = "UpdateAllRewardInfo";// 更新所有奖励状态
    public static const UpdateNewRewardState:String = "UpdateNewRewardState";// 更新新手奖励状态
    public static const UpdateDailyRewardState:String = "UpdateDailyRewardState";// 更新每日奖励状态
    public static const UpdateLevelRewardState:String = "UpdateLevelRewardState";// 更新等级奖励状态

    public var data:Object;

    public function C7K7KEvent(type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false )
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
