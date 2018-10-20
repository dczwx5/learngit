//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectListData;


public class CPeak1v1HeroStateListData extends CObjectListData {

    public function CPeak1v1HeroStateListData() {
        super (CPeak1v1HeroStateData, CPeak1v1HeroStateData._profession);
    }

    public function getHero(heroID:int) : CPeak1v1HeroStateData {
        var heroData:CPeak1v1HeroStateData = this.getByPrimary(heroID) as CPeak1v1HeroStateData;
        return heroData;
    }
}
}
