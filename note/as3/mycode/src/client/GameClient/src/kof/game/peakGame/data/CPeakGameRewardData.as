//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/23.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.game.peakGame.enum.EPeakGameRewardType;
import kof.table.PeakReward;

public class CPeakGameRewardData extends CObjectData {
    public function CPeakGameRewardData() {
    }

    public override function updateDataByData(data:Object) : void {
        _initialRecordListB();

        // daily
        if (beatHeroRewardIDs) {
            updateTaskData(_dailyDataList, beatHeroRewardIDs, dayBeatHeroCount);
        }

        // week
        if (weekWinRewardIDs) {
            updateTaskData(_weekWinDataList, weekWinRewardIDs, weekWinCount);
        }

    }
    private function updateTaskData(taskList:Array, dataList:Array, value:int) : void {
        var task:CPeakGameRewardTaskData;
        for each (task in taskList) {
            task.setUnReady();
            task.value = value;
            if (dataList.indexOf(task.record.ID) != -1) {
                task.setReward();
            } else {
                // not reward, checkState
                if (task.value >= task.target) {
                    task.setCanReward();
                }
            }
        }
    }

    public function get isDailyCanReward() : Boolean {
        var task:CPeakGameRewardTaskData;
        for each (task in _dailyDataList) {
            if (task.isCanReward) {
                return true;
            }
        }
        return false;
    }
    public function get isWeekCanReward() : Boolean {
        var task:CPeakGameRewardTaskData;
        for each (task in _weekWinDataList) {
            if (task.isCanReward) {
                return true;
            }
        }
        return false;
    }
    // ========================initial===============================
    private function _initialRecordListB() : void {
        var peakData:CPeakGameData;

        if (_dailyDataList == null || _weekWinDataList == null || _weekRankDataList == null || _seasonRankDataList == null || _seasonLevelDataList == null) {
            peakData = _rootData as CPeakGameData;
            var allList:Array = _databaseSystem.getTable(peakData.rewardTableName).toArray();
            if (_dailyDataList == null) {
                _dailyDataList = _getDataListC(allList, EPeakGameRewardType.TYPE_DAILY);
                _sortDailyRecord();
            }
            if (_weekWinDataList == null) {
                _weekWinDataList = _getDataListC(allList, EPeakGameRewardType.TYPE_WEEK_WIN_COUNT);
                _sortWeekWinRecord();
            }
            if (_weekRankDataList == null) {
                _weekRankDataList = _getDataListC(allList, EPeakGameRewardType.TYPE_WEEK_RANK);
                _sortWeekRankRecord();
            }
            if (_seasonRankDataList == null) {
                _seasonRankDataList = _getDataListC(allList, EPeakGameRewardType.TYPE_SEASON_RANK);
                _sortSeasonRankRecord();
            }
            if (_seasonLevelDataList == null) {
                peakData = _rootData as CPeakGameData;
                var levelList:Array = _databaseSystem.getTable(peakData.levelTableName).toArray();
                levelList.sortOn("scoreBottomLimit", Array.NUMERIC | Array.DESCENDING);
                _seasonLevelDataList = levelList;
            }
        }
    }
    private function _getDataListC(allRecordList:Array, type:int) : Array {
        var dataList:Array = new Array();
        var recordList:Array = allRecordList.filter(function (item:Object, idx:int, arr:Array) : Boolean {
            return (int)((item as PeakReward).type) == type
        });
        var task:CPeakGameRewardTaskData;
        var record:PeakReward;
        for each (record in recordList) {
            task = new CPeakGameRewardTaskData();
            task.record = record;
            dataList[dataList.length] = task;
        }
        return dataList;
    }
    private function _sortDailyRecord() : void {
        _dailyDataList.sort(function (data1:CPeakGameRewardTaskData, data2:CPeakGameRewardTaskData) : int {
            return data1.record.param[0] - data2.record.param[0];
        });
    }
    private function _sortWeekWinRecord() : void {
        _weekWinDataList.sort(function (data1:CPeakGameRewardTaskData, data2:CPeakGameRewardTaskData) : int {
            return data1.record.param[0] - data2.record.param[0];
        });
    }
    private function _sortWeekRankRecord() : void {
        _weekRankDataList.sort(function (data1:CPeakGameRewardTaskData, data2:CPeakGameRewardTaskData) : int {
            return data1.record.param[0] - data2.record.param[0];
        });
    }
    private function _sortSeasonRankRecord() : void {
        _seasonRankDataList.sort(function (data1:CPeakGameRewardTaskData, data2:CPeakGameRewardTaskData) : int {
            return data1.record.param[0] - data2.record.param[0];
        });
    }

    // =============================get/set======================================
    public function getFirstDailyUnFinishTaskData() : CPeakGameRewardTaskData {
        return _getFirstUnFinishTaskData(_dailyDataList);
    }
    public function getFirstWeekWinUnFinishTaskData() : CPeakGameRewardTaskData {
        return _getFirstUnFinishTaskData(_weekWinDataList);
    }

    private function _getFirstUnFinishTaskData(dataList:Array) : CPeakGameRewardTaskData {
        var task:CPeakGameRewardTaskData;
        for (var i:int = 0; i < dataList.length; i++) {
            task = dataList[i];
            if (task.isUnReady || task.isCanReward) {
                return task;
            }
        }
        return null;
    }
    public function getDailyItemByID(ID:int) : CPeakGameRewardTaskData {
        return getItem(_dailyDataList, ID);
    }
    private function getItem(dataList:Array, ID:int) : CPeakGameRewardTaskData {
        for each (var item:CPeakGameRewardTaskData in dataList) {
            if (item.record.ID == ID) return item;
        }
        return null;
    }
    public function get dailyDataList() : Array {
        return _dailyDataList;
    }
    public function get weekWinDataList() : Array {
        return _weekWinDataList;
    }

    public function get weekRankDataList() : Array {
        return _weekRankDataList;
    }
    public function get seasonRankDataList() : Array {
        return _seasonRankDataList;
    }
    public function get seasonLevelDataList() : Array {
        return _seasonLevelDataList;
    }

    [Inline]
    public function get weekWinCount() : int { return _rootData.data["weekWinCount"]; } // 每周胜利场数量
    [Inline]
    public function get dayBeatHeroCount() : int { return _rootData.data["dayBeatHeroCount"]; } // 当天击败格斗家数量
    [Inline]
    public function get beatHeroRewardIDs() : Array { return _rootData.data["beatHeroRewardIDs"]; } // 已领取每日击败格斗家奖励列表（巅峰赛奖励配置表ID）
    [Inline]
    public function get weekWinRewardIDs() : Array { return _rootData.data["weekWinRewardIDs"]; } // 已领取每周胜利场奖励列表（巅峰赛奖励配置表ID）


    // 奖励是否领取
    public function isRewardGet(rewardID:int) : Boolean {
        var index:int = beatHeroRewardIDs.indexOf(rewardID);
        if (index != -1) return true;
        index = weekWinRewardIDs.indexOf(rewardID);
        if (index != -1) return true;
        return false;
    }

    private var _dailyDataList:Array;
    private var _weekWinDataList:Array;
    private var _weekRankDataList:Array;
    private var _seasonRankDataList:Array;

    private var _seasonLevelDataList:Array;

}
}
