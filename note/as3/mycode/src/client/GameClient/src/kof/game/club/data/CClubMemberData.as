//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/31.
 * 俱乐部成员信息
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubMemberData extends CObjectData {

    public function CClubMemberData() {
        super();
        _data = new CMap();
    }

    public function get roleID() : int { return _data[_roleID]; }
    public function get name() : String { return _data[_name]; }
    public function get level() : int { return _data[_level]; }
    public function get battleValue() : int { return _data[_battleValue]; }
    public function get headID() : int { return _data[_headID]; }
    public function get vipLevel() : int { return _data[_vipLevel]; }
    public function get fundCount() : int { return _data[_fundCount]; }
    public function get isOnline() : int { return _data[_isOnline]; }
    public function get position() : int { return _data[_position]; }
    public function get joinTime() : Number { return _data[_joinTime]; }
    public function get lastOutLineTime() : Number { return _data[_lastOutLineTime]; }

    public static function createObjectData( roleID:int,name:String,level:int,battleValue:int,headID:int,vipLevel:int,
                                             fundCount:int,isOnline:int,position:int,joinTime:Number,lastOutLineTime:Number) : Object {
        return {roleID:roleID,name:name,level:level,battleValue:battleValue,headID:headID,vipLevel:vipLevel,
            fundCount:fundCount,isOnline:isOnline,position:position,joinTime:joinTime,lastOutLineTime:lastOutLineTime}
    }

    public static const _roleID:String = "roleID";
    public static const _name:String = "name";
    public static const _level:String = "level";
    public static const _battleValue:String = "battleValue";
    public static const _headID:String = "headID";
    public static const _vipLevel:String = "vipLevel";
    public static const _fundCount:String = "fundCount";
    public static const _isOnline:String = "isOnline";
    public static const _position:String = "position";
    public static const _joinTime:String = "joinTime";
    public static const _lastOutLineTime:String = "lastOutLineTime";
}
}
