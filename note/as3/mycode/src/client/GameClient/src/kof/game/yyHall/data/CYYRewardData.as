//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/2/5.
 */
package kof.game.yyHall.data {

import kof.message.PlatformReward.PlatformRewardInfoYYResponse;

public class CYYRewardData {
    public function CYYRewardData() {

    }

    public function updateData(response:PlatformRewardInfoYYResponse) : void {

        newPlayerRewardState = response.dataMap.newPlayerRewardState;
        loginRewardState = response.dataMap.loginRewardState;
        gameLevelRewardState = response.dataMap.gameLevelRewardState;
        yyLevelRewardState = response.dataMap.yyLevelRewardState;
        loginDays = response.loginDays;
    }

//    public function isLoginReward(day:int) : Boolean {
//        if (loginRewardList.hasOwnProperty(day.toString())) {
//            return loginRewardList[day] == 1;
//        } else {
//            return false;
//        }
//    }
    /**
     * 查找是否有对应的天数
     * */
    public function isLoginReward(day:int) : Boolean {
        for(var i:int = 0;i<loginRewardState.length;i++)
        {
            if(loginRewardState[i] == day)
            {
                return true;
            }
        }
        return false;
    }
    /**
     * 查找是否有对应的等级
     * */
    public function isGameLevelReward(level:int) : Boolean {
        for(var i:int = 0;i<gameLevelRewardState.length;i++)
        {
            if(gameLevelRewardState[i] == level)
            {
                return true;
            }
        }
        return false;
//        if (loginRewardList.hasOwnProperty(day.toString())) {
//            return loginRewardList[day] == 1;
//        } else {
//        }
    }
    /**
     * 查找是否有对应的YY等级
     * */
    public function isYYLevelRewardState(level:int) : Boolean {
        for ( var i : int = 0; i < yyLevelRewardState.length; i++ ) {
            if ( yyLevelRewardState[ i ] == level ) {
                return true;
            }
        }
        return false;
    }
    /**
     * 新手玩家奖励
     * */
    public var newPlayerRewardState:int; // 1 已领取, 2 未领取
    /**
     * 已经领取的登录奖励
     * */
    public var loginRewardState:Array = []; // 0 , 1
    /**
     * 已经领取的游戏等级奖励
     * */
    public var gameLevelRewardState:Array = []; // 0 , 1
    /**
     * 已经领取的yy等级奖励
     * */
    public var yyLevelRewardState:Array = []; // 0 , 1
    /**
     * 已经登录的天数
     * */
    public var loginDays:int; // 0 , 1
    /**
     * 提示码
     * */
    public var gamePromptID:int; // 0 , 1
    public var newReward:int; // 0 , 1
    public var loginRewardList:Object; // {1:0, 2:1, 3:1}


}
}
