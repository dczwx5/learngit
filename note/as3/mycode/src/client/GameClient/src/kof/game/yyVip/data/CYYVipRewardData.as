//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/15.
 */
package kof.game.yyVip.data {

import kof.message.PlatformReward.PlatformRewardInfoYYResponse;

public class CYYVipRewardData {
    public function CYYVipRewardData() {
    }

    public function updateData(response:PlatformRewardInfoYYResponse) : void {

        yyVipLevelRewardState = response.dataMap.yyVipLevelRewardState;
        dayWelfareState = response.dataMap.dayWelfareState;
        weekWelfareState = response.dataMap.weekWelfareState;
    }

    /**
     * 查找该YY会员礼包是否已经领取
     * */
    public function isVipLevelReward(bagLevel:int) : Boolean {
        for(var i:int = 0;i<yyVipLevelRewardState.length;i++)
        {
            if(yyVipLevelRewardState[i] == bagLevel)
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 查找该日礼包是否已经领取
     * */
    public function isDaysReward(dayLevel:int) : Boolean {
        var a:int = dayWelfareState.length;
        for(var i:int = 0;i<dayWelfareState.length;i++)
        {
            if(dayWelfareState[i] == dayLevel)
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 查找该日礼包是否已经领取
     * */
    public function isWeekReward(weekLevel:int) : Boolean {
        for(var i:int = 0;i<weekWelfareState.length;i++)
        {
            if(weekWelfareState[i] == weekLevel)
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 已经领取的yy会员等级奖励
     * */
    public var yyVipLevelRewardState:Array = []; // 0 , 1
    /**
     * 已经购买的日礼包ID
     * */
    public var dayWelfareState:Array = []; // 0 , 1
    /**
     * 已经购买的周礼包ID
     * */
    public var weekWelfareState:Array = []; // 0 , 1
}
}
