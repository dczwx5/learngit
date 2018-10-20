//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/12.
 */
package kof.game.GMReport.Event {

import flash.events.Event;

public class CGMReportEvent extends Event
{
    public static const OpenReportWin:String = "OpenReportWin";// 打开举报界面
    public static const ReportSucc:String = "ReportSucc";// 举报成功
    public static const SelectDate:String = "SelectDate";// 选择某个日期

    public var data:Object;

    public function CGMReportEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
