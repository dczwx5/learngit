//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data {

import QFLib.Foundation.CTime;

import flash.utils.getTimer;

import kof.data.CObjectData;
import kof.framework.IDatabase;
import kof.game.common.loading.CProgressData;
import kof.game.streetFighter.data.match.CStreetFighterLoadingData;
import kof.game.streetFighter.data.match.CStreetFighterMatchData;
import kof.game.streetFighter.data.rank.CStreetFighterRankData;
import kof.game.streetFighter.data.report.CStreetFighterReportListData;
import kof.game.streetFighter.data.settlement.CStreetFighterSettlementData;

public class CStreetFighterData extends CObjectData {
    public function CStreetFighterData( database:IDatabase) {
        setToRootData(database);

        this.addChild(CStreetFighterReportListData);
        this.addChild(CStreetFighterRankData);
        this.addChild(CStreetFighterMatchData);
        this.addChild(CProgressData);
        this.addChild(CStreetFighterSettlementData);

        this.addChild(CStreetFighterEnterHeroListData);
        this.addChild(CStreetFighterHeroHpListData);
        this.addChild(CStreetFighterLoadingData);

        this.addChild(CStreetFighterRewardData);


    }
    // ===========================data
    public function initialData(data:Object) : void {
        isServerData = true;
        enterHeroListData.clearAll();
        updateDataByData(data);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

        if (data.hasOwnProperty("heroStates")) {
            myHeroHpList.updateDataByData(data["heroStates"]);
        }
        if (data.hasOwnProperty("challengerList")) {
            enterHeroListData.updateDataByData(data["challengerList"]);
        }
        rewardData.updateDataByData(data);
    }
    public function resetEnterRoom() : void {
        enterHeroListData.clearAll();
    }
    // ===========================reportData
    public function updateReportData(fightReportDatas:Object, fightData:Object) : void {
        reportData.isServerData = true;
        reportData.resetChild();
        reportData.updateDataByData({fightReportDatas:fightReportDatas, fightData:fightData});
    }
    // ===========================rankData
    public function updateRankData(data:Object) : void {
        rankData.clearAll();
        rankData.updateDataByData(data);
        if (rankData.hasData()) {
            rankData.isServerData = true; // 排行榜可能会没数据
        }
    }
    // ===========================matchData
    public function updateMatchData(data:Object) : void {
        progressData.clearData();
        matchData.isServerData = true;
        matchData.updateDataByData(data);

        reportData.resetSync(); // 新战斗之后才会重置战报的sync
    }
    public function updateEnemySelectHero(data:Object) : void {
        _enemySelectHeroID = data as int;
        _isEnemySelectHeroReady = true;
    }
    // 开始匹配, 重置一些状态
    public function resetTempData() : void {
        _enemySelectHeroID = 0;
        _isEnemySelectHeroReady = false;
        _isAllSelectHeroOpened = false;
        _countDownStartTime = -1;
    }
    // ===========================loadingData
    public function updateProgressData(data:Object) : void {
        progressData.isServerData = true;
        progressData.updateDataByData(data);
    }
    // ===========================resultData
    public function updateSettlementData(data:Object) : void {
        settlementData.isServerData = true;
        settlementData.updateDataByData(data);
    }
    public function updateLoadingData(data:Object) : void {
        loadingData.isServerData = true;
        loadingData.updateDataByData(data);
    }

    // ============================================================================================================================
    public function get isActivityTime() : Boolean {
        var startTime:Number = this.startTime;
        var endTime:Number = this.endTime;
        var iClientTime:Number = CTime.getCurrServerTimestamp();
        // return startTime <= iClientTime && endTime >= iClientTime;
        return startTime <= iClientTime && pauseTime >= iClientTime || restartTime <= iClientTime && endTime >= iClientTime;
    }

    public function getStartTime() : Number {
        var startTime:Number = this.startTime;
        var endTime:Number = this.endTime;

        var iClientTime:Number = CTime.getCurrServerTimestamp();
        if (iClientTime > pauseTime && iClientTime < restartTime) {
            // 中间时间
            return restartTime;
        } else if (restartTime <= iClientTime && endTime >= iClientTime) {
            return restartTime;
        } else {
            // 其他按第一时间段处理
            return startTime;
        }
    }

    public function getEndTime() : Number {
        var iClientTime:Number = CTime.getCurrServerTimestamp();
        if (iClientTime > pauseTime && iClientTime < restartTime) {
            // 中间时间
            return endTime;
        } else if (restartTime <= iClientTime && endTime >= iClientTime) {
            return endTime;
        } else {
            // 其他按第一时间段处理
            return pauseTime;
        }
    }



    [Inline]
    public function get startTime() : Number { return _data["startTime"]; } //活动开始时间 开始1
    public function get pauseTime() : Number { return _data["pauseTime"]; } // 暂停时间 结束1

    public function get restartTime() : Number { return _data["restartTime"]; } // 重启时间 开始2
    [Inline]
    public function get endTime() : Number { return _data["endTime"]; } //活动结束时间 结束2
    [Inline]
    public function get settlementTime() : Number { return _data["settlementTime"]; } //活动结算时间, 大概是endtTIME+3分钟
    [Inline]
    public function get alwaysWin() : int { return _data["alwaysWin"]; } //当前连胜
    [Inline]
    public function get historyHighAlwaysWin() : int { return _data["historyHighAlwaysWin"]; } //历史最高连胜
    [Inline]
    public function get score() : int { return _data["score"]; } //当前积分
    [Inline]
    public function get historyHighScore() : int { return _data["historyHighScore"]; } //历史最高积分
    [Inline]
    public function get fightCount() : int { return _data["fightCount"]; } //参加次数
    [Inline]
    public function get winCount() : int { return _data["winCount"]; } //胜利次数
    [Inline]
    public function get alreadyStartFight() : Boolean { return _data["alreadyStartFight"]; }// 是否已经开始战斗

    public function getCurValueByType(type:int) : int {
        if (type == CStreetFighterRewardData.TYPE_FIGHT_COUNT) {
            return fightCount;
        } else if (type == CStreetFighterRewardData.TYPE_WIN_COUNT) {
            return winCount;
        } else if (type == CStreetFighterRewardData.TYPE_ALWAYS_WIN_COUNT) {
            return historyHighAlwaysWin;
        } else if (type == CStreetFighterRewardData.TYPE_SCORE) {
            return historyHighScore;
        }
        return 0;
    }

    // heroStates
    // optional int32 profession		格斗家表ID
    // optional int32 HP				生命值
    [Inline]
    public function get heroStates() : Array { return _data["heroStates"]; } //所有格斗家血量数据（全量更新, 因为最多只有5个格斗家有数据）

    [Inline]
    public function get challengeCount() : int { return _data["challengeCount"]; } //挑战人数
    // challengerList
    // {
    // optional int64 roleID             角色ID
    // optional int32 headIcon		     角色头像
    // optional string name              战队名
    // optional int level                角色等级
    // optional int64 time               进场时间
    // }
    [Inline]
    public function get challengerList() : Array { return _data["challengerList"]; } //进场人列表（最多5条数据）(增量更新，重置时候通过StreetFighterEnterResetResponse去重置)

    [Inline]
    public function get matchState() : int { return _data["matchState"]; } // 匹配状态  0空闲 1匹配中 2匹配成功
    [Inline]
    public function get isMatching() : Boolean { return matchState == 1; }
    public function get isIdle() : Boolean {
        return 0 == matchState;
    }

    // ===========================otherData==========================================
    // ===========================reportData
    // 战报数据
    [Inline]
    public function get reportData() : CStreetFighterReportListData {
        return getChild(0) as CStreetFighterReportListData;
    }
    // ===========================rankData
    // 排行榜数据
    [Inline]
    public function get rankData() : CStreetFighterRankData {
        return getChild(1) as CStreetFighterRankData;
    }

    // ===========================MatchData
    // 匹配对的对手的暂存数据
    [Inline]
    public function get matchData() : CStreetFighterMatchData {
        return getChild(2) as CStreetFighterMatchData;
    }
    // ===========================loadingData
    // 对手loading数据
    [Inline]
    public function get progressData() : CProgressData {
        return getChild(3) as CProgressData;
    }
    // ===========================resultData
    // 整场结算数据
    [Inline]
    public function get settlementData() : CStreetFighterSettlementData {
        return getChild(4) as CStreetFighterSettlementData;
    }
    [Inline]
    public function get enterHeroListData() : CStreetFighterEnterHeroListData {
        return getChild(5) as CStreetFighterEnterHeroListData;
    }
    [Inline]
    public function get myHeroHpList() : CStreetFighterHeroHpListData {
        return getChild(6) as CStreetFighterHeroHpListData;
    }
    [Inline]
    public function get loadingData() : CStreetFighterLoadingData {
        return getChild(7) as CStreetFighterLoadingData;
    }

    [Inline]
    public function get rewardData() : CStreetFighterRewardData {
        return getChild(8) as CStreetFighterRewardData;
    }

    public function get countDownStartTime() : int {
        return _countDownStartTime;
    }
    public function get isAllSelectHeroOpened() : Boolean {
        return _isAllSelectHeroOpened;
    }
    public function set isAllSelectHeroOpened(v:Boolean) : void {
        _isAllSelectHeroOpened = v;
        _countDownStartTime = getTimer();
    }
    private var _isAllSelectHeroOpened:Boolean = false; // 两边的人物选择界面是否都加载好了
    public function get enemySelectHeroID() : int {
        return _enemySelectHeroID;
    }
    public function set enemySelectHeroID(v:int) : void {
        _enemySelectHeroID = v;
    }
    public function get mySelectHeroID() : int {
    return _mySelectHeroID;
}
    public function set mySelectHeroID(v:int) : void {
        _mySelectHeroID = v;
    }
    public function get isEnemySelectHeroReady() : Boolean {
        return _isEnemySelectHeroReady;
    }
    public var _playerUID:int;
    private var _enemySelectHeroID:int;
    private var _mySelectHeroID:int;
    private var _isEnemySelectHeroReady:Boolean;
    private var _countDownStartTime:int;

    public var myProgress:int; // 自己的进度
}
}
