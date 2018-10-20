//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/13.
 */
package kof.game.OneDiamondReward {

import flash.events.Event;

public class COneDiamondEvent extends Event {

    public static const StateChange:String = "StateChange";// 首充状态变更

    public var data:Object;

    public function COneDiamondEvent( type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }
}
}
