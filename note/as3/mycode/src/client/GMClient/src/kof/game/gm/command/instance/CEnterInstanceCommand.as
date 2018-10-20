//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
 * 进入副本命令
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CEnterInstanceCommand extends CAbstractConsoleCommand {

    /**
     * Creates a new CEnterInstanceCommand.
     */
    public function CEnterInstanceCommand() {
        super();

        this.name = "enter_instance";
        this.description = "请求进入指定副本，Usage：" + this.name + " instanceID";
        this.label = "进入副本";

        this.syncToServer = true;
    }

}
}
