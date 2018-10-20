//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data {


import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.table.StreetFighterReward;

public class CStreetFighterRewardData extends CObjectData {
    public function CStreetFighterRewardData() {
    }

    public override function updateDataByData(data:Object) : void {
        // 使用父级数据

    }
    [Inline]
    public function get fightCountRewardIDs() : Array { return _rootData.data["fightCountRewardIDs"]; } //已领取参加次数奖励（街头争霸奖励配置表ID）（全量更新）
    [Inline]
    public function get winCountRewardIDs() : Array { return _rootData.data["winCountRewardIDs"]; } //已领取胜利次数奖励（街头争霸奖励配置表ID）（全量更新）
    [Inline]
    public function get historyHighAlwaysWinRewardIDs() : Array { return _rootData.data["historyHighAlwaysWinRewardIDs"]; } //已领取最高连胜次数奖励（街头争霸奖励配置表ID）（全量更新）
    [Inline]
    public function get historyHighScoreRewardIDs() : Array { return _rootData.data["historyHighScoreRewardIDs"]; } //已领取最高积分奖励（街头争霸奖励配置表ID）（全量更新）

    public function getRewardRecord(ID:int) : StreetFighterReward {
        var ret:StreetFighterReward = rewardTable.findByPrimaryKey(ID);
        return ret;
    }
    public function hasRewarded( ID:int) : Boolean {
        // 数据小
        var index:int = fightCountRewardIDs.indexOf(ID);
        if (index != -1) {
            return true;
        }
        index = winCountRewardIDs.indexOf(ID);
        if (index != -1) {
            return true;
        }
        index = historyHighAlwaysWinRewardIDs.indexOf(ID);
        if (index != -1) {
            return true;
        }
        index = historyHighScoreRewardIDs.indexOf(ID);
        if (index != -1) {
            return true;
        }
        return false;
    }

    public function getRewardRecordListByType(typeList:Array) : Array {
        if (!typeList || typeList.length == 0) {
            return null;
        }

        var ret:Array = new Array();
        var findList:Array;
        for (var i:int = 0; i < typeList.length; i++) {
            var type:int = typeList[i] as int;
            findList = rewardTable.findByProperty("type", type);
            ret = ret.concat(findList);
        }
        return ret;
    }

    public function get rewardTable() : IDataTable {
        if (_pTable == null) {
            _pTable = _databaseSystem.getTable(KOFTableConstants.STREET_FIGHTER_REWARD);
        }
        return _pTable;
    }
    private var _pTable:IDataTable;

    public static const TYPE_FIGHT_COUNT:int = 1;
    public static const TYPE_WIN_COUNT:int = 2;
    public static const TYPE_ALWAYS_WIN_COUNT:int = 3;
    public static const TYPE_SCORE:int = 4;
    public static const TYPE_SCORE_RANK_COUNT:int = 5;

}
}
