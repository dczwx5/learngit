//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/30.
 */
package kof.game.common.loading {

import flash.events.Event;

public class CLoadingEvent extends Event {
    public static const LOADING_PROCESS_UPDATE:String = "event_process_update";
    public static const LOADING_PROCESS_FINISH:String = "event_process_finish";
    public static const LOADING_REQUIRE_TO_END:String = "event_require_to_end";

    public static const VIRTUAL_LOAD_FINISHED:String = "event_virtual_load_finish";

    public function CLoadingEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _data = data;
    }

    public function get data() : Object {
        return _data;
    }
    private var _data:Object;
}
}
