//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/17.
 */
package kof.game.gm.command.mail {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CMailCommandHandler extends CAbstractCommandHandler {
    public function CMailCommandHandler() {
        super();
    }
    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CAddMailCommand());

        return ret;
    }
}
}
