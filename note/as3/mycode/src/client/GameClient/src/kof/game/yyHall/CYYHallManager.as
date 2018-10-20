//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.yyHall {

import kof.framework.CAbstractHandler;
import kof.game.yyHall.data.CYYRewardData;

public class CYYHallManager extends CAbstractHandler {

    public function CYYHallManager()
    {
        super();

        data = new CYYRewardData();
    }

    public var data:CYYRewardData;
}
}
