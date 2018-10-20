//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/2.
 */
package kof.game.guildWar.data.fightReport {

import kof.data.CObjectData;

/**
 * 战报数据
 */
public class CGuildWarFightReportData extends CObjectData {

    public static const SpaceId:String = "spaceId";
    public static const AlwaysWinData:String = "alwaysWinData";
    public static const FightReportData:String = "fightReportData";

    public function CGuildWarFightReportData()
    {
        super();
        addChild(CGuildWarAlwaysWinData);
        addChild(CGuildWarFightContentListData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(alwaysWinData && value.hasOwnProperty(AlwaysWinData))
        {
            alwaysWinData.clearAll();
            alwaysWinData.updateDataByData(value[AlwaysWinData]);
        }

        if(fightReportContentListData && value.hasOwnProperty(FightReportData))
        {
            fightReportContentListData.clearAll();
            fightReportContentListData.updateDataByData(value[FightReportData]);
        }
    }

    public function get spaceId() : int { return _data[SpaceId]; }

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function get alwaysWinData():CGuildWarAlwaysWinData
    {
        return getChild(0) as CGuildWarAlwaysWinData;
    }

    public function get fightReportContentListData():CGuildWarFightContentListData
    {
        return getChild(1) as CGuildWarFightContentListData;
    }
}
}
