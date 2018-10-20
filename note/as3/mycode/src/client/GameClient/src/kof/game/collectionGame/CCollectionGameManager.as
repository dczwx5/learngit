//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/13.
 */
package kof.game.collectionGame {

import QFLib.Utils.CFlashVersion;

import kof.framework.CAbstractHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CCollectionGameManager extends CAbstractHandler {
    public function CCollectionGameManager() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if (playerData.systemData.isCollectionGame || CFlashVersion.isDesktop())
        {
            (system as CCollectionGameSystem).closeCollectionGameSystem();
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
