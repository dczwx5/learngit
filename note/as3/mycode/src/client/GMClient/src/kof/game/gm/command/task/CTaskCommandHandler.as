//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/17.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CTaskCommandHandler extends CAbstractCommandHandler {
    public function CTaskCommandHandler() {
        super();
    }
    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CTaskListExpCommand());
        ret = ret && this.registerConsoleCommand(new CDrawTaskRewardCommand());
        ret = ret && this.registerConsoleCommand(new CTaskDrawdActiveRewardCommand());
        ret = ret && this.registerConsoleCommand(new CTaskNpcDialougeCommand());
        ret = ret && this.registerConsoleCommand(new CTaskSubmitExpCommand());

        return ret;
    }
}
}
