//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.events {

import flash.events.Event;

/**
 * A request-side event same as mx.core.Request.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRequestEvent extends Event {

    public var data : *;

    public function CRequestEvent( type : String, data : * = undefined, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.data = data;
    }

}
}
