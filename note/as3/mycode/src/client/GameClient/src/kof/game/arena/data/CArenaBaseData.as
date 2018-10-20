//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/26.
 */
package kof.game.arena.data {

import kof.data.CObjectData;

public class CArenaBaseData extends CObjectData {

    public static const ChallengeNum:String = "challengeNumber";// 可挑战次数
    public static const BuyNum:String = "buyNumber";// 已购买挑战次数
    public static const ChangeNumber:String = "changeNum";// 已换次数

    public function CArenaBaseData()
    {
        super();
    }

    public static function createObjectData(challengeNumber:int, buyNumber:int, changeNum:int) : Object
    {
        return {challengeNumber:challengeNumber, buyNumber:buyNumber, changeNum:changeNum};
    }

    public function get challengeNum() : int { return _data[ChallengeNum]; }
    public function get buyNum() : int { return _data[BuyNum]; }
    public function get changeNum() : int { return _data[ChangeNumber]; }
}
}
