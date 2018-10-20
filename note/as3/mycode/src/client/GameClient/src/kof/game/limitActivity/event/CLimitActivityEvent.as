//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/17.
 */
package kof.game.limitActivity.event {

import flash.events.Event;

public class CLimitActivityEvent extends Event {

    public static const ACTIVITY_RANK_UPDATE:String = "activityRankUpdate";//更新积分排行列表
    public static const ACTIVITY_REWARD_UPDATE:String = "activityRewardUpdate";//更新积分奖励信息

    public static const ACTIVITY_MYSCORE_UPDATE:String = "activityMyScoreUpdate";//更新我的积分

    public function CLimitActivityEvent( type : String, data:Object = null ) {
        super( type );
        this.data = data;
    }

    public var data:Object;
}
}
