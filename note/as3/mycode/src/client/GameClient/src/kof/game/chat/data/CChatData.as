//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/8.
 */
package kof.game.chat.data {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.framework.CAppSystem;

import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.table.MarqueeInfo;

public class CChatData {

    private var _data:CMap;

    private var _isDirty:Boolean;

    public var hasShow : Boolean;

    public var showTime : int;

    public var clubID : String = '';

    public var marqueeInfo : MarqueeInfo;

    private var _responseData : Dictionary;//服务器传来的公告中所携带的数据

    public var marqueeRoleID : int;//跑马灯里的战队ID
    public var marqueeRoleName : String = '';//跑马灯里的战队名

    public function CChatData(system:CAppSystem) {
        _data = new CMap();
        _system = system;
    }

    public function initialData(data:Object) : void {
        _updateData(data);
    }

    private function _updateData(data:Object) : void {
        if (!data) return ;
        for (var key:String in data) {
            _setData(key, data[key]);
        }
    }
    private function _setData(key:String, value:*) : void {
        _data[key] = value;
        _isDirty = true;
    }

    public function set responseData(value : Dictionary) : void
    {
        _responseData = value;
    }
    public function get responseData() : Dictionary{return _responseData};
    public function get channel() : int { return _data[_channel]; }
    public function set channel( value : int ):void{ _data[_channel] = value ; }
    public function get message() : String { return _data[_message]; }
    public function set message( value : String ) : void{ _data[_message] = value; }
    public function get senderID() : int { return _data[_senderID]; }
    public function get peakScore() : int { return _data["peakStore"]; }
    public function get senderName() : String {
        if( _data[_senderName] )
            return _data[_senderName];
        else
            return '';
    }
    public function get location() : String {
        if( _data[_location] )
            return _data[_location];
        else
            return '';

    }
    public function get type() : int { return _data[_type]; }
    public function set type( value : int ):void{ _data[_type] = value ; }
    public function get receiverName() : String { return _data[_receiverName]; }
    public function get receiverID() : int { return _data[_receiverID]; }
    public function get senderUseHeadID() : int { return _data[_senderUseHeadID]; }


    public function get vipLevel() : int { return _data[_vipLevel]; }

    public function get platformInfo() : Object {
        return _data[_platformInfo];
    }
    public function get platformData() : CPlatformBaseData {
        if (!_platformData) {
            _platformData = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).createPlatfromData(platformInfo);
        }
        return _platformData;
    }
    private var _platformData:CPlatformBaseData;
    private var _system:CAppSystem;

    public static const _channel:String = "channel";
    public static const _message:String = "message";
    public static const _senderID:String = "senderID";
    public static const _senderName:String = "senderName";
    public static const _location:String = "location";
    public static const _type:String = "type";
    public static const _receiverID:String = "receiverID";
    public static const _receiverName:String = "receiverName";
    public static const _senderUseHeadID:String = "senderUseHeadID";
    public static const _platformInfo : String = "platformInfo";

    public static const _vipLevel:String = "vipLevel";
}
}
