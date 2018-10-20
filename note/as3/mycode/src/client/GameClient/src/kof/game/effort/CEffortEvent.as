//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort {

import flash.events.Event;

/**
 * 成就系统事件
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortEvent extends Event {

    /**
     * 获得成就通知事件
     */
    public static const ACHIEVE_EFFORT:String = 'effort_achieve_effort';
    /**
     * 分裂奖励通知事件
     */
    public static const TYPE_ACHIEVE_REWARD:String = 'effort_type_achieve_reward';

    /**
     * 目标数据变动(当前值、完成状态变动时发送）
     */
    public static const TARGET_POINT_CHANGE:String = "effort_target_point_change";

    public function CEffortEvent( type : String,data:Object = null, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }

    public var data:Object;
}
}
