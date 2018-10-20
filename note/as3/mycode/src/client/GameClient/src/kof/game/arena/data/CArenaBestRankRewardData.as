//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/24.
 */
package kof.game.arena.data {

import kof.data.CObjectData;

/**
 * 最高排名奖励数据
 */
public class CArenaBestRankRewardData extends CObjectData{

    public static const HisBestRank:String = "rank";// 历史最高排名
    public static const CanGet:String = "canGet";// 可领奖励ID
    public static const HaveGot:String = "haveGot";// 已领奖励ID

    public function CArenaBestRankRewardData()
    {
        super();
    }

    public static function createObjectData(rank:int, canGet:Array, haveGot:Array) : Object
    {
        return {rank:rank, canGet:canGet, haveGot:haveGot};
    }

    public function get hisBestRank() : int { return _data[HisBestRank]; }
    public function get canGetRewards() : Array { return _data[CanGet]; }
    public function get haveGotRewards() : Array { return _data[HaveGot]; }
}
}
