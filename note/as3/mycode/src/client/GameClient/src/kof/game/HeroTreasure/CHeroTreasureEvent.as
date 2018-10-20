//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-05-28.
 */
package kof.game.HeroTreasure {

import flash.events.Event;

/**
 *@author Demi.Liu
 *@data 2018-05-28
 */
public class CHeroTreasureEvent extends Event {

    public static const drawTreasureResponse:String = "drawTreasureResponse";//获得抽奖奖励

    public var data:Object;

    public function CHeroTreasureEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }
}
}
