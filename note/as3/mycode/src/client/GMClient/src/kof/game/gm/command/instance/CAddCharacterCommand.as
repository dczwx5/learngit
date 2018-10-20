//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
 * 添加某个角色指令
 *
 * @author auto (auto@qifun.com)
 */
public class CAddCharacterCommand extends CAbstractConsoleCommand {

    public function CAddCharacterCommand() {
        super();

        this.name = "addObject";
        this.description = "添加指定人物，Usage：" + this.name + " monsterID count camp  x y";
        this.label = "添加指定人物";

        this.syncToServer = true;
    }

}
}
