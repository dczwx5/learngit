//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/13.
 */
package kof.game.lobby {

import kof.game.common.system.CNetHandlerImp;
import kof.message.Activity.ActivityNoticeIdUpdateRequest;

public class CChargeActivityHandler extends CNetHandlerImp {
    public function CChargeActivityHandler() {
        super();
    }

    //活动提示框ID更新请求
    public function activityNoticeIdUpdateRequest(activityId:int):void
    {
        var request : ActivityNoticeIdUpdateRequest = new ActivityNoticeIdUpdateRequest();
        request.activityNoticeId = activityId;
        networking.post( request );
    }
}
}
