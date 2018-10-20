//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/22.
 */
package kof.game.player.data.property {

import kof.game.character.property.CBasePropertyData;

public class CHeroEquipProperty extends CBasePropertyData {
    public function CHeroEquipProperty() {

    }

    public override function add(other:CBasePropertyData) : void {
        super.add(other);
    }

    public function calcFinalProperty() : CHeroEquipProperty {
        var finalData:CHeroEquipProperty = new CHeroEquipProperty();
        finalData.HP = HP * (1 + PercentEquipHP/10000.0);
        finalData.Attack = Attack * (1 + PercentEquipATK/10000.0);
        finalData.Defense = Defense * (1 + PercentEquipDEF/10000.0);

        return finalData;
    }

}
}
