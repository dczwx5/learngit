//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectListData;

public class CCultivateHeroListData extends CObjectListData {
    public function CCultivateHeroListData() {
        super (CCultivateHeroData, CCultivateHeroData._profession);
    }

    public function getHero(heroID:int) : CCultivateHeroData {
        return this.getByPrimary(heroID) as CCultivateHeroData;
    }

}
}
