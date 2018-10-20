//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-01.
 */
package kof.game.redPacket {

import flash.events.Event;

/**
 *@author Demi.Liu
 *@data 2018-06-01
 */
public class CRedPacketEvent extends Event {
    public static const openRedPacketResponse:String = "openRedPacketResponse";// 打开红包，更新红包面板

    public var data:Object;

    public function CRedPacketEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }
}
}
