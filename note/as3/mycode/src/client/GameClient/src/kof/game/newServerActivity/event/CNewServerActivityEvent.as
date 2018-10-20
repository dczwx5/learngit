//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/25.
 */
package kof.game.newServerActivity.event {

import flash.events.Event;

public class CNewServerActivityEvent extends Event {

    public static const NEW_SERVER_ACTIVITY_DAY_UPDATE : String = "newServerActivityDayUpdate" ;// 开服天数的更新
    public static const NEW_SERVER_ACTIVITY_DATE_UPDATE : String = "newServerActivityDateUpdate" ;//新服活动数据更新
    public static const NEW_SERVER_ACTIVITY_UPDATE : String = "newServerActivityUpdate";//选择活动事件
    public static const NEW_SERVER_ACTIVITY_RANK_UPDATA : String = "newServerActivityRankUpdate";//排行榜更新
    public static const NEW_SERVER_ACTIVITY_TIPS_UPDATE : String = "newServerActivityTipsUpdate";//小红点数据更新
    public static const NEWSERVERRANKACTIVITYSTATERESPONSE : String = "newserverrankactivitystateresponse";

    public function CNewServerActivityEvent( type : String, data : Object = null ) {
        super( type );
        this.data = data;
    }

    public var data : Object;
}
}
