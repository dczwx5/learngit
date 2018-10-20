//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/4.
 */
package kof.game.ActivityNotice.event {

import flash.events.Event;

public class CActivityNoticeEvent extends Event {

    public static const ActivityOpenStateChange:String = "ActivityStateChange";// 活动开启状态变更
    public static const ActivityIconInit:String = "ActivityIconInit";// 活动图标初始化
    public static const ActivityCrossDay:String = "ActivityCrossDay";// 活动跨天

    public var data:Object;

    public function CActivityNoticeEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
