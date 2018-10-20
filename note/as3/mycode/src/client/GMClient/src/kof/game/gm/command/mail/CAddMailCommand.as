//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/17.
 */
package kof.game.gm.command.mail {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CAddMailCommand extends CAbstractConsoleCommand {
    public function CAddMailCommand() {
        super();

        name = "add_mail";
        description = "添加邮件(附件参数为可选)，Usage：" + this.name + " baseID resourceID:count";
        this.label = "添加邮件";

        this.syncToServer = true;
    }
}
}
