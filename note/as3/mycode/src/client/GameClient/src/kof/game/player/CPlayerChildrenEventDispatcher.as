//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player {

import QFLib.Interface.IDisposable;

import kof.game.player.childrenEvent.CPlayerArenaEventProcess;
import kof.game.player.childrenEvent.CPlayerArtifactEventProcess;
import kof.game.player.childrenEvent.CPlayerChildrenEventProcess;
import kof.game.player.childrenEvent.CPlayerCultivateEventProcess;
import kof.game.player.childrenEvent.CPlayerEquiqCardEventProcess;
import kof.game.player.childrenEvent.CPlayerGuildEventProcess;

import kof.game.player.childrenEvent.CPlayerHeroCardEventProcess;
import kof.game.player.childrenEvent.CPlayerHeroEventProcess;
import kof.game.player.childrenEvent.CPlayerLevelUpEventProcess;
import kof.game.player.childrenEvent.CPlayerMonthAndWeekEventProcess;
import kof.game.player.childrenEvent.CPlayerOriginCurrencyEventProcess;

import kof.game.player.childrenEvent.CPlayerPeakEventProcess;
import kof.game.player.childrenEvent.CPlayerPeakFairEventProcess;
import kof.game.player.childrenEvent.CPlayerPlatformEventProcess;
import kof.game.player.childrenEvent.CPlayerSkillEventProcess;
import kof.game.player.childrenEvent.CPlayerSystemEventProcess;
import kof.game.player.childrenEvent.CPlayerTalentEventProcess;

import kof.game.player.childrenEvent.CPlayerTaskEventProcess;
import kof.game.player.childrenEvent.CPlayerTeamEventProcess;
import kof.game.player.childrenEvent.CPlayerTutorEventProcess;
import kof.game.player.childrenEvent.CPlayerVipEventProcess;
import kof.game.player.childrenEvent.CPlayerVipLevelUpEventProcess;

import kof.game.player.childrenEvent.CPlayerVitEventProcess;


import kof.game.player.data.CPlayerData;

// playerData 子事件派发处理
public class CPlayerChildrenEventDispatcher implements IDisposable {
    public function CPlayerChildrenEventDispatcher(netHandler:CPlayerHandler) {
        _pNetHandler = netHandler;

        var clazzList:Array = [
            CPlayerLevelUpEventProcess, CPlayerVipLevelUpEventProcess, CPlayerOriginCurrencyEventProcess,
            CPlayerVitEventProcess, CPlayerVipEventProcess, CPlayerTeamEventProcess,
            CPlayerPeakEventProcess, CPlayerPeakFairEventProcess, CPlayerCultivateEventProcess,
            CPlayerHeroCardEventProcess, CPlayerArenaEventProcess,
            CPlayerEquiqCardEventProcess, CPlayerTalentEventProcess, CPlayerSystemEventProcess,
            CPlayerArtifactEventProcess ,CPlayerMonthAndWeekEventProcess, CPlayerTaskEventProcess,
            CPlayerTutorEventProcess, CPlayerSkillEventProcess, CPlayerHeroEventProcess, CPlayerGuildEventProcess,
            CPlayerPlatformEventProcess
        ];
        _processList = new Vector.<CPlayerChildrenEventProcess>(clazzList.length);
        for (var i:int = 0; i < clazzList.length; i++) {
            var clazz:Class = clazzList[i]  as Class;
            _processList[i] = new clazz(this);
        }
    }

    public function dispose() : void {
        _pNetHandler = null;
        if (_processList) {
            for each (var processer:CPlayerChildrenEventProcess in _processList) {
                processer.dispose();
            }
        }
        _processList = null;
    }

    // 玩家基本信息改变
    public function processChildrenEvent(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        for each (var processer:CPlayerChildrenEventProcess in _processList) {
            processer.process(newDataObject, oldPlayerData);
        }
    }

    public function dispatchChildrenEvent(playerData:CPlayerData) : void {
        var processer:CPlayerChildrenEventProcess;
        for each (processer in _processList) {
            processer.dispatch(playerData);
        }

        for each (processer in _processList) {
            processer.reset();
        }
    }

    // ======================================================================
    [Inline]
    public function get netHandler():CPlayerHandler {
        return _pNetHandler;
    }

    private var _pNetHandler:CPlayerHandler;
    private var _processList:Vector.<CPlayerChildrenEventProcess>;

}
}
