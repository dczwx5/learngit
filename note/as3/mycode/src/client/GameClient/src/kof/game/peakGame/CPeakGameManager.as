//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;

import QFLib.Interface.IUpdatable;

import kof.framework.IDatabase;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameDataEventType;
import kof.game.peakGame.enum.EPeakGameRankType;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;

public class CPeakGameManager extends CAbstractHandler implements IUpdatable {
    public function CPeakGameManager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onPeakGameNetEvent);

        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pPlayerData:CPlayerData = playerSystem.playerData;
        _peakGameFairData = new CPeakGameData(system.stage.getSystem(IDatabase) as IDatabase, EPeakGameWndType.PLAY_TYPE_FAIR,
                KOFTableConstants.FAIR_PEAK_GAME_LEVEL,
                KOFTableConstants.FAIR_PEAK_GAME_REWARD,
                KOFTableConstants.FAIR_PEAK_GAME_CONSTANT);
        _peakGameFairData._playerUID = pPlayerData.ID;

        _system.listenEvent(_onPeakGameNetEvent);

        return ret;
    }

    private function _onPeakGameNetEvent(e:CPeakGameEvent) : void {
        if (e.type == CPeakGameEvent.DATA_EVENT) {
            return ;
        }

        var paramListData:Array = e.data as Array;
        var playType:int = paramListData[paramListData.length - 1] as int;
        var findPeakGameData:CPeakGameData = data;

        switch (e.type) {
            case CPeakGameEvent.NET_EVENT_DATA :
            case CPeakGameEvent.NET_EVENT_UPDATE_DATA :
                var peakData:Object = e.data[0] as Object;
                var oldID:int = findPeakGameData.scoreLevelID;
                var oldMatchState:int = findPeakGameData.matchState;
                if (CPeakGameEvent.NET_EVENT_DATA == e.type) {
                    // 初始化数据
                    findPeakGameData.initialData(peakData);
                } else {
                    // 更新数据
                    findPeakGameData.updateDataByData(peakData);

                    // check match stage // 匹配状态  0空闲 1匹配中 2匹配成功
                    var newMatchState:int = findPeakGameData.matchState;
                    if (oldMatchState != newMatchState) {
                        _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_MATCHING, null, [playType]));
                    }
                }

                // check levelUp
                var newID:int = findPeakGameData.scoreLevelID;
                if (oldID != newID && oldID > 0) {
                    // change
                    var oldRecord:PeakScoreLevel = findPeakGameData.getLevelRecordByID(oldID);
                    var newRecord:PeakScoreLevel = findPeakGameData.getLevelRecordByID(newID);
                    var isLevelUp:Boolean = false;
                    if (newRecord.levelId > oldRecord.levelId) {
                        isLevelUp = true;
                    } else if (newRecord.levelId == oldRecord.levelId && newRecord.subLevelId > oldRecord.subLevelId) {
                        isLevelUp = true;
                    }
                    _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.DATA_LEVEL_CHANGE, [isLevelUp, oldRecord, newRecord]));
                    if (findPeakGameData.isMaxLevel) {
                        findPeakGameData.rankDataMulti.sync();
                        _system.netHandler.sendGetRank(EPeakGameRankType.TYPE_MULTI_SERVER, playType);
                    }
                }
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.DATA, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_MATCHING :
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.MATCHING, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_MATCH_DATA :
                var matchData:Object = e.data[0] as Object;
                findPeakGameData.updateMatchData(matchData);
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.MATCH_DATA, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_HONOUR_DATA :
                var honourData:Array = e.data[0] as Array;
                findPeakGameData.updateGloryData(honourData);
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.HONOUR, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_REPORT_DATA :
                var reportData:Array = e.data[0] as Array;
                findPeakGameData.updateReportData(reportData);
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.REPORT, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_RANK_DATA :
                var rankData:Object = e.data[0] as Object;
                findPeakGameData.updateRankData(rankData);
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.RANK, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_LOADING_DATA :
                var loadingData:int = e.data[0] as int;
                findPeakGameData.updateLoadingData({enemyProgress:loadingData});
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.LOADING, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_ENTER_ERROR :
                _system.sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.ENTER_ERROR, findPeakGameData));
                break;
            case CPeakGameEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH :
                findPeakGameData.isServerData = false;
                break;

        }

    }

    [Inline]
    public function get data() : CPeakGameData {
        return _peakGameFairData;
    }
    [Inline]
    private function get _system() : CPeakGameSystem {
        return system as CPeakGameSystem;
    }
    private var _peakGameFairData:CPeakGameData;
}
}
