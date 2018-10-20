//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/24.
 */
package kof.game.streetFighter.data {
import kof.data.CObjectListData;

public class CStreetFighterEnterHeroListData extends CObjectListData {
    public function CStreetFighterEnterHeroListData() {
        super (CStreetFighterEnterHeroData, CStreetFighterEnterHeroData._roleID);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

        while (childList.length > 5) {
            shiftChild();
        }

    }
    public function getItem(roleID:int) : CStreetFighterEnterHeroData {
        return super.getByPrimary(roleID) as CStreetFighterEnterHeroData;
    }
}
}
