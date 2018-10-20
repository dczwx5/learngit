//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/25.
 */
package kof.game.rank.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

public class RankData extends CObjectData {
    public function RankData(system:CAppSystem) {
        super();
        _data = new CMap();

        _system = system;
    }

    public function get _id() : int { return _data[__id]; }
    public function get value() : int { return _data[_value]; }
    public function get headId() : int { return _data[_headId]; }
    public function get level() : int { return _data[_level]; }
    public function get like() : int { return _data[_like]; }
    public function set like( value : int ):void{ _data[_like] = value };
    public function get name() : String { return _data[_name]; }
    public function get rank() : int { return _data[_rank]; }
    public function get heroId() : int { return _data[_heroId]; }
    public function get clubName() : String { return _data[_clubName]; }


    public function get vipLevel() : int { return _data[_vipLevel]; }
    public function get quality() : int { return _data[_quality]; }
    public function get power() : int { return _data[_power]; }


    public static function createObjectData( _id:int,value:int,headId:int,level:int,like:int,name:String,rank:int,heroId:int,clubName:String,
                                             isYellowVip:int,isYellowYearVip:int,yellowVipLevel:int,isYellowHighVip:int,
                                             isBlueVip:int,isBlueYearVip:int,blueVipLevel:int,isSuperBlueVip:int,vipLevel:int,quality:int,
                                             power:int) : Object {
        return {_id:_id,value:value,headId:headId,level:level,like:like,name:name,rank:rank,heroId:heroId,clubName:clubName,
            isYellowVip:isYellowVip,isYellowYearVip:isYellowYearVip,yellowVipLevel:yellowVipLevel,isYellowHighVip:isYellowHighVip,
            isBlueVip:isBlueVip,isBlueYearVip:isBlueYearVip,blueVipLevel:blueVipLevel,isSuperBlueVip:isSuperBlueVip,vipLevel:vipLevel,quality:quality,
            power:power}
    }

    public function get platformInfo() : Object {
        return _data[ _platformInfo ];
    }
    public function get platformData() : CPlatformBaseData {
        if (!_platformData) {
            _platformData = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).createPlatfromData(platformInfo);
        }
        return _platformData;
    }
    private var _platformData:CPlatformBaseData;
    private var _system:CAppSystem;

    public static const _platformInfo : String = "platformInfo";
    public static const __id:String = "_id";
    public static const _value:String = "value";
    public static const _headId:String = "headId";
    public static const _level:String = "level";
    public static const _like:String = "like";
    public static const _name:String = "name";
    public static const _rank:String = "rank";
    public static const _heroId:String = "heroId";
    public static const _clubName:String = "clubName";

    public static const _isYellowVip:String = "isYellowVip";
    public static const _isYellowYearVip:String = "isYellowYearVip";
    public static const _yellowVipLevel:String = "yellowVipLevel";
    public static const _isYellowHighVip:String = "isYellowHighVip";

    public static const _isBlueVip:String = "isBlueVip";
    public static const _isBlueYearVip:String = "isBlueYearVip";
    public static const _blueVipLevel:String = "blueVipLevel";
    public static const _isSuperBlueVip:String = "isSuperBlueVip";
    public static const _vipLevel:String = "vipLevel";
    public static const _quality:String = "quality";
    public static const _power:String = "power";
}
}
