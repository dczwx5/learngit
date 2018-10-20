//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/24.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;


public class CCultivateOtherData extends CObjectData {
    public function CCultivateOtherData() {
        this.addChild(CCultivateBuffData);
        this.addChild(CCultivateBuffListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty("currBuffID")) {
            curBuffData.updateDataByData({ID:data["currBuffID"]});
        }

        if (data.hasOwnProperty("selectBuffIDs")) {
            selectBuffList.resetChild();
            var serverData:Array = data["selectBuffIDs"] as Array;
            var newData:Array = new Array(serverData.length);
            for (var i:int = 0; i < serverData.length; i++) {
                var buffID:int = serverData[i];
                newData[i] = {ID:buffID};
            }
            selectBuffList.updateDataByData(newData);
        }

        if (data.hasOwnProperty("openBoxLayers")) {
            rewardListState = data["openBoxLayers"];
        }
    }

    public function get resetTimes() : int { return _data["resetTimes"]; } // 可重置次数
//    private function get currBuff() : int { return _data["currBuffID"]; } // 当前选中的buff
//    private function get selectBuffs() : Array { return _data["selectBuffIDs"]; } // 随机出来的buffList
    public function get rerandBuffNum() : int { return _data["rerandBuffNum"]; } // 当天已重随的免费次数
    public function get randBuffCostNum() : int { return _data["randBuffCostNum"]; } // 当天已重随扣费的次数
    public function get currBuffEffect() : int { return _data["currBuffEffect"]; } // 当前buff状态 1已激活, 0未激活

    public function get curBuffData() : CCultivateBuffData { return this.getChild(0) as CCultivateBuffData; }
    public function get selectBuffList() : CCultivateBuffListData { return this.getChild(1) as CCultivateBuffListData; }
    public function get openFlag() : Boolean { // true 开过, false, 没开过
        return _data["openFlag"];
    } // 是否首次打开系统, 非0是
    public function setOpenFlag() : void { _data["openFlag"] = true; }


    public function isGetRewardBox(levelIndex:int) : Boolean {
        if (!rewardListState) return false;
        return  rewardListState.indexOf(levelIndex) != -1;
    }
    public var rewardListState:Array; // 已领宝箱数据
    public var rewardBoxRewardList:Array;


}
}
