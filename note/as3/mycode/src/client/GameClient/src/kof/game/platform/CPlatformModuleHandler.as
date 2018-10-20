//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/28.
 */
package kof.game.platform {

import kof.framework.CAbstractHandler;
import kof.game.player.CPlayerSystem;


public class CPlatformModuleHandler extends CAbstractHandler {

    [Inline]
    public function get playerSystem() : CPlayerSystem {
        return system as CPlayerSystem;
    }
    [Inline]
    public function get platformHandler() : CPlatformHandler {
        return playerSystem.platform;
    }
}
}
