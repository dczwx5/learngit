//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.player {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 增加战队经验指令
 *
 * @author auto
 */
public class CAddPlayerExpCommand extends CAbstractConsoleCommand {
    public function CAddPlayerExpCommand() {
        super();

        this.name = "add_exp";
        this.description = "增加玩家经验，Usage：" + this.name + " addValue";
        this.label = "增加玩家经验";

        this.syncToServer = true;
    }


}
}
