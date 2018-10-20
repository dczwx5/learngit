//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/27.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 个人排行榜单条数据
 */
public class CRoleRankCellData extends CObjectData {

    public static const Ranking:String = "ranking";
    public static const RoleID:String = "roleID";
    public static const Name:String = "name";
    public static const Score:String = "score";
    public static const ClubID:String = "clubID";
    public static const ClubName:String = "clubName";
    public static const ClubSignID:String = "clubSignID";

    public function CRoleRankCellData()
    {
        super();
    }

    public function get ranking() : int { return _data[Ranking]; }
    public function get roleID() : Number { return _data[RoleID]; }
    public function get name() : String { return _data[Name]; }
    public function get score() : int { return _data[Score]; }
    public function get clubID() : String { return _data[ClubID]; }
    public function get clubName() : String { return _data[ClubName]; }
    public function get clubSignID() : int { return _data[ClubSignID]; }

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

    public function set clubID(value:String):void
    {
        _data[ClubID] = value;
    }

    public function set clubName(value:String):void
    {
        _data[ClubName] = value;
    }

    public function set clubSignID(value:int):void
    {
        _data[ClubSignID] = value;
    }
}
}
