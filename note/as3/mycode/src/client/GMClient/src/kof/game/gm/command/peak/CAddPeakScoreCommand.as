//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.peak {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CAddPeakScoreCommand extends CAbstractConsoleCommand {
    public function CAddPeakScoreCommand() {
        super();
        this.name = "add_peak_score";
        this.description = "加巅峰赛积分，Usage：" + this.name + " addValue";
        this.label = "加巅峰赛积分";

        this.syncToServer = true;
    }
}
}
