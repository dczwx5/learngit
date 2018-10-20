//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.data {

import flash.utils.getTimer;

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.loading.CMatchData;
import kof.game.common.loading.CProgressData;
import kof.game.im.data.CIMFriendsData;
import kof.game.peakGame.data.CPeakGameSettlementData;
import kof.table.PeakScoreLevel;

public class CPeakpkData extends CObjectData {

    public function CPeakpkData( database:IDatabase) {
        setToRootData(database);
        this.addChild(CMatchData);
        this.addChild(CProgressData);
        this.addChild(CPeakGameSettlementData);
        this.addChild(CPeakpkInviterData);
    }

    public function initialData(data:Object) : void {
        isServerData = true;
        super.updateDataByData(data);
    }
    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }

    public function updateResultData(data:Object) : void {
        resultData.updateDataByData(data);
    }
    public function updateMatchData(data:Object) : void {
        matchData.updateDataByData(data);
    }
    public function updateLoadingData(data:Object) : void {
        loadingData.isServerData = true;
        loadingData.updateDataByData(data);
    }
    public function updateInviterData(data:Object) : void {
        inviterData.updateDataByData(data);
    }
    ////////////////////////////////////////////////////////
    public function get scoreLevelTable() : IDataTable {
        if (!_scoreLevelTable) {
            _scoreLevelTable = _databaseSystem.getTable(KOFTableConstants.FAIR_PEAK_GAME_LEVEL)
        }
        return _scoreLevelTable;
    }
    public function get scoreLevelDataList() : Vector.<Object> {
        if (!_pScoreLevelDataList) {
            _pScoreLevelDataList = scoreLevelTable.toVector();
        }
        return _pScoreLevelDataList;
    }
    public function getLevelRecordByID(ID:int) : PeakScoreLevel {
        return scoreLevelTable.findByPrimaryKey(ID);
    }
    ////////////////////////////////////////////////////////////////
    public function get matchData() : CMatchData { return this.getChild(0) as CMatchData; }
    [Inline]
    public function get loadingData() : CProgressData {
        return getChild(1) as CProgressData;
    }
    public function get resultData() : CPeakGameSettlementData { return this.getChild(2) as CPeakGameSettlementData; }
    public function get inviterData() : CPeakpkInviterData { return this.getChild(3) as CPeakpkInviterData; }

    ////////////////////////////////////////////
    private var _scoreLevelTable:IDataTable;
    private var _pScoreLevelDataList:Vector.<Object>;
    public var pFriendList:Array; // 好友列表

    public var lastSendInviteData:CIMFriendsData;

    private var _lastSyncTime:int;
    public override function sync() : void {
        _lastSyncTime = getTimer();
    }
    public override function get needSync() : Boolean {
        if (_lastSyncTime == 0) return true;
        return getTimer() - _lastSyncTime > 1000; // 10分钟 60000
    }
}
}
