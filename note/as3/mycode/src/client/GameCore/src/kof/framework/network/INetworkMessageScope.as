//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

import kof.framework.IProvider;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INetworkMessageScope {

    function runScope(key:INetworkMessageBindingKey, provider:IProvider):IProvider;

} // interface INetworkMessageScope
}
