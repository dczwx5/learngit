//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy {

import kof.net.*;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CDummyNetworkSystem extends CNetworkSystem {

    /**
     * Creates a new CDummyNetworkSystem.
     */
    public function CDummyNetworkSystem() {
        super();
    }

    override protected function get channelClass():Class {
        if (stage.configuration.getBoolean('dummy')) {
            return CDummyFallbackChannel;
        } else {
            return super.channelClass;
        }
    }

}
}
