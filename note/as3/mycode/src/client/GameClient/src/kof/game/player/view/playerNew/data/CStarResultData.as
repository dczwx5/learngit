//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/9.
 */
package kof.game.player.view.playerNew.data {

import kof.data.CObjectData;

public class CStarResultData extends CObjectData {

    public static const NewAttr:String = "newAttr";
    public static const OldAttr:String = "oldAttr";
    public static const NewCombat:String = "newCombat";
    public static const OldCombat:String = "oldCombat";
    public static const NewStar:String = "newStar";
    public static const OldStar:String = "oldStar";
    public static const HeroId:String = "heroId";

    public function CStarResultData() {
        super();
    }

    public function get newAttr() : Array { return _data[NewAttr]; }// ElementType:CHeroAttrData
    public function get oldAttr() : Array { return _data[OldAttr]; }// ElementType:CHeroAttrData
    public function get newCombat() : int { return _data[NewCombat]; }
    public function get oldCombat() : int { return _data[OldCombat]; }
    public function get newStar() : int { return _data[NewStar]; }
    public function get oldStar() : int { return _data[OldStar]; }
    public function get heroId() : int { return _data[HeroId]; }

    public function set newAttr(value:Array):void
    {
        _data[NewAttr] = value;
    }

    public function set oldAttr(value:Array):void
    {
        _data[OldAttr] = value;
    }

    public function set newCombat(value:int):void
    {
        _data[NewCombat] = value;
    }

    public function set oldCombat(value:int):void
    {
        _data[OldCombat] = value;
    }

    public function set newStar(value:int):void
    {
        _data[NewStar] = value;
    }

    public function set oldStar(value:int):void
    {
        _data[OldStar] = value;
    }

    public function set heroId(value:int):void
    {
        _data[HeroId] = value;
    }
}
}
