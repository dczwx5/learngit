//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/28.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 空间站能源排行详情排名数据
 */
public class CStationDetailRankData extends CObjectData {

    public static const Ranking:String = "ranking";
    public static const RoleID:String = "roleID";
    public static const Name:String = "name";
    public static const Score:String = "score";

    public function CStationDetailRankData()
    {
        super();
    }

    public function get ranking() : int { return _data[Ranking]; }
    public function get roleID() : Number { return _data[RoleID]; }
    public function get name() : String { return _data[Name]; }
    public function get score() : int { return _data[Score]; }

    public function set ranking(value:int):void
    {
        _data[Ranking] = value;
    }

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
}
}
