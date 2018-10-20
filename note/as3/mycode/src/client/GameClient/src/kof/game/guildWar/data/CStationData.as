//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/19.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 主界面的空间站数据
 */
public class CStationData extends CObjectData {

    public static const SpaceId:String = "spaceId";// 空间站id
    public static const ClubID:String = "clubID";// 俱乐部ID
    public static const ClubName:String = "clubName";// 俱乐部名字
    public static const ClubSignID:String = "clubSignID";// 俱乐部徽章
    public static const ClubScore:String = "clubScore";// 俱乐部积分(以太能源)

    public function CStationData() {
        super();
    }

    public function get spaceId() : int { return _data[SpaceId]; }
    public function get clubID() : String { return _data[ClubID]; }
    public function get clubName() : String { return _data[ClubName]; }
    public function get clubSignID() : int { return _data[ClubSignID]; }
    public function get clubScore() : int { return _data[ClubScore]; }

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
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
