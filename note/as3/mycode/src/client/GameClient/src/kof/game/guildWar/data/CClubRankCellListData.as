//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/27.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

/**
 * 空间站俱乐部排行榜列表数据
 */
public class CClubRankCellListData extends CObjectListData {
    public function CClubRankCellListData()
    {
        super (CClubRankCellData, CClubRankCellData.Ranking);
    }

    public function getRankData(ranking:int) : CClubRankCellData
    {
        var rankData:CClubRankCellData = this.getByPrimary(ranking) as CClubRankCellData;
        return rankData;
    }
}
}
