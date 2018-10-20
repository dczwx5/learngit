//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/8.
 * 基金
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubFundData extends CObjectData {
    public function CClubFundData() {
        super();
        _data = new CMap();
    }
    public function get id() : String { return _data[_id]; }
    public function get name() : String { return _data[_name]; }
    public function get level() : int { return _data[_level]; }
    public function get activeValue() : int { return _data[_activeValue]; }
    public function get fund() : int { return _data[_fund]; }
    public function get fundInvestCounts() : int { return _data[_fundInvestCounts]; }
    public function get getActiveRewardSign() : Array { return _data[_getActiveRewardSign]; }
    public function get vipInvestCounts() : int { return _data[_vipInvestCounts]; }

    public static function createObjectData( id:int,name:String,level:int,activeValue:int,fund:int,fundInvestCounts:int,getActiveRewardSign:Array) : Object {
        return {id:id,name:name,level:level,activeValue:activeValue,fund:fund,fundInvestCounts:fundInvestCounts,getActiveRewardSign:getActiveRewardSign}
    }

    public static const _id:String = "id";
    public static const _name:String = "name";
    public static const _level:String = "level";
    public static const _activeValue:String = "activeValue";
    public static const _fund:String = "fund";
    public static const _fundInvestCounts:String = "fundInvestCounts";
    public static const _getActiveRewardSign:String = "getActiveRewardSign";
    public static const _vipInvestCounts : String = "vipInvestCounts";
}
}
