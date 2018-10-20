//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/2.
 */
package kof.game.chat {

import flash.events.Event;

public class CChatEvent extends  Event{

    public static const CHAT_RESPONSE : String = "chat_response";

    public static const FACE_BUY_SUCC : String = "face_buy_succ";

    public function CChatEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
