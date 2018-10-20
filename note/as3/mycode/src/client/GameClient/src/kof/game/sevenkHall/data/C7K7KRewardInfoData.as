//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/22.
 */
package kof.game.sevenkHall.data {

import kof.data.CObjectData;

public class C7K7KRewardInfoData extends CObjectData {

    public static const EverydayRewardState:String = "everydayRewardState";// 普通贵族每日奖励领取状态
    public static const YearVipEverydayRewardState:String = "yearVipEverydayRewardState";// 年费贵族每日奖励领取状态
    public static const NewPlayerRewardState:String = "newPlayerRewardState";// 普通贵族新手奖励领取状态
    public static const YearVipNewPlayerRewardState:String = "yearVipNewPlayerRewardState";// 年费贵族新手奖励领取状态
    public static const LevelUpRewardState:String = "levelUpRewardState";// 普通贵族等级奖励领取状态
    public static const YearVipLevelUpRewardState:String = "yearVipLevelUpRewardState";// 年费贵族等级奖励领取状态

    public function C7K7KRewardInfoData()
    {
        super();
    }

    public function get everydayRewardState() : int { return _data[EverydayRewardState]; }
    public function get yearVipEverydayRewardState() : int { return _data[YearVipEverydayRewardState]; }
    public function get newPlayerRewardState() : int { return _data[NewPlayerRewardState]; }
    public function get yearVipNewPlayerRewardState() : int { return _data[YearVipNewPlayerRewardState]; }
    public function get levelUpRewardState() : Array { return _data[LevelUpRewardState]; }
    public function get yearVipLevelUpRewardState() : Array { return _data[YearVipLevelUpRewardState]; }

    public function set everydayRewardState(value:int):void
    {
        _data[EverydayRewardState] = value;
    }

    public function set yearVipEverydayRewardState(value:int):void
    {
        _data[YearVipEverydayRewardState] = value;
    }

    public function set newPlayerRewardState(value:int):void
    {
        _data[NewPlayerRewardState] = value;
    }

    public function set yearVipNewPlayerRewardState(value:int):void
    {
        _data[YearVipNewPlayerRewardState] = value;
    }

    public function set levelUpRewardState(value:Array):void
    {
        _data[LevelUpRewardState] = value;
    }

    public function set yearVipLevelUpRewardState(value:Array):void
    {
        _data[YearVipLevelUpRewardState] = value;
    }
}
}
