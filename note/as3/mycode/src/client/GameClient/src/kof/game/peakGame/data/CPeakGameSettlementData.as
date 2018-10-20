//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.game.item.data.CRewardListData;

public class CPeakGameSettlementData extends CObjectData {
    public function CPeakGameSettlementData() {
        this.addChild(CRewardListData); // 自己的
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }


    // self
    [Inline]
    public function get result() : int { return _data["result"]; } // 结果 : 0 : 失败, 1 : 成功, 2 : 战平, 3 : 完胜
    [Inline]
    public function get scoreLevelID() : int { return _data["scoreLevelID"]; }
    [Inline]
    public function get updateScore() : int { return _data["updateScore"]; }
    [Inline]
    public function get rewards() : Object { return _data["rewards"]; }
    [Inline]
    public function get noDamageToWin() : Boolean { return _data["noDamageToWin"]; } // 无伤
    [Inline]
    public function get fullWin() : Boolean { return _data["fullWin"]; } // 完胜
    [Inline]
    public function get comboHitMan() : Boolean { return _data["comboHitMan"]; } // 连击达人
    // enemy
    [Inline]
    public function get enemyScoreLevelID() : int { return _data["enemyScoreLevelID"]; }
    [Inline]
    public function get enemyUpdateScore() : int { return _data["enemyUpdateScore"]; }
    [Inline]
    public function get enemyRewards() : Object { return _data["enemyRewards"]; }
    [Inline]
    public function get enemyName() : String { return _data["enemyName"]; }

    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id

    public function get scoreActivityStart() : int { return _data["scoreActivityStart"]; } // 活动是否开启
    public function get scoreActivityBaseMultiple() : int { return _data["scoreActivityBaseMultiple"]; } // 倍数
}
}
