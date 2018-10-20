//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CTeamData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerLevelUpEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerLevelUpEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_LEVEL_UP);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        var lastLevel:int = oldPlayerData.teamData.level;
        var curLevel:int = newDataObject[CTeamData._level];
        var isLevelUp : Boolean = curLevel > lastLevel;
        if (isLevelUp) {
            oldPlayerData.backup();
        }
        // 计算经验改变值
        if (newDataObject.hasOwnProperty(CTeamData._exp)) {
            var expChange:int;
            var curExp:int = newDataObject[CTeamData._exp];
            expChange = oldPlayerData.calcExpChange( curLevel, curExp );
            if (expChange > 0) {
                oldPlayerData.lastTotalExp = oldPlayerData.nextLevelExpCost;
                oldPlayerData.lastExp = oldPlayerData.teamData.exp;
                oldPlayerData.lastLevel = oldPlayerData.teamData.level;
                oldPlayerData.lastExpChange = expChange;
            }
        }
        _isChange = isLevelUp;
    }

    public override function dispatch(playerData:CPlayerData) : void {
        if (_isChange) {
            playerData.isLevelUp = true;
        }
        super.dispatch(playerData);
    }
}
}
