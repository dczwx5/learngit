//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.subData.CTeamData;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerTeamEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerTeamEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_TEAM);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CTeamData._name)) {
            _isChange = oldPlayerData.teamData.name != newDataObject[CTeamData._name];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._battleValue)) {
            _isChange = oldPlayerData.teamData.battleValue != newDataObject[CTeamData._battleValue];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._level)) {
            _isChange = oldPlayerData.teamData.level != newDataObject[CTeamData._level];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._exp)) {
            _isChange = oldPlayerData.teamData.exp != newDataObject[CTeamData._exp];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._useHeadID)) {
            _isChange = oldPlayerData.teamData.useHeadID != newDataObject[CTeamData._useHeadID];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._prototypeID)) {
            _isChange = oldPlayerData.teamData.prototypeID != newDataObject[CTeamData._prototypeID];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._firstModifyName)) {
            _isChange = oldPlayerData.teamData.firstModifyName != newDataObject[CTeamData._firstModifyName];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._createTeam)) {
            _isChange = oldPlayerData.teamData.createTeam != newDataObject[CTeamData._createTeam];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CTeamData._sign)) {
            _isChange = oldPlayerData.teamData.sign != newDataObject[CTeamData._sign];
        }
    }
}
}
