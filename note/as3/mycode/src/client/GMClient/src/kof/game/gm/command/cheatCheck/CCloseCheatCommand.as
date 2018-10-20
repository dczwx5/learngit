//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.cheatCheck {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CCloseCheatCommand extends CAbstractConsoleCommand {
    public function CCloseCheatCommand() {
        super();
        this.name = "close_cheat";
        this.description = "关闭作弊检测，Usage：" + this.name;
        this.label = "关闭作弊检测";

        this.syncToServer = true;
    }
}
}
