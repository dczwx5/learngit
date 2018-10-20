//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import kof.data.CObjectListData;

public class CPeakGameReportListData extends CObjectListData {
    public function CPeakGameReportListData() {
        super (CPeakGameReportItemData, CPeakGameReportItemData._time);
    }

    public function getReport(time:int) : CPeakGameReportItemData {
        return super.getByPrimary(time) as CPeakGameReportItemData;
    }
    
}
}
