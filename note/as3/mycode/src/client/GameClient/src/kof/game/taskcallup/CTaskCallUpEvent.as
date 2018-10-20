//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup {
import flash.events.Event;
public class CTaskCallUpEvent extends Event{

    public static const TASK_CALL_UP_UPDATE:String = "task_call_up_update";

    public static const TASK_CALL_UP_REFRESH:String = "task_call_up_refresh";

    public static const ACCEPT_TASK_CALLUP_RESPONSE:String = "accept_task_callup_response";

    public static const CANCEL_TASK_CALLUP_RESPONSE:String = "cancel_task_callup_response";

    public static const TASK_CALL_UP_CAN_REWARD:String = "task_call_up_can_reward";

    public function CTaskCallUpEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
