//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/15.
 */
package kof.game.im.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CIMChatData extends CObjectData {
    public function CIMChatData() {
        super();
        _data = new CMap();
    }
    public function get friendID() : Number { return _data[_friendID]; }
    public function get senderID() : Number { return _data[_senderID]; }
    public function get headID() : int { return _data[_headID]; }
    public function get message() : String { return _data[_message]; }

    public static function createObjectData( friendID:Number,senderID:Number,headID:int,message:String) : Object {
        return {friendID:friendID,senderID:senderID,headID:headID,message:message}
    }


    public static const _friendID:String = "friendID";
    public static const _senderID:String = "senderID";
    public static const _headID:String = "headID";
    public static const _message:String = "message";
}
}
