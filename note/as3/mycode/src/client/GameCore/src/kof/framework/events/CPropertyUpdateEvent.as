//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/6/13.
 */
package kof.framework.events {

import flash.events.Event;
import flash.utils.Dictionary;

import kof.game.core.CGameObject;

public class CPropertyUpdateEvent extends Event {

    public var propertyDic : Dictionary;
    public var owner : CGameObject;

    public function CPropertyUpdateEvent( type : String, owner : CGameObject,propertyDic : Dictionary, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.owner = owner;
        this.propertyDic = propertyDic;
    }
}
}
