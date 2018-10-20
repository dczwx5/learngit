//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network.impl {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import kof.framework.IProvider;
import kof.framework.network.CNetworkMessageScopes;
import kof.framework.network.INetworkMessageBinder;
import kof.framework.network.INetworkMessageLinkedBuilder;
import kof.framework.network.INetworkMessageScope;
import kof.framework.network.INetworkMessageScopeBuilder;

[ExcludeClass]
/**
 * An internal implementation for <code>INetworkMessageLinkedBuilder</code> and
 * <code>INetworkMessageScopeBuilder</code>.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNetworkMessageBindingBuilder implements INetworkMessageLinkedBuilder, INetworkMessageScopeBuilder {

    /**
     * Creates a new binder.
     */
    static public function newBinder(bindings:Dictionary):INetworkMessageBinder {
        if (!CNetworkMessageBinderImpl.builderClass) {
            CNetworkMessageBinderImpl.builderClass = CNetworkMessageBindingBuilder;
        }

        return new CNetworkMessageBinderImpl(bindings);
    }

    /**
     * Constructor
     */
    public function CNetworkMessageBindingBuilder(binder:INetworkMessageBinder,
                                                  bindings:Dictionary, clazz:Class = null) {
        super();

        _impl = new CNetworkMessageBindingImpl(new CSimpleNetworkMessageBindingKey(clazz));
        this._bindings = bindings;
        binder.addEventListener(Event.COMPLETE, binder_onComplete, false, 0, true);
    }

    private var _impl:CNetworkMessageBindingImpl;
    private var _bindings:Dictionary;

    public function get binding():CNetworkMessageBindingImpl {
        return _impl;
    }

    public function withNamed(named:String):INetworkMessageLinkedBuilder {
        _setBinding(_impl.withNamed(named));
        return this;
    }

    public function withToken(token:*):INetworkMessageLinkedBuilder {
        _setBinding(_impl.withToken(token));
        return this;
    }

    public function toInstance(instance:Object):INetworkMessageLinkedBuilder {
        _setBinding(_impl.toProvider(new InternalNetworkMessageProvider(instance)));
        return this;
    }

    public function toClass(target:Class):INetworkMessageScopeBuilder {
        _setBinding(_impl.toProvider(new InternalNetworkMessageProvider(target)));
        return this;
    }

    public function toProvider(provider:IProvider):INetworkMessageScopeBuilder {
        _setBinding(_impl.toProvider(provider));
        return this;
    }

    public function inScope(scope:INetworkMessageScope):void {
        _setBinding(_impl.withScope(scope));
        // return
    }

    public function toHandler(func:Function):INetworkMessageScopeBuilder {
        _setBinding(_impl.toHandler(func));
        return this;
    }

    private function _setBinding(impl:CNetworkMessageBindingImpl):void {
        this._impl = impl;
    }

    /** @private */
    private function binder_onComplete(event:Event):void {
        EventDispatcher(event.currentTarget).removeEventListener(event.type,
                binder_onComplete);

        if (!_impl.scope) {
            _impl.scope = CNetworkMessageScopes.NO_SCOPES;
        }

        if (!_impl.provider) {
            _impl.provider = new CNewCreateNetworkMessageProvider(_impl.key.forClass);
        }

        _bindings[_impl.key] = _impl;
    }

}
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import kof.framework.IProvider;
import kof.framework.network.INetworkMessageBinder;
import kof.framework.network.INetworkMessageLinkedBuilder;
import kof.framework.network.impl.CNewCreateNetworkMessageProvider;
import kof.framework.network.impl.CSingletonNetworkMessageProvider;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class CNetworkMessageBinderImpl extends EventDispatcher implements INetworkMessageBinder {

    /** @private */
    static internal var builderClass:Class;

    internal var bindings:Dictionary;
    internal var builders:Array;

    function CNetworkMessageBinderImpl(bindings:Dictionary) {
        this.bindings = bindings;
        this.builders = [];
    }

    public function bind(clazz:Class):INetworkMessageLinkedBuilder {
        if (!clazz)
            throw new ArgumentError("Invalid binding class.");

        if (!(clazz in this.bindings)) {
            bindings[clazz] = new Dictionary();
        }

        var builder:INetworkMessageLinkedBuilder = new builderClass(this, bindings[clazz]);
        builders.push(builder);

        return builder;
    }

    private function onBuiltCompleted(event:Event):void {

    }

    public virtual function dispose():void {
        bindings = null;

        if (builders)
            builders.splice(0, builders.length);
        builders = null;
    }

}

/** @private */
class InternalNetworkMessageProvider implements IProvider {

    /** Constructor */
    function InternalNetworkMessageProvider(impl:*) {
        super();

        if (impl is Class) {
            _provider = new CNewCreateNetworkMessageProvider(impl as Class);
        } else if (impl is Object) {
            _provider = new CSingletonNetworkMessageProvider(impl);
        } else if (impl is Function) {
            // TODO: provider with function handler.
        }
    }

    /** @private */
    private var _provider:IProvider;

    /**
     * @{inheritDoc}
     */
    public function getInstance():* {
        return _provider.getInstance();
    }

}
