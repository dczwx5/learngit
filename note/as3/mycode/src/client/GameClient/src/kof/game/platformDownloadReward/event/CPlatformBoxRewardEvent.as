//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward.event {

import flash.events.Event;

public class CPlatformBoxRewardEvent extends Event{

    public static const GetRewardSucc:String = "GetRewardSucc";// 领取奖励成功
    public static const RewardInfo:String = "rewardInfo";// 平台奖励信息(领取状态)

    public var data:Object;

    public function CPlatformBoxRewardEvent( type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false )
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
