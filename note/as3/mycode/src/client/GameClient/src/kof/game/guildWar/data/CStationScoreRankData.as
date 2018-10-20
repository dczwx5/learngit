//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/28.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 某个空间站能源排行数据
 */
public class CStationScoreRankData extends CObjectData {

    public static const SpaceId:String = "spaceId";

    public function CStationScoreRankData()
    {
        super();

        addChild(CStationDetailRankListData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(value.hasOwnProperty("detailRanks"))
        {
            detailRankListData.clearAll();
            detailRankListData.updateDataByData(value["detailRanks"]);
        }
    }

    public function get spaceId() : int { return _data[SpaceId]; }

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function get detailRankListData():CStationDetailRankListData
    {
        return this.getChild(0) as CStationDetailRankListData;
    }
}
}
