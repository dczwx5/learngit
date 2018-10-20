//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/19.
 */
package kof.game.arena.data {

import kof.data.CObjectData;

/**
 * 竞技场挑战者数据
 */
public class CArenaRoleData extends CObjectData {
    public static const RoleId:String = "roleId";// 角色ID
    public static const RoleName:String = "roleName";// 角色名
    public static const Rank:String = "rank";// 排名
    public static const Combat:String = "battleValue";// 战力
    public static const WorshipNum:String = "worship";// 被膜拜次数
    public static const DisplayId:String = "display";// 展示的格斗家ID
    public static const DisplayPos:String = "DisplayPos"// 展示位置:前三甲 1, 五个排名 2
    public static const HeroList:String = "heroList"// 出战格斗家列表

    public function CArenaRoleData()
    {
        super();
    }

    public static function createObjectData(roleId:int, roleName:String, rank:int, battleValue:int, worship:int, display:int) : Object
    {
        return {roleId:roleId, roleName:roleName, rank:rank, battleValue:battleValue, worship:worship, display:display};
    }

    public function get roleId() : Number { return _data[RoleId] == null ? 0 : _data[RoleId]; }
    public function get roleName() : String { return _data[RoleName]; }
    public function get rank() : int { return _data[Rank]; }
    public function get combat() : int { return _data[Combat]; }
    public function get worshipNum() : int { return _data[WorshipNum]; }
    public function get displayId() : int { return _data[DisplayId]; }
    public function get displayPos() : int { return _data[DisplayPos]; }
    public function get heroList() : Array { return _data[HeroList]; }

    public function set displayPos(value:int):void
    {
        _data.add(DisplayPos,value,true);
    }
}
}
