//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-5-28.
 */
package kof.game.activityHall.activeTask {

import kof.table.TaskActivity;

/**
 * @author Ender
 * @date 2018-5-28
 */
public class CActiveTaskData {
    public var config : TaskActivity;
    /**
     * 当前进度
     */
    public var currValue : int;
    /**
     * 任务状态 0未完成 1可领取 2已领取
     */
    public var state : int = 0;
}
}
