//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/2.
 */
package kof.game.guildWar.data.fightReport {

import kof.data.CObjectListData;

/**
 * 战报内容列表数据
 */
public class CGuildWarFightContentListData extends CObjectListData {
    public function CGuildWarFightContentListData()
    {
        super (CGuildWarFightReportContentData, null);
    }

    public function getReportContentData(time:Number) : CGuildWarFightReportContentData
    {
        var rankData:CGuildWarFightReportContentData = this.getByPrimary(time) as CGuildWarFightReportContentData;
        return rankData;
    }
}
}
