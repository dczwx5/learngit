//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/15.
 * Time: 17:20
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CAddBlueDiamondCommand extends CAbstractConsoleCommand {
    public function CAddBlueDiamondCommand( name : String = null, desc : String = null ) {
        super( name, desc );
        this.name = "add_blue_diamond";
        this.description = "增加蓝钻，Usage：" + this.name + " addValue";
        this.label = "增加蓝钻";

        this.syncToServer = true;
    }
}
}