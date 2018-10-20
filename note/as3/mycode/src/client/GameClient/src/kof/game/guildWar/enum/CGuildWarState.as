//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/3.
 */
package kof.game.guildWar.enum {

public class CGuildWarState {

    public static var isInInspire:Boolean;// 是否战斗鼓舞操作

    public function CGuildWarState()
    {
    }

    public static function reset():void
    {
        isInInspire = false;
    }
}
}
