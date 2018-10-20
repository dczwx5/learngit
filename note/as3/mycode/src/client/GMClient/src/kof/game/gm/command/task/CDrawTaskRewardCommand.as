//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/18.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CDrawTaskRewardCommand extends CAbstractConsoleCommand{
    public function CDrawTaskRewardCommand() {
        super( );

        name = "drawTaskReward";
        description = "领取任务奖励，Usage：" + this.name + " gamePromptID";
        this.label = "领取任务奖励";

        this.syncToServer = true;
    }
}
}
