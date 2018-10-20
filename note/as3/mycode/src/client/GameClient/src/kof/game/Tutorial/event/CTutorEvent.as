//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.event {

import flash.events.Event;
public class CTutorEvent extends Event {

    // 战斗引导 net
    public static const NET_EVENT_START_BATTLE_TUTOR:String = "battleTutorStartNetEvent"; // 开始一个战斗指引

    // 战斗引导 流程
    public static const BATTLE_TUTOR_PREPARE:String = "tutorPrepare"; // 战斗引导准备
    public static const BATTLE_TUTOR_STARTED:String = "tutorStarted"; // 战斗引导开始
    public static const BATTLE_TUTOR_END:String = "tutorPrepare"; // 战斗引导完成

    //
    public static const DATA_EVENT:String = "tutorDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    // 流程事件
    public static const TUTOR_PREPARE:String = "tutorPrepare"; // 引导准备
    public static const TUTOR_STARTED:String = "tutorStarted"; // 引导开始
    public static const TUTOR_END:String = "tutorPrepare"; // 引导完成

    public function CTutorEvent(type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
