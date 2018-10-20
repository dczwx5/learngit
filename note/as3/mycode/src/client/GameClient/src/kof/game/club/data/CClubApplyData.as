//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/31.
 * 俱乐部申请信息
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubApplyData extends CObjectData {
    public function CClubApplyData() {
        super();
        _data = new CMap();
    }

    public function get roleID() : int { return _data[_roleID]; }
    public function get name() : String { return _data[_name]; }
    public function get level() : int { return _data[_level]; }
    public function get battleValue() : int { return _data[_battleValue]; }
    public function get headID() : int { return _data[_headID]; }
    public function get vipLevel() : int { return _data[_vipLevel]; }
    public function get applyTime() : Number { return _data[_applyTime]; }

    public static function createObjectData( roleID:int,name:String,level:int,battleValue:int,headID:int,vipLevel:int,applyTime:Number) : Object {
        return {roleID:roleID,name:name,level:level,battleValue:battleValue,headID:headID,vipLevel:vipLevel,applyTime:applyTime}
    }

    public static const _roleID:String = "roleID";
    public static const _name:String = "name";
    public static const _level:String = "level";
    public static const _battleValue:String = "battleValue";
    public static const _headID:String = "headID";
    public static const _vipLevel:String = "vipLevel";
    public static const _applyTime:String = "applyTime";
}
}
