//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/4.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectListData;

public class CGiftBagRankListData extends CObjectListData {
    public function CGiftBagRankListData()
    {
        super( CGiftBagRankData, CGiftBagRankData.RoleID );
    }

    public function getDataById(roleId:Number):CGiftBagRankData
    {
        var rankData:CGiftBagRankData = this.getByPrimary(roleId) as CGiftBagRankData;
        return rankData;
    }
}
}
