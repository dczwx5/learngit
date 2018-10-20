//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/22.
 */
package kof.game.embattle {

import flash.events.Event;

public class CEmbattleEvent extends Event{

    public static const EMBATTLE_SUCC:String = "embattle_succ";

    public static const EMBATTLE_CLOSE:String = "embattle_close";

    public static const EMBATTLE_DATA:String = "embattle_data"; // 有返回就发出, add by auto

    public static const EMBATTLE_POSITION_CHANGE:String = "embattle_position_change"; // 有返回就发出, add by auto

    public function CEmbattleEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);

        this.data = data;
    }

    public var data:Object;
}
}
