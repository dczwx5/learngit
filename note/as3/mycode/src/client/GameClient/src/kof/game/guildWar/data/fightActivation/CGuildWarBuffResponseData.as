//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/3.
 */
package kof.game.guildWar.data.fightActivation {

import kof.data.CObjectData;

/**
 * 公会战鼓舞反馈数据
 */
public class CGuildWarBuffResponseData extends CObjectData {

    public static const BuffType:String = "buffType";// 鼓舞类型 ：1普通鼓舞 2钻石鼓舞
    public static const Success:String = "success";// true 鼓舞成功 ; false 鼓舞失败

    public function CGuildWarBuffResponseData()
    {
        super();
    }

    public function get buffType() : int { return _data[BuffType]; }
    public function get success() : Boolean { return _data[Success]; }

    public function set buffType(value:int):void
    {
        _data[BuffType] = value;
    }

    public function set success(value:Boolean):void
    {
        _data[Success] = value;
    }
}
}
