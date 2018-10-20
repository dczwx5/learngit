//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/22.
 */
package kof.game.platform.sevenK {

import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;

/**
 * 7k7k平台数据
 */
public class C7KData extends CPlatformBaseData{

    /** vip类型 */
    public var vipType : int;
    /** 会员过期时间 */
    public var vipExpired : Number;

    public function C7KData()
    {
    }

    public override function updateData(data:Object) : void
    {
        if (!data) return ;

        this.pf = data["pf"];

        this.vipType = data["vipType"];
        this.vipExpired = data["vipExpired"];
    }

    /**
     * yy大厅
     */
    public function get isYYHall() : Boolean {
        return pf == EPlatformType.TYPE_QQ_ZONE;
    }

    /**
     * 网页
     */
    public function get isWeb() : Boolean {
        return pf == EPlatformType.TYPE_QQ_ZONE;
    }

    /**
     * 微端
     */
    public function get isMicroClient() : Boolean {
        return pf == EPlatformType.TYPE_QQ_ZONE;
    }
}
}
