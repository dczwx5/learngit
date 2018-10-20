//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/5.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;

public class CCultivateResultData extends CObjectData {
    public function CCultivateResultData() {
//        this.addChild(CRewardListData);
    }

    public override function updateDataByData(data:Object) : void {
        this.clearAll();
        super.updateDataByData(data);
    }


    [Inline]
    public function get index() : int { return _data["index"]; } // 第X关
    [Inline]
    public function get win() : int { return _data["win"]; } // 结果 : 0 : 失败, 1 : 成功, 2 : 战平, 3 : 完胜
    [Inline]
    public function get rewardList() : Object { return _data["rewardList"]; }

}
}
