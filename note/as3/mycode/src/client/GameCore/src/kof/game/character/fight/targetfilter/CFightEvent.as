//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/7/18.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import flash.events.Event;

public class CFightEvent extends Event {
    public static var STOP_FIGHT_HDL : String = "stopfighthandler";
    public function CFightEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
    }
}
}
