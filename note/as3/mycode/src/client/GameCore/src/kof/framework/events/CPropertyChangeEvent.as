//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.events {

import flash.events.Event;

/**
 * Dispatching for properties changed.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPropertyChangeEvent extends Event {

    public static const CHANGE:String = "__cPropertyChange";

    private var _propertyName:String;
    private var _oldValue:*;
    private var _newValue:*;

    /**
     * Creates a CPropertyChangeEvent object.
     */
    public function CPropertyChangeEvent(type:String, propertyName:String, oldValue:*, newValue:*, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);

        this._propertyName = propertyName;
        this._oldValue = oldValue;
        this._newValue = newValue;
    }

    /**
     * The name of property.
     */
    public function get propertyName():String {
        return _propertyName;
    }

    /**
     * The old value.
     */
    public function get oldValue():* {
        return _oldValue;
    }

    /**
     * The new value.
     */
    public function get newValue():* {
        return _newValue;
    }

}
}
