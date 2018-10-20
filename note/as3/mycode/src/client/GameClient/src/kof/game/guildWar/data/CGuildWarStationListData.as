//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/25.
 */
package kof.game.guildWar.data {

import kof.data.CObjectListData;

public class CGuildWarStationListData extends CObjectListData {
    public function CGuildWarStationListData()
    {
        super (CStationData, CStationData.SpaceId);
    }

    public function getStation(spaceId:int) : CStationData
    {
        var data:CStationData = this.getByPrimary(spaceId) as CStationData;
        return data;
    }
}
}
