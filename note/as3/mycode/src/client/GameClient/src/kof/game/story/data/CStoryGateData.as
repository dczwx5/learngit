//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.data {


import kof.data.CObjectData;
import kof.table.HeroStoryGate;

public class CStoryGateData extends CObjectData {
    public function CStoryGateData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    [Inline]
    public function get heroID() : int { return _data[_heroID]; } // 格斗家ID
    [Inline]
    public function get gateIndex() : int { return _data[_gateIndex]; } // 第几关，从1开始  1-5
    [Inline]
    public function get passed() : Boolean { return _data["passed"]; } // 是否通关
//    [Inline]
//    public function get freeChallengeNum() : int { return _data[_freeChallengeNum]; } // 已打次数
//    [Inline]
//    public function get allBuyChallengeNum() : int { return _data["allBuyChallengeNum"]; } // 当天总购买挑战的次数
//    [Inline]
//    public function get hasBuyChallengeNum() : int { return _data[_hasBuyChallengeNum]; } // 拥有的购买的挑战次数
    [Inline]
    public function get challengeNum() : int { return _data[_challengeNum]; } // 当天已挑战的次数
    [Inline]
    public function get resetNum() : int { return _data[_resetNum]; } // 当天已重置的次数

    public function get leftCount() : int {
        var leftCount:int = (rootData as CStoryData).FREE_FIGHT_COUNT_DAILY - challengeNum;
        return leftCount;

    }

    [Inline]
    public function get gateID() : int { return _data[_gateID]; } // gate ID GateList表中的ID

    public static const _heroID:String = "heroID";
    public static const _gateIndex:String = "gateIndex";
    public static const _challengeNum:String = "challengeNum";
    public static const _resetNum:String = "resetNum";
    public static const _gateID:String = "gateID";

    public function get gateRecord() : HeroStoryGate {
        if (!_gateRecord) {
            _gateRecord = (rootData as CStoryData).gateTable.findByPrimaryKey(gateID);
        }
        return _gateRecord;
    }
    private var _gateRecord:HeroStoryGate;
}
}
