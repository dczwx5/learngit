//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/1.
 */
package kof.game.peak1v1.data {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.Peak1v1Constant;
import kof.table.Peak1v1Reward;

public class CPeak1v1RewardDataUtil {
    public function CPeak1v1RewardDataUtil(databaseSystem:IDatabase) {
        _databaseSystem = databaseSystem;

        initial();
    }

    public function initial() : void {

        // 四种奖励
        _rewardMap = new CMap();
        var pRewardTable:IDataTable = rewardTable;
        var rewardList:Vector.<Object> = pRewardTable.toVector();
        _rewardMap.add(TYPE_REWARD_DAMAGE, new Array());
        _rewardMap.add(TYPE_REWARD_JOIN, new Array());
        _rewardMap.add(TYPE_REWARD_WIN, new Array());
        _rewardMap.add(TYPE_REWARD_SCORE_RANK, new Array());

        var rewardRecord:Peak1v1Reward;
        var rewardRecordData:CPeak1v1RewardRecordData;
        for (var i:int = 0; i < rewardList.length; i++) {
            rewardRecord = rewardList[i] as Peak1v1Reward;

            rewardRecordData = new CPeak1v1RewardRecordData();
            rewardRecordData.ID = rewardRecord.ID;
            rewardRecordData.reward = rewardRecord.reward;
            rewardRecordData.type = rewardRecord.type;
            rewardRecordData.startValue = rewardRecord.param[0];
            rewardRecordData.endValue = rewardRecord.param[1];

            getRewardListByType(rewardRecord.type).push(rewardRecordData);
        }

        getRewardListByType(TYPE_REWARD_DAMAGE).sortOn(CPeak1v1RewardRecordData.SORT_FLAG, Array.NUMERIC);
        getRewardListByType(TYPE_REWARD_JOIN).sortOn(CPeak1v1RewardRecordData.SORT_FLAG, Array.NUMERIC);
        getRewardListByType(TYPE_REWARD_WIN).sortOn(CPeak1v1RewardRecordData.SORT_FLAG, Array.NUMERIC);
        getRewardListByType(TYPE_REWARD_SCORE_RANK).sortOn(CPeak1v1RewardRecordData.SORT_FLAG, Array.NUMERIC);

        // 单局奖励
        _winReward = constantRecord.winReward;
        _loseReward = constantRecord.loseReward;
        _tieReward = constantRecord.drawReward;
    }

    public function getRewardListByType(type:int) : Array {
        return _rewardMap[type];
    }
    public function get damageRewardList() : Array {
        return _rewardMap[TYPE_REWARD_DAMAGE];
    }

    public function get joinRewardList() : Array {
        return _rewardMap[TYPE_REWARD_JOIN];
    }

    public function get winRewardList() : Array {
        return _rewardMap[TYPE_REWARD_WIN];
    }

    public function get scoreRankRewardList() : Array {
        return _rewardMap[TYPE_REWARD_SCORE_RANK];
    }

    public function get rewardTable() : IDataTable {
        if (_rewardTable == null) {
            _rewardTable = _databaseSystem.getTable(KOFTableConstants.Peak1v1Reward);
        }
        return _rewardTable;
    }

    public function get constantRecord() : Peak1v1Constant {
        if (!_constantRecord) {
            var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.Peak1v1Constant);
            _constantRecord = table.first();
        }
        return _constantRecord;
    }

    public function get winReward():int {
        return _winReward;
    }

    public function get loseReward():int {
        return _loseReward;
    }
    public function get tieReward():int {
        return _tieReward;
    }
    private var _rewardTable:IDataTable;
    private var _constantRecord:Peak1v1Constant;

    //    1-伤害累计奖励，参数1是伤害值
    //    2-累计参加次数奖励，参数1是累计参加次数
    //    3-累计胜利次数奖励，参数1是累计胜利次数
    //    4-积分排行奖励，参数1是靠前名次，参数2是靠后名次
    private var _rewardMap:CMap;

    // 单局奖励
    private var _winReward:int;
    private var _loseReward:int;
    private var _tieReward:int;

    private var _databaseSystem:IDatabase;

    public static const TYPE_REWARD_DAMAGE:int = 1;
    public static const TYPE_REWARD_JOIN:int = 2;
    public static const TYPE_REWARD_WIN:int = 3;
    public static const TYPE_REWARD_SCORE_RANK:int = 4;
}
}
