//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

import QFLib.Interface.IDisposable;

import flash.events.IEventDispatcher;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INetworkMessageBinder extends IEventDispatcher, IDisposable {

    function bind(msgClass:Class):INetworkMessageLinkedBuilder;

}
}
