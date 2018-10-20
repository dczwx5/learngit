//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/9.
 * 好友数据
 */
package kof.game.im.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

public class CIMFriendsData extends CObjectData {
    public function CIMFriendsData() {
        super();
        _data = new CMap();
    }

    public function get platformData() : CPlatformBaseData {
        if (!_platformData) {
            _platformData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).createPlatfromData(platformInfo);
        }
        return _platformData;
    }
    private var _platformData:CPlatformBaseData;

    public function get platformInfo() : Object { return _data["platformInfo"]; }

    public function get name() : String { return _data[_name]; }
    public function get battleValue() : Number { return _data[_battleValue]; }
    public function get level() : int { return _data[_level]; }
    public function get headID() : int { return _data[_headID]; }
    public function get roleID() : Number { return _data[_roleID]; }
    public function get isGet() : int { return _data[_isGet]; }
    public function get isSend() : int { return _data[_isSend]; }
    public function get isOnline() : int { return _data[_isOnline]; }

    public function get isYellowVip() : int { return _data[_isYellowVip]; }
    public function get isYellowYearVip() : int { return _data[_isYellowYearVip]; }
    public function get yellowVipLevel() : int { return _data[_yellowVipLevel]; }
    public function get isYellowHighVip() : int { return _data[_isYellowHighVip]; }

    public function get isBlueVip() : int { return _data[_isBlueVip]; }
    public function get isBlueYearVip() : int { return _data[_isBlueYearVip]; }
    public function get blueVipLevel() : int { return _data[_blueVipLevel]; }
    public function get isSuperBlueVip() : int { return _data[_isSuperBlueVip]; }

    public function get vipLevel() : int { return _data[_vipLevel]; }

    public function get clubID() : String { return _data[_clubID]; }
    public function get clubName() : String { return _data[_clubName]; }

    // 拳皇大赛冗余数据
    public function get fairPeakScore() : int { return _data[_fairPeakScore]; }
    public function get fairPeakHeroIds() : Array { return _data[_fairPeakHeroIds]; }



    public static function createObjectData(name:String, battleValue:Number,level:int,headID:int,roleID:Number,isGet:int,isSend:int,isOnline:int,
                       isYellowVip:int,isYellowYearVip:int,yellowVipLevel:int,isYellowHighVip:int,
                       isBlueVip:int,isBlueYearVip:int,blueVipLevel:int,isSuperBlueVip:int,vipLevel:int,
                                            clubID:String,clubName:String) : Object {
        return {name:name, battleValue:battleValue,level:level,headID:headID,roleID:roleID,isGet:isGet,isSend:isSend,isOnline:isOnline,
            isYellowVip:isYellowVip,isYellowYearVip:isYellowYearVip,yellowVipLevel:yellowVipLevel,isYellowHighVip:isYellowHighVip,
            isBlueVip:isBlueVip,isBlueYearVip:isBlueYearVip,blueVipLevel:blueVipLevel,isSuperBlueVip:isSuperBlueVip,vipLevel:vipLevel,
            clubID:clubID,clubName:clubName}
    }

    public static const _name:String = "name";
    public static const _battleValue:String = "battleValue";
    public static const _level:String = "level";
    public static const _headID:String = "headID";
    public static const _roleID:String = "roleID";
    public static const _isGet:String = "isGet";
    public static const _isSend:String = "isSend";
    public static const _isOnline:String = "isOnline";

    public static const _isYellowVip:String = "isYellowVip";
    public static const _isYellowYearVip:String = "isYellowYearVip";
    public static const _yellowVipLevel:String = "yellowVipLevel";
    public static const _isYellowHighVip:String = "isYellowHighVip";

    public static const _isBlueVip:String = "isBlueVip";
    public static const _isBlueYearVip:String = "isBlueYearVip";
    public static const _blueVipLevel:String = "blueVipLevel";
    public static const _isSuperBlueVip:String = "isSuperBlueVip";

    public static const _vipLevel:String = "vipLevel";
    public static const _clubID:String = "clubID";
    public static const _clubName:String = "clubName";
    public static const _fairPeakScore:String = "fairPeakScore";
    public static const _fairPeakHeroIds:String = "fairPeakHeroIds";


}
}
