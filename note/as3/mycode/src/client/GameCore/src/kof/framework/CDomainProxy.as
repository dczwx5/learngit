//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import avmplus.getQualifiedClassName;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import kof.framework.events.CPropertyChangeEvent;

use namespace flash_proxy;

/**
 * Domain Model Proxy.
 *
 * - Auto handling properties changed.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public dynamic class CDomainProxy extends Proxy implements IEventDispatcher {

    /**
     * Creates a CDomainProxy object.
     */
    public function CDomainProxy(target:* = null) {
        super();

        if (!target)
            _item = [];
        else
            _item = target;
    }

    /** @private */
    private var _item:*;

    /** @private */
    private var _eventDelegate:IEventDispatcher;

    internal function get eventDelegate():IEventDispatcher {
        if (!_eventDelegate) {
            _eventDelegate = new EventDispatcher(this);
        }
        return _eventDelegate;
    }

    override flash_proxy function deleteProperty(name:*):Boolean {
        var ret:Boolean = name in _item;
        delete _item[name];
        return ret;
    }

    override flash_proxy function getDescendants(name:*):* {
        return _item[name];
    }

    override flash_proxy function nextNameIndex(index:int):int {
        return super.flash_proxy::nextNameIndex(index);
    }

    override flash_proxy function nextName(index:int):String {
        return super.flash_proxy::nextName(index);
    }

    override flash_proxy function nextValue(index:int):* {
        return super.flash_proxy::nextValue(index);
    }

    override flash_proxy function isAttribute(name:*):Boolean {
        return super.flash_proxy::isAttribute(name);
    }

    override flash_proxy function hasProperty(name:*):Boolean {
        return name in _item;
    }

    override flash_proxy function getProperty(name:*):* {
        return _item[name];
    }

    override flash_proxy function setProperty(name:*, value:*):void {
        // set property by dirty mode.
        var currentVal:* = _item[name];
        if (currentVal != value) {
            _item[name] = value;
            // dispatching property changed event.
            eventDelegate.dispatchEvent(new CPropertyChangeEvent(CPropertyChangeEvent.CHANGE, name, currentVal, value));
        }
    }

    override flash_proxy function callProperty(name:*, ...rest):* {
        var ret:*;

        ret = _item[name].apply(_item, rest);

        switch (name.toString()) {
            case 'toString':
                if (ret == "") {
                    ret = "[domain " + getQualifiedClassName(this) + "]";
                }
                break;
        }

        return ret;
    }

    //------------------------------------------------------------------------------
    // IEventDispatcher Delegation Implementations.
    //------------------------------------------------------------------------------

    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        eventDelegate.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        eventDelegate.removeEventListener(type, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Boolean {
        return eventDelegate.dispatchEvent(event);
    }

    public function hasEventListener(type:String):Boolean {
        return eventDelegate.hasEventListener(type);
    }

    public function willTrigger(type:String):Boolean {
        return eventDelegate.willTrigger(type);
    }

} // class CDomainProxy
}
