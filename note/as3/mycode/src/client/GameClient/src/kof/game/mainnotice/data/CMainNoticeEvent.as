//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/6.
 */
package kof.game.mainnotice.data {

import flash.events.Event;

public class CMainNoticeEvent extends  Event{

    public static const MAIN_NOTICE_UPDATE : String = "main_notice_update";

    public function CMainNoticeEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;

    }
    public var data:Object;
}
}
