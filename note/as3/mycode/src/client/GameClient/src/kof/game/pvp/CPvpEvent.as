//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/26.
 */
package kof.game.pvp {

import flash.events.Event;

public class CPvpEvent extends Event {
    public static const QUERY_ROOM:String = "QueryRoom";
    public static const CREATE_ROOM:String = "CreateRoom";
    public var data:Object = null;
    public function CPvpEvent( type : String, data : Object = null) {
        super( type, bubbles, cancelable );
        this.data = data;
    }
}
}
