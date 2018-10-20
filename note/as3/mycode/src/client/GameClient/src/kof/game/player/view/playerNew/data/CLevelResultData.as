//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/21.
 */
package kof.game.player.view.playerNew.data {

import kof.data.CObjectData;

public class CLevelResultData extends CObjectData {

    public static const NewAttr:String = "newAttr";
    public static const OldAttr:String = "oldAttr";
    public static const HeroId:String = "heroId";

    public function CLevelResultData() {
        super();
    }

    public function get newAttr() : Array { return _data[NewAttr]; }// ElementType:CHeroAttrData
    public function get oldAttr() : Array { return _data[OldAttr]; }// ElementType:CHeroAttrData
    public function get heroId() : int { return _data[HeroId]; }

    public function set newAttr(value:Array):void
    {
        _data[NewAttr] = value;
    }

    public function set oldAttr(value:Array):void
    {
        _data[OldAttr] = value;
    }

    public function set heroId(value:int):void
    {
        _data[HeroId] = value;
    }
}
}
