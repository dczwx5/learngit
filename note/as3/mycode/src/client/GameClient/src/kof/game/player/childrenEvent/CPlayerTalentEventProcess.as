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

public class CPlayerTalentEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerTalentEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_TALENT);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CCurrencyData._talentPoint)) {
            _isChange = oldPlayerData.currency.talentPoint != newDataObject[CCurrencyData._talentPoint];
        }
        if(!_isChange && newDataObject.hasOwnProperty(CGlobalPropertyData._talentProperty)) {
            _isChange = true;
        }
    }
}
}
