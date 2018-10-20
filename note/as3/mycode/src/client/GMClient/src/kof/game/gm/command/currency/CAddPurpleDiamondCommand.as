//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/15.
 * Time: 17:21
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CAddPurpleDiamondCommand extends CAbstractConsoleCommand {
    public function CAddPurpleDiamondCommand( name : String = null, desc : String = null ) {
        super( name, desc );
        this.name = "add_purple_diamond";
        this.description = "增加紫钻，Usage：" + this.name + " addValue";
        this.label = "增加紫钻";

        this.syncToServer = true;
    }
}
}
