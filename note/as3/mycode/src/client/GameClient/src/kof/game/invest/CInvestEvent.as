//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/1/4.
 */
package kof.game.invest {

import flash.events.Event;

public class CInvestEvent extends Event {

    public static const INVEST_INIT_DATA_RESPONSE:String = "invest_init_data_response";
    public static const SHOW_INVEST_VIEW:String = "show_invest_view";
    public static const INVEST_DATA_RESPONSE:String = "invest_data_response";
    public static const INVEST_GET_AWARD_RESPONSE:String = "invest_get_award_response";

    public function CInvestEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
