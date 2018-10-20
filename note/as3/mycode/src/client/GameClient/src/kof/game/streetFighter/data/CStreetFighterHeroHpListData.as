//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data {


import kof.data.CObjectListData;

public class CStreetFighterHeroHpListData extends CObjectListData {
    public function CStreetFighterHeroHpListData() {
        super (CStreetFighterHeroHpData, CStreetFighterHeroHpData._profession);
    }

    public override function updateDataByData(data:Object) : void {
        clearAll();
        super.updateDataByData(data);

    }
    public function getItem(roleID:int) : CStreetFighterHeroHpData {
        return super.getByPrimary(roleID) as CStreetFighterHeroHpData;
    }
}
}
