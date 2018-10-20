//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/21.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

public class CGuildWarStateListData extends CObjectListData {
    public function CGuildWarStateListData()
    {
        super (CGuildWarHeroStateData, CGuildWarHeroStateData.Profession);
    }

    public function getHero(heroID:int) : CGuildWarHeroStateData
    {
        var heroData:CGuildWarHeroStateData = this.getByPrimary(heroID) as CGuildWarHeroStateData;
        return heroData;
    }
}
}
