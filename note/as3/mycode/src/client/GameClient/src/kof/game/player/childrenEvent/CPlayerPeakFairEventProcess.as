//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerBaseData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerPeakFairEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerPeakFairEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_PEAK_FAIR);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CCurrencyData._fairPeakCoin)) {
            _isChange = oldPlayerData.currency.fairPeakCoin != newDataObject[CCurrencyData._fairPeakCoin];
        }
    }
}
}
