//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/4.
 */
package kof.game.bootstrap {

import flash.events.Event;

public class CBootstrapEvent extends  Event{

    public static const SINGLE_PINGPONG_TIME_DELAY : String = "single_pingpong_time_delay";//单个（比较精准）

    public static const AVERAGE_PINGPONG_TIME_DELAY : String = "average_pingpong_time_delay";//平均

    public static const NET_DELAY_RESPONSE : String = "net_delay_response";//后来传来的

    public function CBootstrapEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
