//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network.impl {

import kof.framework.IProvider;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSingletonNetworkMessageProvider implements IProvider {

    private var m_instance:Object;

    public function CSingletonNetworkMessageProvider(instance:Object) {
        super();
        this.m_instance = instance;
    }

    public function getInstance():* {
        return m_instance;
    }

}
}
