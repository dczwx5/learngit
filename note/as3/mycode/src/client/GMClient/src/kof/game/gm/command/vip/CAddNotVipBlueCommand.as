//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.vip {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CAddNotVipBlueCommand extends CAbstractConsoleCommand {
    public function CAddNotVipBlueCommand() {
        super();

        this.name = "add_not_vip_blue";
        this.description = "添加蓝钻但不加vip经验，Usage：" + this.name + " addValue";
        this.label = "添加蓝钻但不加vip经验";

        this.syncToServer = true;
    }
}
}
