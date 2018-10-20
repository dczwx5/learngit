//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/22.
 */
package kof.game.player.data.property {

import kof.game.character.property.CBasePropertyData;

public class CPlayerHeroProperty extends CBasePropertyData {
    public function CPlayerHeroProperty() {

    }

    public override function add(other:CBasePropertyData) : void {
        super.add(other);

        if (other is CPlayerHeroProperty) {

        }
    }

}
}
