//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/17.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;

public class CEndlessTowerHeroData extends CObjectData {

    public static const HeroId:String = "heroId";
    public static const Level:String = "level";
    public static const Quality:String = "quality";
    public static const Star:String = "star";
    public static const LayerId:String = "layerId";

    public function CEndlessTowerHeroData()
    {
        super();
    }

    public function get heroId() : int { return _data[HeroId]; }
    public function get level() : int { return _data[Level]; }
    public function get quality() : int { return _data[Quality]; }
    public function get star() : int { return _data[Star]; }
    public function get layerId() : int { return _data[LayerId]; }

    public function set heroId(value:int):void
    {
        _data[HeroId] = value;
    }

    public function set level(value:int):void
    {
        _data[Level] = value;
    }

    public function set quality(value:int):void
    {
        _data[Quality] = value;
    }

    public function set star(value:int):void
    {
        _data[Star] = value;
    }

    public function set layerId(value:int):void
    {
        _data[LayerId] = value;
    }
}
}
