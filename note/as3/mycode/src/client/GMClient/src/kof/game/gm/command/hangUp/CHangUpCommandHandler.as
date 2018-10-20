//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/4/12.
 */
package kof.game.gm.command.hangUp {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CHangUpCommandHandler extends CAbstractCommandHandler {
    public function CHangUpCommandHandler() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new COpenHangUpViewCommand());
        ret = ret && this.registerConsoleCommand(new CCloseHangUpSystemCommand());

        return ret;
    }
}
}
