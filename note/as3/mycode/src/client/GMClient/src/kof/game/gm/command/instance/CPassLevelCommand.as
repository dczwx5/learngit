//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 通过关卡
 *
 * @author auto (auto@qifun.com)
 */
public class CPassLevelCommand extends CAbstractConsoleCommand {

    public function CPassLevelCommand() {
        super();

        this.name = "pass_level";
        this.description = "通过关卡，Usage：" + this.name;
        this.label = "通过关卡";

        this.syncToServer = true;
    }

}
}
