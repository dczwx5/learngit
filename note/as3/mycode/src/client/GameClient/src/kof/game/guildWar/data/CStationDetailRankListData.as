//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/28.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

/**
 * 空间站能源排行详情排名列表数据
 */
public class CStationDetailRankListData extends CObjectListData {
    public function CStationDetailRankListData()
    {
        super (CStationDetailRankData, CStationDetailRankData.Ranking);
    }

    public function getDetailData(rank:int) : CStationDetailRankData
    {
        var data:CStationDetailRankData = this.getByPrimary(rank) as CStationDetailRankData;
        return data;
    }
}
}
