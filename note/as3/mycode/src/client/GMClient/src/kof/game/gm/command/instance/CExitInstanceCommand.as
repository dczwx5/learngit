//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.framework.INetworking;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.instance.CInstanceSystem;
import kof.util.CAssertUtils;

/**
 * 退出副本命令
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CExitInstanceCommand extends CAbstractConsoleCommand {

    /**
     * Creates a new CEnterInstanceCommand.
     */
    public function CExitInstanceCommand() {
        super();

        this.name = "exit_instance";
        this.description = "退出当前副本，Usage：" + this.name;
        this.label = "退出副本";

        this.syncToServer = true;
    }
}
}
