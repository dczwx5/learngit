//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.bag {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CAddTypeItemCommand extends CAbstractConsoleCommand {
    public function CAddTypeItemCommand() {
        super();

        name = "add_type_item";
        description = "加某种类型的所有道具，Usage：" + this.name + " type count";
        this.label = "加某种类型的所有道具";

        this.syncToServer = true;
    }
}
}
