//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/18.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CTaskDrawdActiveRewardCommand extends CAbstractConsoleCommand{
    public function CTaskDrawdActiveRewardCommand() {

        super( );

        name = "drawdActiveReward";
        description = "领取活跃奖励，Usage：" + this.name + " rewardID";
        this.label = "领取活跃奖励";

        this.syncToServer = true;

    }
}
}
