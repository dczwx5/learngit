//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.event {

import flash.events.Event;

public class CGemEvent extends Event{

    public static const UpdateGemHoleInfo:String = "UpdateGemHoleInfo";// 更新宝石孔信息
    public static const UpdateGemBagInfo:String = "UpdateGemBagInfo";// 更新宝石库信息
    public static const GemInfoInit:String = "GemInfoInit";// 登录时宝石信息初始化
    public static const UpdateGemCategoryList:String = "UpdateGemCategoryList";// 宝石合成分类列表更新

    public var data:Object;

    public function CGemEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
