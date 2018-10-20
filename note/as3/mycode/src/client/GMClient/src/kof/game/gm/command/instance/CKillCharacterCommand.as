//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
 * 杀死某个角色指令
 *
 * @author auto (auto@qifun.com)
 */
public class CKillCharacterCommand extends CAbstractConsoleCommand {

    public function CKillCharacterCommand() {
        super();

        this.name = "removeOneObject";
        this.description = "杀死指定人物，Usage：" + this.name + " uid type";
        this.label = "杀死指定人物";

        this.syncToServer = true;
    }

}
}
