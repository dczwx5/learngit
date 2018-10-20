//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/11.
 */
package kof.ui.event {

import flash.events.Event;

public class CSceneLoadingEvent extends Event {

//    public static const EVENT_LOADING_PROCESS:String = "loading_process";

    public function CSceneLoadingEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
