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
import kof.game.player.data.subData.CSubSkillData;
import kof.game.player.data.subData.CSubTutorData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerSkillEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerSkillEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_SKILL);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CSubSkillData._buySkillPointCount)) {
            _isChange = oldPlayerData.skillData.buySkillPointCount != newDataObject[CSubSkillData._buySkillPointCount];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSubSkillData._skillPoint)) {
            _isChange = oldPlayerData.skillData.skillPoint != newDataObject[CSubSkillData._skillPoint];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSubSkillData._remainTimeGetNexSkillPoint)) {
            _isChange = oldPlayerData.skillData.remainTimeGetNexSkillPoint != newDataObject[CSubSkillData._remainTimeGetNexSkillPoint];
        }
    }
}
}
