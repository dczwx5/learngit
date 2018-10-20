//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/5.
 * Time: 17:20
 */
package kof.game.sign.signFacade.signSystem {

    import flash.events.Event;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/5
     */
    public class CSignEvent extends Event {
        public static const UPDATE_DATA : String = "updateData";
        public static const TOTAL_REWARD_GET_SUCCESS : String = "totalRewardGetSuccess";
        public var data : Object = null;

        public function CSignEvent( type : String, data : Object = null ) {
            super( type );
            this.data = data;
        }
    }
}
