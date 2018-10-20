//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerOriginCurrencyEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerOriginCurrencyEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_ORIGIN_CURRENCY);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        var isGoldChange:Boolean;
        var isDiamondChange:Boolean;
        var isBindDiamondChange:Boolean;
        var isBuyGoldCountChange:Boolean;
        if (newDataObject.hasOwnProperty(CCurrencyData._gold)) {
            if (oldPlayerData.currency.gold != newDataObject[CCurrencyData._gold]) {
                isGoldChange = true;
            }
        }
        if (newDataObject.hasOwnProperty(CCurrencyData._buyGoldCount)) {
            if (oldPlayerData.currency.buyGoldCount!= newDataObject[CCurrencyData._buyGoldCount]) {
                isBuyGoldCountChange = true;
            }
        }
        if (newDataObject.hasOwnProperty(CCurrencyData._blueDiamond)) {
            if (oldPlayerData.currency.blueDiamond != newDataObject[CCurrencyData._blueDiamond]) {
                isDiamondChange = true;
            }
        }
        if (newDataObject.hasOwnProperty(CCurrencyData._purpleDiamond)) {
            if (oldPlayerData.currency.purpleDiamond != newDataObject[CCurrencyData._purpleDiamond]) {
                isBindDiamondChange = true;
            }
        }
        _isChange = isBindDiamondChange || isDiamondChange || isGoldChange || isBuyGoldCountChange;
    }
}
}
