//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data {


import kof.data.CObjectData;

public class CStreetFighterHeroHpData extends CObjectData {
    public function CStreetFighterHeroHpData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    [Inline]
    public function get profession() : int { return _data[_profession]; } // 角色ID
    [Inline]
    public function get HP() : int { return _data["HP"]; } //
    [Inline]
    public function get MaxHP() : int { return _data["MaxHP"]; } //

    public static const _profession:String = "profession";

}
}
