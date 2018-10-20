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
public class CModifyCharacterPropertyCommand extends CAbstractConsoleCommand {

    public function CModifyCharacterPropertyCommand() {
        super();

        this.name = "modifyAttr";
        this.description = "修改人物属性，Usage：" + this.name + " uid type value";
        this.label = "修改人物属性";

        this.syncToServer = true;
    }

}
}
