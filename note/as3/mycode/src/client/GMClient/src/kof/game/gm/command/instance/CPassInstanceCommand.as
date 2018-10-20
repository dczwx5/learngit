//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 通过副本
 *
 * @author auto (auto@qifun.com)
 */
public class CPassInstanceCommand extends CAbstractConsoleCommand {

    public function CPassInstanceCommand() {
        super();

        this.name = "pass_instance";
        this.description = "请求通过副本";
        this.label = "通过副本";

        this.syncToServer = true;
    }
}
}
