//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.vip {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CVipCommandHandler extends CAbstractCommandHandler {
    public function CVipCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CAddNotVipBlueCommand());

        return ret;
    }
}
}
