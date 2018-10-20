//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/2.
 */
package kof.game.guildWar.data.fightReport {

import kof.data.CObjectData;

/**
 * 战报内容数据
 */
public class CGuildWarFightReportContentData extends CObjectData {

    public static const ReportConfigID:String = "reportConfigID";
    public static const ReportContents:String = "reportContents";
    public static const Time:String = "time";

    public function CGuildWarFightReportContentData()
    {
        super();
    }

    public function get reportConfigID() : int { return _data[ReportConfigID]; }
    public function get reportContents() : Array { return _data[ReportContents]; }
    public function get time() : Number { return _data[Time]; }

    public function set reportConfigID(value:int):void
    {
        _data[ReportConfigID] = value;
    }

    public function set reportContents(value:Array):void
    {
        _data[ReportContents] = value;
    }

    public function set time(value:Number):void
    {
        _data[Time] = value;
    }
}
}
