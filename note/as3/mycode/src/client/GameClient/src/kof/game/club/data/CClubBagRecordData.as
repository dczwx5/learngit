//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/14.
 * 红包日志
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubBagRecordData extends CObjectData {
    public function CClubBagRecordData() {
        super();
        _data = new CMap();
    }
    public function get name() : String { return _data[_name]; }
    public function get type() : int { return _data[_type]; }
    public function get record() : int { return _data[_record]; }
    public function get vipLevel() : int { return _data[_vipLevel]; }


    public static function createObjectData( name:String,type:int,record:int,vipLevel:int) : Object {
        return {name:name,type:type,record:record,vipLevel:vipLevel}
    }

    public static const _name:String = "name";
    public static const _type:String = "type";
    public static const _record:String = "record";
    public static const _vipLevel:String = "vipLevel";
}
}
