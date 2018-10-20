//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/25.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

public class CEnemyFightHeroData extends CObjectData {

    public static const PrototypeID:String = "prototypeID";
    public static const Level:String = "level";
    public static const Quality:String = "quality";
    public static const Star:String = "star";
    public static const BattleValue:String = "battleValue";

    public function CEnemyFightHeroData()
    {
        super();
    }

    public function get prototypeID() : int { return _data[PrototypeID]; }
    public function get level() : int { return _data[Level]; }
    public function get quality() : int { return _data[Quality]; }
    public function get star() : int { return _data[Star]; }
    public function get battleValue() : Number { return _data[BattleValue]; }

    public function set prototypeID(value:int):void
    {
        _data[PrototypeID] = value;
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

    public function set battleValue(value:Number):void
    {
        _data[BattleValue] = value;
    }
}
}
