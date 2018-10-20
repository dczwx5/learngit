//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/29.
 */
package kof.game.peakGame.data {

import kof.data.CObjectListData;

public class CPeakGameGloryListData extends CObjectListData {
    public function CPeakGameGloryListData() {
        super(CPeakGameGloryData, CPeakGameGloryData._season);
    }

    public function getGloryDataByIndex(index:int) : CPeakGameGloryData {
        return this.list[index];
    }
    public function getGloryDataBySeason(season:int) : CPeakGameGloryData {
        return this.getByPrimary(season) as CPeakGameGloryData;
    }
}
}
