//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/17.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CTaskListExpCommand extends CAbstractConsoleCommand {
    public function CTaskListExpCommand( ) {
        super();


        name = "task_list";
        this.description = "玩家任务列表";
        this.label = "玩家任务列表";

        this.syncToServer = true;
    }
}
}
