//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/11.
 */
package kof.game.totalConsume {

import kof.framework.CAbstractHandler;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.data.CActivityHallActivityType;

public class CTotalConsumeHelpHandler extends CAbstractHandler {
    public function CTotalConsumeHelpHandler()
    {
        super();
    }

    public function getActivityInfo():CActivityHallActivityInfo
    {
        var vec:Vector.<CActivityHallActivityInfo> = activityHallDataManager.getOpenedActivityList();
        for each(var info:CActivityHallActivityInfo in vec)
        {
            if(info.table.type == CActivityHallActivityType.CONSUME)
            {
                return info;
            }
        }

        return null;
    }

    /**
     * 活动是否已开启
     * @return
     */
    public function isActivityOpen():Boolean
    {
        var activityInfo:CActivityHallActivityInfo = getActivityInfo();
        return activityInfo != null;
    }

    private function get activityHallDataManager() : CActivityHallDataManager
    {
        return system.stage.getSystem(CActivityHallSystem).getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
