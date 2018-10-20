//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/17.
 */
package kof.game.recruitRank.event {

import flash.events.Event;


public class CRecruitRankEvent extends Event{
    public static const OPEN_ACTIVITY:String = "openActivity";//开放活动
    public static const RANK_UPDATE:String = "rankUpdate";//更新排行列表
    public static const REWARD_UPDATE:String = "rewardUpdate";//更新奖励信息
    public static const TIMES_UPDATE:String = "timesUpdate";//更新全服累计

    public var data:Object;
    public function CRecruitRankEvent(type:String,data:Object = null) {
        super(type);
        this.data = data;
    }
}
}
