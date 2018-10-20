//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/21.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

public class CGuildWarHeroStateData extends CObjectData {

    public static const Profession:String = "profession";
    public static const HP:String = "HP";

    public function CGuildWarHeroStateData() {
        super();
    }

    public function get profession() : int { return _data[Profession]; }
    public function get hp() : int { return _data[HP]; }

    public function set profession(value:int):void
    {
        _data[Profession] = value;
    }

    public function set hp(value:int):void
    {
        _data[HP] = value;
    }

}
}
