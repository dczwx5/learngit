//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INetworkMessageLinkedBuilder {

    function withToken(token:*):INetworkMessageLinkedBuilder;

    function toHandler(func:Function):INetworkMessageScopeBuilder;

    function toInstance(instance:Object):INetworkMessageLinkedBuilder;

    function withNamed(named:String):INetworkMessageLinkedBuilder;

}
}
