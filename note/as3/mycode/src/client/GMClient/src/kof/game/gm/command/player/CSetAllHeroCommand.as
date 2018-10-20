//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.player {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CSetAllHeroCommand extends CAbstractConsoleCommand {
    public function CSetAllHeroCommand() {
        super();

        name = "set_all_hero";
        description = "设置所有格斗家等级品质星级，Usage：" + this.name + " 等级 品质 星级";
        this.label = "设置所有格斗家等级品质星级";

        this.syncToServer = true;
    }
}
}
