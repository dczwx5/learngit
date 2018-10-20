//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package kof.game.Tutorial.battleTutorPlay {

import flash.events.Event;

public class CBattleTutorEvent extends Event {
    public static const EVENT_START:String = "tutor_start";
    public static const EVENT_FINISH:String = "tutor_finish";
    public static const EVENT_STEP_CHANGE:String = "tutor_step_change";

    public function CBattleTutorEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
