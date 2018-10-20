//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/28.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

/**
 * 所有空间站能源排行数据列表
 */
public class CStationTotalScoreRankListData extends CObjectListData {
    public function CStationTotalScoreRankListData()
    {
        super (CStationScoreRankData, CStationScoreRankData.SpaceId);
    }

    public function getRankData(spaceId:int) : CStationScoreRankData
    {
        var rankData:CStationScoreRankData = this.getByPrimary(spaceId) as CStationScoreRankData;
        return rankData;
    }
}
}
