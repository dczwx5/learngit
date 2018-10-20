//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/8.
 */
package kof.game.player.view.playerNew.data {

import kof.data.CObjectData;

/**
 * 格斗家升品成功结算数据
 */
public class CQualityResultData extends CObjectData {

    public static const NewAttr:String = "newAttr";
    public static const OldAttr:String = "oldAttr";
    public static const NewCombat:String = "newCombat";
    public static const OldCombat:String = "oldCombat";
    public static const NewQualityName:String = "newQualityName";
    public static const OldQualityName:String = "oldQualityName";
    public static const HeroId:String = "heroId";
    public static const OldQualityLevelValue:String = "oldQualityLevelValue";
    public static const NewQualityLevelValue:String = "newQualityLevelValue";

    public function CQualityResultData()
    {
        super();
    }

    public function get newAttr() : Array { return _data[NewAttr]; }// ElementType:CHeroAttrData
    public function get oldAttr() : Array { return _data[OldAttr]; }// ElementType:CHeroAttrData
    public function get newCombat() : int { return _data[NewCombat]; }
    public function get oldCombat() : int { return _data[OldCombat]; }
    public function get newQualityName() : String { return _data[NewQualityName]; }
    public function get oldQualityName() : String { return _data[OldQualityName]; }
    public function get heroId() : int { return _data[HeroId]; }
    public function get oldQualityLevelValue() : int { return _data[OldQualityLevelValue]; }
    public function get newQualityLevelValue() : int { return _data[NewQualityLevelValue]; }

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

    public function set newQualityName(value:String):void
    {
        _data[NewQualityName] = value;
    }

    public function set oldQualityName(value:String):void
    {
        _data[OldQualityName] = value;
    }

    public function set heroId(value:int):void
    {
        _data[HeroId] = value;
    }

    public function set oldQualityLevelValue(value:int):void
    {
        _data[OldQualityLevelValue] = value;
    }

    public function set newQualityLevelValue(value:int):void
    {
        _data[NewQualityLevelValue] = value;
    }
}
}
