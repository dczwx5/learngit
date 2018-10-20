//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/21.
 */
package kof.game.arena.event {

import flash.events.Event;

public class CArenaEvent extends Event{

    public static const AllChallenger_Update:String = "allChallengerUpdate";// 所有挑战信息更新
    public static const SingleChallenger_Update:String = "singleChallengerUpdate";// 单个挑战信息更新
    public static const RewardInfo_Update:String = "rewardInfoUpdate";// 奖励信息更新
    public static const BaseInfo_Update:String = "baseInfoUpdate";// 基本信息更新
    public static const TakeRewardSucc:String = "takeRewardSucc";// 领取奖励成功
    public static const FightReport_Update:String = "fightReportUpdate";// 领取奖励成功
    public static const WorshipSucc:String = "WorshipSucc";// 膜拜成功

    public var data:Object;

    public function CArenaEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
