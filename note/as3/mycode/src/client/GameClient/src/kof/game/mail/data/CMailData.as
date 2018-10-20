//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/15.
 */
package kof.game.mail.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CMailData extends CObjectData {

    public function CMailData() {
        super();
        _data = new CMap();
    }

    public function get uid() : Number { return _data[_uid]; }
    public function get createTime() : Number { return _data[_createTime]; }
    public function get expireTime() : Number { return _data[_expireTime]; }
    // 邮件状态
    //1 邮件没有附件，且邮件未阅读状态
    //2 邮件没有附件，且邮件已阅读状态
    //3 邮件有附件，且邮件未阅读状态
    //4 邮件有附件，附件未领取，邮件已阅读状态
    //5 邮件有附件，附件已领取，邮件已阅读状态
    public function get state() : int { return _data[_state]; }
    public function get attachs() : Array { return _data[_attachs]; }
    public function get sent() : String { return _data[_sent]; }
    public function get name() : String { return _data[_name]; }
    public function get content() : String { return _data[_content]; }
    public function get top() : int { return _data[_top]; }



    public static function createObjectData(uid:Number, createTime:Number, expireTime:Number, state:int, attachs:Array,
                                            sent :String,name:String,content:String,top:int) : Object {
        return {uid:uid, createTime:createTime, expireTime:expireTime, state:state, attachs:attachs,
            sent:sent,name:name,content:content,top:top}
    }

    public static const _uid:String = "uid";
    public static const _createTime:String = "createTime";
    public static const _expireTime:String = "expireTime";
    public static const _state:String = "state";
    public static const _attachs:String = "attachs";
    public static const _sent:String = "sent";
    public static const _name:String = "name";
    public static const _content:String = "content";
    public static const _top:String = "top";
}
}
