//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/14.
 */
package kof.game.weiClient {

import QFLib.Utils.CFlashVersion;

import kof.framework.CAbstractHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CWeiClientManager extends CAbstractHandler {
    public function CWeiClientManager() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if (playerData.systemData.isGetMicroClientReward && CFlashVersion.isDesktop())
        {
            (system as CWeiClientSystem).closeWeiClientSystem();
        }
        return ret;
    }

    private function get playerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }
}
}
