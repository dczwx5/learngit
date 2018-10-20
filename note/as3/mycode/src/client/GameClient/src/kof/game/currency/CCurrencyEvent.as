//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/10/18.
 * Time: 15:47
 */
package kof.game.currency {

    import flash.events.Event;

    public class CCurrencyEvent extends Event {
        public static const BUY_GOLD : String = "buyGold";
        public static const BUY_VIT : String = "buyVit";
        public static const NOT_REMIND : String = "notRemind";
        public static const BUY_WEEK_OR_MONTH_CARD : String = "buyMonthCard";
        public static const UPDATE_QQData : String = "updateQQData";
        public var data : Object = null;

        public function CCurrencyEvent( type : String, data : Object = null ) {
            super( type );
            this.data = data;
        }
    }
}
