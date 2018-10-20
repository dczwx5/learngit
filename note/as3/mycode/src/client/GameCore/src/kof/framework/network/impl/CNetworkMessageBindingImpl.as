//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network.impl {

import kof.framework.IProvider;
import kof.framework.network.INetworkMessageBindingKey;
import kof.framework.network.INetworkMessageScope;

[ExcludeClass]
/**
 * An implementation for binding's value object, just storage the bindings
 * elements.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CNetworkMessageBindingImpl {

    /**
     * Constructor
     */
    public function CNetworkMessageBindingImpl(key:INetworkMessageBindingKey, provider:IProvider = null,
                                               scope:INetworkMessageScope = null) {
        super();

        this.key = key;
        this.provider = provider;
        this.scope = scope;
    }

    public var key:INetworkMessageBindingKey;
    public var provider:IProvider;
    public var handler:Function;
    public var scope:INetworkMessageScope;

    internal function withToken(token:*):CNetworkMessageBindingImpl {
        key = key || new CSimpleNetworkMessageBindingKey();
        (key as CSimpleNetworkMessageBindingKey)._forToken = token;
        return this;
    }

    internal function withNamed(named:String):CNetworkMessageBindingImpl {
        key = key || new CSimpleNetworkMessageBindingKey();
        (key as CSimpleNetworkMessageBindingKey)._forNamed = named;
        return this;
    }

    internal function toProvider(provider:IProvider):CNetworkMessageBindingImpl {
        this.provider = provider;
        return this;
    }

    internal function withScope(scope:INetworkMessageScope):CNetworkMessageBindingImpl {
        this.scope = scope;
        return this;
    }

    internal function toHandler(handler:Function):CNetworkMessageBindingImpl {
        this.handler = handler;
        return this;
    }
}
}

