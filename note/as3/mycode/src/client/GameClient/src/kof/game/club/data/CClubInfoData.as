//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/27.
 * 俱乐部基本信息
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

public class CClubInfoData extends CObjectData {
    public function CClubInfoData(system:CAppSystem) {
        super();
        _data = new CMap();

        _system = system;
    }

    public function get id() : String { return _data[_id]; }
    public function get name() : String { return _data[_name]; }
    public function get level() : int { return _data[_level]; }
    public function set level( value : int) : void { _data[_level] = value; }
    public function get battleValue() : Number { return _data[_battleValue]; }
    public function get clubSignID() : int { return _data[_clubSignID]; }
    public function get announcement() : String { return _data[_announcement]; }
    public function get joinCondition() : int { return _data[_joinCondition]; }
    public function get levelCondition() : int { return _data[_levelCondition]; }
    public function get memberCount() : int { return _data[_memberCount]; }
    public function get chairmanName() : String { return _data[_chairmanName]; }
    public function get rank() : int { return _data[_rank]; }
    public function get chairmanInfo() : Object { return _data[_chairmanInfo]; }
    public function get logList() : Array { return _data[_logList]; }
    public function get isApply() : Boolean { return _data[_isApply]; }
    public function get fund() : int { return _data[_fund]; }
    public function get like() : int { return _data[_like]; }
    public function set like( value : int ):void{ _data[_like] = value };
    public function get applicationSize() : int { return _data[_applicationSize]; }
    public function set applicationSize( value : int ) : void{ _data[_applicationSize] = value };
    public function get nextInviteTime() : Number { return _data[_nextInviteTime]; }


    public static function createObjectData(id:int ,name:String,level:int,battleValue:Number,clubSignID:int,announcement:String,joinCondition:int,
                                            levelCondition:int,memberCount:int,chairmanName:String,rank:int,chairmanInfo:Object,logList:Array,isApply:Boolean,fund:int,like:int,
                                            applicationSize:int,nextInviteTime:Number) : Object {
        return {id:id,name:name,level:level, battleValue:battleValue,clubSignID:clubSignID,announcement:announcement,joinCondition:joinCondition,
            levelCondition:levelCondition,memberCount:memberCount,chairmanName:chairmanName,rank:rank,chairmanInfo:chairmanInfo,logList:logList,isApply:isApply,fund:fund,like:like,
            applicationSize:applicationSize,nextInviteTime:nextInviteTime}
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

    public static const _id:String = "id";
    public static const _name:String = "name";
    public static const _level:String = "level";
    public static const _battleValue:String = "battleValue";
    public static const _clubSignID:String = "clubSignID";
    public static const _announcement:String = "announcement";
    public static const _joinCondition:String = "joinCondition";
    public static const _levelCondition:String = "levelCondition";
    public static const _memberCount:String = "memberCount";
    public static const _chairmanName:String = "chairmanName";
    public static const _rank:String = "rank";
    public static const _chairmanInfo:String = "chairmanInfo";
    public static const _logList:String = "logList";
    public static const _isApply:String = "isApply";
    public static const _fund:String = "fund";
    public static const _like:String = "like";
    public static const _applicationSize:String = "applicationSize";
    public static const _nextInviteTime:String = "nextInviteTime";
    public static const _platformInfo : String = "platformInfo";
}
}
