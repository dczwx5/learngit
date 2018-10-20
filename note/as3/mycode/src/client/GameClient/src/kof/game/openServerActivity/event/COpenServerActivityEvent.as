//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/17.
 */
package kof.game.openServerActivity.event {

import flash.events.Event;

public class COpenServerActivityEvent extends Event {

    public static const ACTIVITY_START:String = "activityStart";
    public static const ACTIVITY_TARGET_UPDATE:String = "activityTargetUpdate";
    public static const ACTIVITY_TARGET_REWARD:String = "activityTargetReward";
    public static const ACTIVITY_COMPLETE_REWARD:String = "activityCompleteReward";

    public function COpenServerActivityEvent( type : String, data:Object = null ) {
        super( type );
        this.data = data;
    }

    public var data:Object;
}
}
