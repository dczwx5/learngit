//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/4.
 */
package kof.game.ActivityNotice.data {

import kof.table.ActivitySchedule;

public class CActivityNoticeData {

    public var id:int;
    public var actData:ActivitySchedule;
    public var openState:int;// 1开启 0关闭
    public var startTime:Date;
    public var endTime:Date;

    public function CActivityNoticeData() {
    }
}
}
