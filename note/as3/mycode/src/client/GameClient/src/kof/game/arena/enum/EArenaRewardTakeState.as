//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/26.
 */
package kof.game.arena.enum {

public class EArenaRewardTakeState {

    public static var HasTaken:int = 1;// 已领取
    public static var CanTake:int = 2;// 可领取
    public static var NotReach:int = 3;// 尚未达成

    public function EArenaRewardTakeState()
    {
    }
}
}
