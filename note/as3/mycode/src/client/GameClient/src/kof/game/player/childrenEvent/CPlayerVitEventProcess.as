//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CVitData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerVitEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerVitEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_VIT);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CVitData._physicalStrength)) {
            _isChange = oldPlayerData.vitData.physicalStrength != newDataObject[CVitData._physicalStrength];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVitData._buyPhysicalStrengthCount)) {
            _isChange = oldPlayerData.vitData.buyPhysicalStrengthCount != newDataObject[CVitData._buyPhysicalStrengthCount];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVitData._remainTimeGetNextVit)) {
            _isChange = oldPlayerData.vitData.remainTimeGetNextVit != newDataObject[CVitData._remainTimeGetNextVit];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVitData._notRemindFlag)) {
            _isChange = oldPlayerData.vitData.notRemindFlag != newDataObject[CVitData._notRemindFlag];
        }
    }
}
}
