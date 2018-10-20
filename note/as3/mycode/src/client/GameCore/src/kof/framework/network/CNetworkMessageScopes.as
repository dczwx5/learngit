//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CNetworkMessageScopes {

    public static var DEFAULT:INetworkMessageScope;
    public static var NO_SCOPES:INetworkMessageScope;

    /**
     * Constructor
     */
    public function CNetworkMessageScopes() {
        throw new Error("Instance CNetworkMessageScopes is not allowed.");
    }

}
}

import kof.framework.IProvider;
import kof.framework.network.CNetworkMessageScopes;
import kof.framework.network.INetworkMessageBindingKey;
import kof.framework.network.INetworkMessageScope;

{
    CNetworkMessageScopes.DEFAULT = new __NewScope();
    CNetworkMessageScopes.NO_SCOPES = new __NoScope();
}

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class __NoScope implements INetworkMessageScope {

    function __NoScope() {
        super();
    }

    public function runScope(key:INetworkMessageBindingKey, provider:IProvider):IProvider {
        return provider;
    }

}

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class __NewScope implements INetworkMessageScope {

    function __NewScope() {
        super();
    }

    public function runScope(key:INetworkMessageBindingKey, provider:IProvider):IProvider {
        return provider;
    }

}
