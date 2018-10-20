//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import kof.data.CObjectListData;

public class CPeakGameRankListData extends CObjectListData {
    public function CPeakGameRankListData() {
        super (CPeakGameRankItemData, CPeakGameRankItemData._playerUID);
    }

    public function getByRanking(ranking:int) : CPeakGameRankItemData {
        return this.getByKey(CPeakGameRankItemData._ranking, ranking) as CPeakGameRankItemData;
    }

}
}
