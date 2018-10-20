//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/15.
 * Time: 17:22
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CAddGoldCommand extends CAbstractConsoleCommand {
    public function CAddGoldCommand( name : String = null, desc : String = null ) {
        super( name, desc );
        this.name = "add_gold";
        this.description = "增加金币，Usage：" + this.name + " addValue";
        this.label = "增加金币";

        this.syncToServer = true;
    }
}
}
