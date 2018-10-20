//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/27.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 俱乐部排行榜单条数据
 */
public class CClubRankCellData extends CObjectData {

    public static const Ranking:String = "ranking";
    public static const ClubID:String = "clubID";
    public static const ClubName:String = "clubName";
    public static const ClubSignID:String = "clubSignID";
    public static const ClubScore:String = "clubScore";

    public function CClubRankCellData()
    {
        super();
    }

    public function get ranking() : int { return _data[Ranking]; }
    public function get clubID() : String { return _data[ClubID]; }
    public function get clubName() : String { return _data[ClubName]; }
    public function get clubSignID() : int { return _data[ClubSignID]; }
    public function get clubScore() : int { return _data[ClubScore]; }

    public function set ranking(value:int):void
    {
        _data[Ranking] = value;
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

    public function set clubScore(value:int):void
    {
        _data[ClubScore] = value;
    }
}
}
