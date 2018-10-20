//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.data {

import kof.data.CObjectData;

public class CStoryResultData extends CObjectData {
    public function CStoryResultData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    [Inline]
    public function get heroID() : int { return data[_heroID]; } // 格斗家ID
    [Inline]
    public function get gateIndex() : int { return data[_gateIndex]; } //第几关，从1开始
    [Inline]
    public function get win() : Boolean { return data[_win]; } //是否胜利
    [Inline]
    public function get rewardList() : Array { return data[_rewardList]; } //获得的奖励


    public static const _heroID:String = "heroID";
    public static const _gateIndex:String = "gateIndex";
    public static const _win:String = "win";
    public static const _rewardList:String = "rewardList";
}
}
