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
import kof.game.player.data.subData.CSubTutorData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerTutorEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerTutorEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_TUTOR);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CSubTutorData._guideIndex)) {
            _isChange = oldPlayerData.tutorData.guideIndex != newDataObject[CSubTutorData._guideIndex];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSubTutorData._battleGuideStep)) {
            _isChange = oldPlayerData.tutorData.battleGuideStep != newDataObject[CSubTutorData._battleGuideStep];
        }
    }
}
}
