//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.player.data.subData.CMonthAndWeekCardData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerMonthAndWeekEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerMonthAndWeekEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CMonthAndWeekCardData._goldCardState)) {
            _isChange = oldPlayerData.monthAndWeekCardData.goldCardState != newDataObject[CMonthAndWeekCardData._goldCardState];
        }
        if(!_isChange && newDataObject.hasOwnProperty(CMonthAndWeekCardData._silverCardState)) {
            _isChange = oldPlayerData.monthAndWeekCardData.silverCardState != newDataObject[CMonthAndWeekCardData._silverCardState];
        }
    }
}
}
