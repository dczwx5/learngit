//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/4.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectData;

/**
 * 俱乐部成员礼包排行数据
 */
public class CGiftBagRankData extends CObjectData {

    public static const RoleID:String = "roleID";
    public static const Name:String = "name";
    public static const Score:String = "score";
    public static const AlreadyReceiveRewardBags:String = "alreadyReceiveRewardBags";

    public function CGiftBagRankData()
    {
        super();
    }

    public function get roleID():Number {return _data[RoleID];}
    public function get name():String {return _data[Name];}
    public function get score():int {return _data[Score];}
    public function get alreadyReceiveRewardBags():Array {return _data[AlreadyReceiveRewardBags];}

    public function set roleID(value:Number):void
    {
        _data[RoleID] = value;
    }

    public function set name(value:String):void
    {
        _data[Name] = value;
    }

    public function set score(value:int):void
    {
        _data[Score] = value;
    }

    public function set alreadyReceiveRewardBags(value:Array):void
    {
        _data[AlreadyReceiveRewardBags] = value;
    }
}
}
