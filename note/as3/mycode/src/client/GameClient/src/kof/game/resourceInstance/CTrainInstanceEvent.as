//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/10/27.
 */
package kof.game.resourceInstance {

import flash.events.Event;

public class CTrainInstanceEvent extends Event {
    public static const ROUND : String = "round";
    public static const UPDATE_AWARD:String = "update_award";

    public function CTrainInstanceEvent( type : String, data : Object = null, bubbles : Boolean = false, cancelable:Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }
    public var data:Object;

}
}
