//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/18.
 */
package kof.game.task {

import flash.events.Event;

public class CTaskEvent extends Event{

    public static const TASK_INIT:String = "task_init";
    public static const TASK_UPDATE:String = "task_update";
    public static const PLOT_TASK_UPDATE:String = "plot_task_update";
    public static const DRAW_DAILY_TASK_ACTIVE_REWARD:String = "draw_daily_task_active_reward";
    public static const TASK_FINISH:String = "task_finish";
    public static const TASK_COMPLETE:String = "task_complete";
    public static const TASK_RESET_RESPONSE:String = "task_reset_response";
    public static const TASK_ADD:String = "task_add";
//    public static const PLOT_TASK_AWARD_IN_MAINCITY:String = "plot_task_award_in_maincity";

    public static const TASK_DATA_UPDATE_COMP:String = "task_data_update_comp";

    public function CTaskEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
