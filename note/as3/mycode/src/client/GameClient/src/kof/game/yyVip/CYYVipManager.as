//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/8.
 */
package kof.game.yyVip {

import kof.framework.CAbstractHandler;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyVip.data.CYYVipRewardData;

public class CYYVipManager extends CAbstractHandler {
    public function CYYVipManager() {
        super();

        data = new CYYVipRewardData();
    }

    public var data:CYYVipRewardData;
}
}
