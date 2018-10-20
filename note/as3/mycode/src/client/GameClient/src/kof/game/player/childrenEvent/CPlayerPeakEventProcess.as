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

public class CPlayerPeakEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerPeakEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_PEAK);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CCurrencyData._gloryCoin)) {
            _isChange = oldPlayerData.currency.honorCoin != newDataObject[CCurrencyData._gloryCoin];
        }
    }
}
}
