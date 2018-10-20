//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/30.
 */
package kof.game.bossChallenge.event {

import flash.events.Event;

public class CBossChallengeEvent extends Event{

    public static const REFRESH_VIEW : String = "refreshView";//刷新界面
    public static const REMOVE_VIEW : String = "removeView";//关闭界面
    public static const OPEN_INVITE : String = "openInvite";//打开协助面板
    public static const OPEN_RESULT : String = "openResult";//打开结算界面
    public static const EXIT_INSTANCE : String = "exitInstance";//退出副本


    public var data:Object;
    public function CBossChallengeEvent(type:String,data:Object = null) {
        super(type);
        this.data = data;
    }

}

}