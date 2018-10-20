//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/15.
 * Time: 17:15
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CAddVitCommand extends CAbstractConsoleCommand {
    public function CAddVitCommand( name : String = null, desc : String = null ) {
        super( name, desc );
        this.name = "add_vit";
        this.description = "增加体力，Usage：" + this.name + " addValue";
        this.label = "增加体力";

        this.syncToServer = true;
    }
}
}
