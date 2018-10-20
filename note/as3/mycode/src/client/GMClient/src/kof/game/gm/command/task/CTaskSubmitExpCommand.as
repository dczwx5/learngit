//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/18.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CTaskSubmitExpCommand extends CAbstractConsoleCommand{
    public function CTaskSubmitExpCommand() {
        super();


        name = "submit_task";
        description = "提交任务，Usage：" + this.name + " taskID";
        this.label = "提交任务";

        this.syncToServer = true;
    }
}
}
