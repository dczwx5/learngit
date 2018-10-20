//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/3.
 */
package kof.game.guildWar.data.fightActivation {

import kof.data.CObjectData;

/**
 * 公会战鼓舞记录数据
 */
public class CGuildWarBuffRecordData extends CObjectData {

    public static const BuffType:String = "buffType";// 鼓舞类型 ：1普通鼓舞 2钻石鼓舞
    public static const Name:String = "name";// 鼓舞人战队名

    public function CGuildWarBuffRecordData()
    {
        super();
    }

    public function get buffType() : int { return _data[BuffType]; }
    public function get name() : String { return _data[Name]; }

    public function set buffType(value:int):void
    {
        _data[BuffType] = value;
    }

    public function set name(value:String):void
    {
        _data[Name] = value;
    }
}
}
