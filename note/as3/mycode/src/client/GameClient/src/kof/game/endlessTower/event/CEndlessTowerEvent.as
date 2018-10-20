//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower.event {

import flash.events.Event;

public class CEndlessTowerEvent extends Event {

    public static const BaseInfo_Update:String = "baseInfoUpdate";// 基本信息更新
    public static const RankInfo_Update:String = "rankInfoUpdate";// 排行版信息更新
    public static const DayRewardInfo_Update:String = "dayRewardInfoUpdate";// 每日奖励领取信息更新
    public static const BoxRewardInfo_Update:String = "boxRewardInfoUpdate";// 通关宝箱领取信息更新
    public static const TakeRewardSucc:String = "takeRewardSucc";// 领取奖励成功
    public static const FightReport_Update:String = "fightReportUpdate";// 领取奖励成功
    public static const StartChallenge:String = "startChallenge";// 开始挑战
    public static const SweepSucc:String = "SweepSucc";// 扫荡成功

    public static const NET_RESULT:String = "netResult"; // 结算

    public var data:Object;

    public function CEndlessTowerEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
