//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network.impl {

import kof.framework.IProvider;

[ExcludeClass]
/**
 * @author Jeremy
 */
public class CNewCreateNetworkMessageProvider implements IProvider {

    private var _impl:Class;

    public function CNewCreateNetworkMessageProvider(impl:Class) {
        super();
        this._impl = impl;
    }

    public function getInstance():* {
        var obj:* = new _impl;

        return obj;
    }

}
}
