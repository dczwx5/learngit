//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/8.
 * 好友申请数据
 */
package kof.game.im.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

public class CIMApplyData extends CObjectData{
    public function CIMApplyData() {
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
    public function get isAgree() : int { return _data[_isAgree]; }
    public function get isOnline() : int { return _data[_isOnline]; }
    public function get isGet() : int { return _data[_isGet]; }//没有意义，只为排序

    public function get isYellowVip() : int { return _data[_isYellowVip]; }
    public function get isYellowYearVip() : int { return _data[_isYellowYearVip]; }
    public function get yellowVipLevel() : int { return _data[_yellowVipLevel]; }
    public function get isYellowHighVip() : int { return _data[_isYellowHighVip]; }

    public function get isBlueVip() : int { return _data[_isBlueVip]; }
    public function get isBlueYearVip() : int { return _data[_isBlueYearVip]; }
    public function get blueVipLevel() : int { return _data[_blueVipLevel]; }
    public function get isSuperBlueVip() : int { return _data[_isSuperBlueVip]; }
    public function get vipLevel() : int { return _data[_vipLevel]; }


    public static function createObjectData(name:String, battleValue:Number,level:int,headID:int,roleID:Number,isAgree:int,isOnline:int,isGet:int,
                                            isYellowVip:int,isYellowYearVip:int,yellowVipLevel:int,isYellowHighVip:int,
                                            isBlueVip:int,isBlueYearVip:int,blueVipLevel:int,isSuperBlueVip:int,vipLevel:int) : Object {
        return {name:name, battleValue:battleValue,level:level,headID:headID,roleID:roleID,isAgree:isAgree,isOnline:isOnline,isGet:isGet,
            isYellowVip:isYellowVip,isYellowYearVip:isYellowYearVip,yellowVipLevel:yellowVipLevel,isYellowHighVip:isYellowHighVip,
            isBlueVip:isBlueVip,isBlueYearVip:isBlueYearVip,blueVipLevel:blueVipLevel,isSuperBlueVip:isSuperBlueVip,vipLevel:vipLevel}
    }

    public static const _name:String = "name";
    public static const _battleValue:String = "battleValue";
    public static const _level:String = "level";
    public static const _headID:String = "headID";
    public static const _roleID:String = "roleID";
    public static const _isAgree:String = "isAgree";
    public static const _isOnline:String = "isOnline";
    public static const _isGet:String = "isGet";

    public static const _isYellowVip:String = "isYellowVip";
    public static const _isYellowYearVip:String = "isYellowYearVip";
    public static const _yellowVipLevel:String = "yellowVipLevel";
    public static const _isYellowHighVip:String = "isYellowHighVip";

    public static const _isBlueVip:String = "isBlueVip";
    public static const _isBlueYearVip:String = "isBlueYearVip";
    public static const _blueVipLevel:String = "blueVipLevel";
    public static const _isSuperBlueVip:String = "isSuperBlueVip";

    public static const _vipLevel:String = "vipLevel";
}
}
