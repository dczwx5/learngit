//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.arena.util {

/**
 * 竞技场操作锁定状态类
 */
public class CArenaState {

    public static var isInChangeGroup:Boolean;// 是否在换一组操作
    public static var isInChallenge:Boolean;// 是否在挑战操作
    public static var isInBuyPower:Boolean;// 是否在购买体力操作
    public static var isInTakeReward:Boolean;// 是否在领取奖励操作
    public static var isInWorship:Boolean;// 是否在膜拜操作

    public function CArenaState()
    {
    }

    public static function reset():void
    {
        isInChangeGroup = false;
        isInChallenge = false;
        isInBuyPower = false;
        isInTakeReward = false;
        isInWorship = false;
    }
}
}
