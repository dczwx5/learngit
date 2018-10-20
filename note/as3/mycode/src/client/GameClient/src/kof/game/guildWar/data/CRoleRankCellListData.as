//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/27.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

/**
 * 空间站个人排行榜列表数据
 */
public class CRoleRankCellListData extends CObjectListData {
    public function CRoleRankCellListData()
    {
        super (CRoleRankCellData, CRoleRankCellData.Ranking);
    }

    public function getRankData(ranking:int) : CRoleRankCellData
    {
        var rankData:CRoleRankCellData = this.getByPrimary(ranking) as CRoleRankCellData;
        return rankData;
    }
}
}
