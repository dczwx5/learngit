//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/2.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectData;
import kof.game.item.data.CRewardListData;

// 副本通关奖励
public class CInstancePassRewardData extends CObjectData {
    public function CInstancePassRewardData() {
        this.addChild(CRewardListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        _reward.resetChild();
        if (data.hasOwnProperty("rewardList")) _reward.updateDataByData(data["rewardList"]);
    }

    public function get level() : int { return _data["level"]; }
    public function get star() : int {  return _data["star"];
    }
    public function get passTime() : int { return _data["passTime"]; } // 1 : 时间的星级条件满足, 0 : 时间的星级条件不满足

    [Inline]
    public function get isStar3Pass() : Boolean { return passTime == 1; } // 第3个星星是否是通过的
    public function isStarPassByIndex(idx:int) : Boolean {
        if (star == 0) {
            return false;
        } else if (star == 1) {
            if (idx == 0) {
                // 1星只有第一个亮
                return true;
            } else {
                return false;
            }
        } else if (star == 2) {
            if (idx == 0) {
                // 2星, 第一个肯定是亮
                return true;
            } else if (idx == 1) {
                // 2星, passTime如果是1, 则说明不通过的是死亡格斗家
                return !isStar3Pass;
            } else {
                // 2星, passTime如果是1, 则第三个亮
                return isStar3Pass;
            }
        } else if (star == 3) {
            return true;
        }

        return false;
    }

    public function get rewardList() : CRewardListData {
    return _reward;
}

    private function get _reward() : CRewardListData { return this.getChild(0) as CRewardListData; }


}
}
