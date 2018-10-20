//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/28.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

public class CTotalScoreRankListData extends CObjectListData {
    public function CTotalScoreRankListData()
    {
        super (CTotalScoreRankData, CTotalScoreRankData.RoleID);
    }

    public function getRankData(roleId:Number) : CTotalScoreRankData
    {
        var rankData:CTotalScoreRankData = this.getByPrimary(roleId) as CTotalScoreRankData;
        return rankData;
    }
}
}
