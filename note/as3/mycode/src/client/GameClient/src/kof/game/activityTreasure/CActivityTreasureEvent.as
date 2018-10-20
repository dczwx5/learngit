//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/18.
 */
package kof.game.activityTreasure {

import flash.events.Event;

public class CActivityTreasureEvent extends Event {

    public static const DigTreasureActivityDataResponse : String = "DigTreasureActivityDataResponse";
    public static const DigTreasureResponse : String = "DigTreasureResponse";
    public static const OpenDigTreasureBoxResponse : String = "OpenDigTreasureBoxResponse";
    public static const DigTreasureActivityDataUpdateEvent : String = "DigTreasureActivityDataUpdateEvent";

    public function CActivityTreasureEvent( type : String, data : Object = null, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }

    public var data : Object;
}
}
