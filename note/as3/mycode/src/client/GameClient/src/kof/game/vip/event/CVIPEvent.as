/**
 * Created by Administrator on 2017/6/15.
 */
package kof.game.vip.event {

import flash.events.Event;

public class CVIPEvent extends Event {

    public static const VIP_BUYGIFT:String = "VipBuyGift";//购买特权礼包
    public static const VIP_GET_FREE_GIFT:String = "VipGetFreeGift";//领取vip免费礼包
    public static const VIP_GET_EVERYDAYREWARD:String = "vip_get_everydayreward";//领取每日礼包

    public function CVIPEvent( type : String, data:Object = null ) {
        super( type );
        this.data = data;
    }

    public var data:Object;
}
}
