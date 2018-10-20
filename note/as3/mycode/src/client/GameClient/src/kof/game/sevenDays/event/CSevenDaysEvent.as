//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/24.
 */
package kof.game.sevenDays.event {

import flash.events.Event;

public class CSevenDaysEvent extends Event {

    public static const SEVEN_DAYS_SEVER_UPDATE : String = "sevenDaysSeverUpdate";//开服天数更新
    public static const SEVEN_DAYS_STATE_UPDATE : String = "sevenDaysStateUpdate";//领取状态发生改变
    public static const SEVEN_DAYS_REWARD_SUCCESS : String = "sevenDaysRewardSuccess";//领取奖励成功

    public function CSevenDaysEvent( type : String, data:Object = null ) {
        super( type );
        this.data = data;
    }

    public var data : Object;
}
}
