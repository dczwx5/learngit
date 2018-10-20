//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/3/10.
 */
package kof.game.bundle {

import flash.events.Event;

public class CChildSystemBundleEvent extends Event {

    static public const CHILD_BUNDLE_START : String = "childBundleStart";
    static public const CHILD_BUNDLE_STOP : String = "childBundleStop";

    public var data:Object;

    public function CChildSystemBundleEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
