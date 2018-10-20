//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network {

import flash.utils.Dictionary;

import kof.framework.network.impl.CNetworkMessageBindingBuilder;

[ExcludeClass]
/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CNetworkGlobals {

    // Run class initialization.
    staticInitialization();

    /** @private */
    static private function staticInitialization():void {
        // NOOP.
    }

    static public function newBinder(bindings:Dictionary):INetworkMessageBinder {
        return CNetworkMessageBindingBuilder.newBinder(bindings);
    }

    static public function deleteBinder(binder:INetworkMessageBinder):void {
        // NOOP.
    }

    /** @private */
    public function CNetworkGlobals() {
        throw "Instances CNetworkGlobals is not allowed.";
    }

}
}
