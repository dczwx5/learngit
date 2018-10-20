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
import kof.game.player.data.subData.CSystemData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerSystemEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerSystemEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_SYSTEM);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CSystemData._channelInfo)) {
            _isChange = oldPlayerData.systemData.channelInfo != newDataObject[CSystemData._channelInfo];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSystemData._openSeverDays)) {
            _isChange = oldPlayerData.systemData.openSeverDays != newDataObject[CSystemData._openSeverDays];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSystemData._sevenDaysLoginActivityState)) {
            _isChange = oldPlayerData.systemData.sevenDaysLoginActivityState != newDataObject[CSystemData._sevenDaysLoginActivityState];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSystemData._firstRechargeState)) {
            _isChange = oldPlayerData.systemData.firstRechargeState != newDataObject[CSystemData._firstRechargeState];
        }
    }
}
}
