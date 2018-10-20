//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/8/11.
 */
package kof.game.newServerActivity.data {

/**
 * 新服活动配置数据
 * **/
public class CActivityRewardConfig {

    public static const TYPE_RANK:int = 1;
    public function CActivityRewardConfig() {
    }

    public var pre_goal : int = 2 ;//排名奖励中使用,默认从第二名开始
    public var goal : int;
    public var rewardID : int;
    public var rewardType : int;//0:阶段奖励 1：排名奖励
    /***********目标奖励中使用的字段***********************/
    public var canGet : Boolean = false;
    public var hasGet : Boolean = false;
}
}
