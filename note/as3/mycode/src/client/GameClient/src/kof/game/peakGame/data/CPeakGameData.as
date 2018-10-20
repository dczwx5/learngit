//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CLang;
import kof.game.common.CTest;
import kof.game.common.loading.CProgressData;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.FairPeakConstant;
import kof.table.PeakConstant;
import kof.table.PeakScoreLevel;

public class CPeakGameData extends CObjectData {
    public static const MAX_LEVEL:int = 7;
    public static const MAX_SUB_LEVEL:int = 3;
    public function CPeakGameData(database:IDatabase, playType:int, levelTableName:String, rewardTableName:String, constantTableName:String) {
        setToRootData(database);

        _sLevelTableName = levelTableName;
        _sRewardTableName = rewardTableName;
        _sConstantTableName = constantTableName;

        _iPlayType = playType;
        this.addChild(CPeakGameReportListData);
        this.addChild(CPeakGameRankData);
        this.addChild(CPeakGameRankData);
        this.addChild(CPeakGameMatchData);
        this.addChild(CProgressData);
        this.addChild(CPeakGameSettlementData);

        this.addChild(CPeakGameRewardData);

        this.addChild(CPeakGameGloryListData);

        // 新赛季奖励,
//        this.addChild(CRewardListData);
//        this.addChild(CRewardListData);
    }
    // ===========================data
    public function initialData(data:Object) : void {
        isServerData = true;
        updateDataByData(data);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty("score")) {
            rankDataMulti.setPlayerScore(_playerUID, data["score"]);
            rankDataOne.setPlayerScore(_playerUID, data["score"]);
        }
        if (!seasonComingFlag) {
            lastRanking = 0;
            lastScoreLevelID = 0;
            lastRankRewards = null;
            lastLevelRewards = null;
//            lastRankRewardData.resetChild();
//            lastLevelRewardData.resetChild();
        } else {
//            lastRankRewardData.updateDataByData(this.lastRankRewards);
//            lastLevelRewardData.updateDataByData(this.lastLevelRewards);
        }

        rewardData.updateDataByData(data);
    }
    // ===========================reportData
    public function updateReportData(data:Object) : void {
        reportData.isServerData = true;
        reportData.resetChild();
        reportData.updateDataByData(data);
    }
    // ===========================rankData
    public function updateRankData(data:Object) : void {
        if (data.hasOwnProperty(CPeakGameRankData._type)) {
            if (data[CPeakGameRankData._type] == CPeakGameRankData.TYPE_ONE) {
                //_lastRequireRank = rankDataOne;
                rankDataOne.updateDataByData(data);
                if (rankDataOne.hasData()) {
                    rankDataOne.isServerData = true; // 排行榜可能会没数据
                }
            } else {
                //_lastRequireRank = rankDataMulti;
                rankDataMulti.updateDataByData(data);
                if (rankDataMulti.hasData()) {
                    rankDataMulti.isServerData = true;
                }
            }
        }
    }
    // ===========================matchData
    public function updateMatchData(data:Object) : void {
        loadingData.clearData();
        matchData.isServerData = true;
        matchData.updateDataByData(data);

        reportData.resetSync(); // 新战斗之后才会重置战报的sync
    }
    // ===========================loadingData
    public function updateLoadingData(data:Object) : void {
        loadingData.isServerData = true;
        loadingData.updateDataByData(data);
    }
    // ===========================resultData
    public function updateSettlementData(data:Object) : void {
        settlementData.isServerData = true;
        settlementData.updateDataByData(data);
    }
    // ===========================gloryData
    public function updateGloryData(data:Object) : void {
        gloryData.isServerData = true;
        gloryData.updateDataByData(data);
    }


    // peakGame data base
    [Inline]
    public function get scoreLevelID() : int { return _data["scoreLevelID"]; } // 积分段位表ID - 非段位ID，非阶位ID
    [Inline]
    public function get score() : int { return _data["score"]; } // 当前积分
    [Inline]
    public function get fightCount() : int { return _data["fightCount"]; } // 出战次数
    public function get dayFightCount() : int { return _data["dayFightCount"]; } // 当天出战次数

    public function get scoreActivityStart() : int { return _data["scoreActivityStart"]; } // 活动是否开启
    public function get scoreActivityBaseMultiple() : int { return _data["scoreActivityBaseMultiple"]; } // 倍数

    [Inline]
    public function get winCount() : int { return _data["winCount"]; } // 胜场次数
    [Inline]
    public function get weekWinCount() : int { return _data["weekWinCount"]; } // 每周胜利场数量
    [Inline]
    public function get matchState() : int { return _data["matchState"]; } // 匹配状态  0空闲 1匹配中 2匹配成功
    [Inline]
    public function get predictMatchTime() : int { return _data["predictMatchTime"]; } // 预计匹配时间
    [Inline]
    public function get seasonStartTime() : Number { return _data["seasonStartTime"]; } // 赛季开始时间
    public function get seasonOverTime() : Number { return _data["seasonOverTime"]; } // 赛季结束时间
    public function get firstAutoEmbattle() : Boolean { return _data["firstAutoEmbattle"]; } // 是否已经第一次自动布阵 true 已自动布过一次阵； false 没有
    public function set firstAutoEmbattle(v:Boolean) : void { _data["firstAutoEmbattle"] = v; } // 是否已经第一次自动布阵 true 已自动布过一次阵； false 没有
    public function get isFirstOpenGloryHallFlag() : Boolean { return _data["isFirstOpenGloryHallFlag"]; } // 是否首次打开荣耀殿堂标志， true 已经打开过 ， flase 没有打开过'
    public function set isFirstOpenGloryHallFlag(v:Boolean) : void { _data["isFirstOpenGloryHallFlag"] = v; }

    public function get seasonComingFlag() : Boolean { return _data["seasonComingFlag"]; } // 赛季来袭flag: true显示赛季来袭界面， false不显示, 服务器请求之后, 会设成false

// 以下信息, 如果seasonComingFlag == false, 则服务器不会发
    public function get lastRanking() : int { return _data["lastRanking"]; } // 上赛季排名
    public function get lastScoreLevelID() : int { return _data["lastScoreLevelID"]; } // 上赛季积分段位表ID
    public function get lastRankRewards() : Array { return _data["lastRankRewards"]; } // 上赛季排名奖励
    public function get lastLevelRewards() : Array { return _data["lastLevelRewards"]; } // 上赛季段位奖励

    // 客户端自己设置下面的值
    public function set seasonComingFlag(v:Boolean) : void { _data["seasonComingFlag"] = v;
        if (!v) {
            lastRanking = 0;
            lastScoreLevelID = 0;
            lastRankRewards = null;
            lastLevelRewards = null;

        }
    } // 赛季来袭flag: true显示赛季来袭界面， false不显示, 服务器请求之后, 会设成false
    public function set lastRanking(v:int) : void { _data["lastRanking"] = v; } // 上赛季排名
    public function set lastScoreLevelID(v:int) : void { _data["lastScoreLevelID"] = v; } // 上赛季积分段位表ID
    public function set lastRankRewards(v:Array) : void { _data["lastRankRewards"] = v; } // 上赛季排名奖励
    public function set lastLevelRewards(v:Array) : void { _data["lastLevelRewards"] = v; } // 上赛季段位奖励

    // ==get/set
//    [Inline]
//    public function set isMatching(value:Boolean) : void { if (value) _data["matchState"] = 1; else _data["matchState"] = 0; }
    [Inline]
    public function get isMatching() : Boolean { return matchState == 1; }
    public function get isIdle() : Boolean {
        return 0 == matchState;
    }
    public function get winRate() : String {
        if (fightCount == 0) { return "0%"; }
        else { return  ((winCount/fightCount)*100).toFixed(0) + "%"; }
    }
    public function get levelName() : String {
        if (peakLevelRecord) return peakLevelRecord.levelName;
        return "";
    }
    public function get isMaxLevel() : Boolean {
        if (peakLevelRecord) {
            if (peakLevelRecord.levelId == MAX_LEVEL && peakLevelRecord.subLevelId == MAX_SUB_LEVEL) {
                return true;
            }
        }
        return false;
    }
    public function get peakLevelRecord() : PeakScoreLevel {
        if (_peakLevelRecord == null || _peakLevelRecord.ID != scoreLevelID) {
            _peakLevelRecord = peakLevelTable.findByPrimaryKey(scoreLevelID);
        }
        return _peakLevelRecord;
    }
    public function get peakLevelTable() : IDataTable {
        if (_peakLevelTable == null) {
            _peakLevelTable = _databaseSystem.getTable(levelTableName) as IDataTable;
        }
        return _peakLevelTable;
    }
    // 段位ID
    public function getLevelRecordByLevelID(levelID:int) : PeakScoreLevel {
        var list:Vector.<Object> = peakLevelTable.toVector();
        for each (var record:PeakScoreLevel in list) {
            if (record.levelId == levelID) return record;
        }
        return null;
    }
    // 段位+阶位ID
    public function getLevelRecordByLevelNSubID(levelID:int, subLevel:int) : PeakScoreLevel {
        var list:Vector.<Object> = peakLevelTable.toVector();
        for each (var record:PeakScoreLevel in list) {
            if (record.levelId == levelID && record.subLevelId == subLevel) return record;
        }
        return null;
    }
//    // 阶位ID, 即levelScoreID
//    public function getLevelRecordBySubID(subLevel:int) : PeakScoreLevel {
//        var levelID:int = subLevel/3;
//        subLevel = (subLevel-1) % 3 + 1;
//        return getLevelRecordByLevelNSubID(levelID, subLevel);
//    }
    public function getLevelRecordByID(ID:int) : PeakScoreLevel {
        return peakLevelTable.findByPrimaryKey(ID);
    }
    public function get rewardTable() : IDataTable {
        if (_rewardTable == null) {
            _rewardTable = _databaseSystem.getTable(rewardTableName);
        }
        return _rewardTable;
    }

    public function get peakConstantTableData():PeakConstant
    {
        if (_peakConstantTable == null)
        {
            _peakConstantTable = _databaseSystem.getTable(KOFTableConstants.PEAK_GAME_CONSTANT) as IDataTable;
        }

        return _peakConstantTable.findByPrimaryKey(1) as PeakConstant;
    }

    private var _peakLevelTable:IDataTable;
    private var _peakLevelRecord:PeakScoreLevel; // 段位表记录
    private var _rewardTable:IDataTable;
    private var _peakConstantTable:IDataTable;

    // ===========================otherData==========================================
    // ===========================reportData
    // 战报数据
    [Inline]
    public function get reportData() : CPeakGameReportListData {
        return getChild(0) as CPeakGameReportListData;
    }
    // ===========================rankData
    // 排行榜数据 本服
    [Inline]
    public function get rankDataOne() : CPeakGameRankData {
        return getChild(1) as CPeakGameRankData;
    }
//    public function get isLastRequireRankOne() : Boolean {
//        return _lastRequireRank == rankDataOne;
//    }
//    public function get lastRequireRank() : CPeakGameRankData {
//        return _lastRequireRank;
//    }
//    private var _lastRequireRank:CPeakGameRankData; // 最后一次
    // 排行榜数据 赛季
    [Inline]
    public function get rankDataMulti() : CPeakGameRankData {
        return getChild(2) as CPeakGameRankData;
    }
    // ===========================MatchData
    // 匹配对的对手的暂存数据
    [Inline]
    public function get matchData() : CPeakGameMatchData {
        return getChild(3) as CPeakGameMatchData;
    }
    // ===========================loadingData
    // 对手loading数据
    [Inline]
    public function get loadingData() : CProgressData {
        return getChild(4) as CProgressData;
    }
    // ===========================resultData
    // 整场结算数据
    [Inline]
    public function get settlementData() : CPeakGameSettlementData {
        return getChild(5) as CPeakGameSettlementData;
    }
    // ===========================rewardData
    // 整场结算数据
    [Inline]
    public function get rewardData() : CPeakGameRewardData {
        return getChild(6) as CPeakGameRewardData;
    }

// ===========================gloryData
    // 荣誉
    [Inline]
    public function get gloryData() : CPeakGameGloryListData {
        return getChild(7) as CPeakGameGloryListData;
    }

    // 货币
    public function get currency() : int {
        var playerData:CPlayerData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        if (EPeakGameWndType.PLAY_TYPE_NORMAL == _iPlayType) {
            return playerData.currency.honorCoin;
        } else {
            return playerData.currency.fairPeakCoin;
        }
    }
    public function get currencyName() : String {
        if (EPeakGameWndType.PLAY_TYPE_NORMAL == _iPlayType) {
            return CLang.Get("peak_currence_title");
        } else {
            return CLang.Get("fair_peak_currence_title");
        }
    }

    public static function findScoreLevelRecordByScore(scoreLevelDataList:Vector.<Object>, score:int) : PeakScoreLevel {
        var findScoreLevelRecord:PeakScoreLevel;
        for each (var scoreLevelRecored:PeakScoreLevel in scoreLevelDataList) {
            if (scoreLevelRecored.scoreTopLimit == -1) {
                if (score >= scoreLevelRecored.scoreBottomLimit) {
                    findScoreLevelRecord = scoreLevelRecored;
                }
            } else {
                if (score >= scoreLevelRecored.scoreBottomLimit && score <= scoreLevelRecored.scoreTopLimit) {
                    findScoreLevelRecord = scoreLevelRecored;
                }
            }
        }
        return findScoreLevelRecord;
    }

    [Inline]
    public function get playType():int {
        return _iPlayType;
    }
    private var _iPlayType:int;

    public function get levelTableName() : String {
        return _sLevelTableName;
    }
    public function get rewardTableName() : String {
        return _sRewardTableName;
    }
    public function get constantTableName() : String {
        return _sConstantTableName;
    }
    private var _sLevelTableName:String;
    private var _sRewardTableName:String;
    private var _sConstantTableName:String;

    public var _playerUID:int;
    public var lastNetDelay:int; // 最后一次延迟时间
}
}
