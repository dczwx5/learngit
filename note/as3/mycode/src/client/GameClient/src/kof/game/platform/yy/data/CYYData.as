//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/17.
 */
package kof.game.platform.yy.data {

import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;

public class CYYData extends CPlatformBaseData {
    public var client:int;
    public var yyVipGrade:int;
    public var cwVipLevel:int;
    public var yyLevel:int;
    public function CYYData()
    {
        super();
    }

    public override function updateData(data:Object) : void
    {
        if (!data) return ;
        //哪个平台登录
        this.client = data["client"];
        //会员等级
        this.yyVipGrade = data["yyVipGrade"];
        //超级会员等级
        this.cwVipLevel = data["cwVipLevel"];
        //yy等级 0 无等级 1 等级4以上 2 等级16以上 3等级40以上
        this.yyLevel = data["yyLevel"];
    }

    /**
     * yy大厅
     */
    public function get isYYHall() : Boolean {
        return client == EPlatformType.YY_CLIENT_YYDATING;
    }

    /**
     * 网页
     */
    public function get isWeb() : Boolean {
        return client == EPlatformType.YY_CLIENT_WEB;
    }

    /**
     * 微端
     */
    public function get isMicroClient() : Boolean {
        return client == EPlatformType.YY_CLIENT_WEIDUAN;
    }
}
}
