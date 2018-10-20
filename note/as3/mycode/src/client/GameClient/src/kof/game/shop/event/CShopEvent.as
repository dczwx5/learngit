//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/5/11.
 */
package kof.game.shop.event {

import flash.events.Event;

public class CShopEvent extends Event {

    public static const SHOP_LIST_UPDATE:String = "shopListUpdate";//更新商店列表
    public static const SHOP_ITEM_UPDATE:String = "shopItemUpdate";//更新商品信息

    public static const SHOP_REMIND_COME:String = "shopRemindCome";//神秘商店来袭

    public function CShopEvent( type : String, data:Object = null ) {
        super( type );
        this.data = data;
    }

    public var data:Object;
}
}
