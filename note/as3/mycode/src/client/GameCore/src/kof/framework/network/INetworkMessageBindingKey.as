//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INetworkMessageBindingKey {

    function get forClass():Class;

    function get forNamed():String;

    function get forToken():*;

    function equals(key:INetworkMessageBindingKey):Boolean;

} // interface INetworkMessageBindingKey
}

