//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CGlobalPropertyData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerArtifactEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerArtifactEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_ARTIFACT);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CCurrencyData._artifactEnergy)) {
            _isChange = oldPlayerData.currency.artifactEnergy != newDataObject[CCurrencyData._artifactEnergy];
        }
        if(!_isChange && newDataObject.hasOwnProperty(CGlobalPropertyData._artifactProperty)) {
            _isChange = true;
        }
    }
}
}
