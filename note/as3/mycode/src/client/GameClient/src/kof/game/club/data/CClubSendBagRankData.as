//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/14.
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubSendBagRankData extends CObjectData {
    public function CClubSendBagRankData() {
        super();
        _data = new CMap();
    }

    public function get roleID() : Number { return _data[_roleID]; }
    public function get name() : String { return _data[_name]; }
    public function get totalValue() : int { return _data[_totalValue]; }
    public function get totalCounts() : int { return _data[_totalCounts]; }
    public function get vipLevel() : int { return _data[_vipLevel]; }


    public static function createObjectData( roleID:int,name:String,totalValue:int,totalCounts:int,vipLevel:int) : Object {
        return {roleID:roleID,name:name,totalValue:totalValue,totalCounts:totalCounts,vipLevel:vipLevel}
    }

    public static const _roleID:String = "roleID";
    public static const _name:String = "name";
    public static const _totalValue:String = "totalValue";
    public static const _totalCounts:String = "totalCounts";
    public static const _vipLevel:String = "vipLevel";
}
}
