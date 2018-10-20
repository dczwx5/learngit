//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/22.
 */
package kof.game.gm.command.focusLost {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CFocusLostCommandHandler extends CAbstractCommandHandler {
    public function CFocusLostCommandHandler()
    {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CFocusLostCancelCommand());
        ret = ret && this.registerConsoleCommand(new CFocusLostOpenCommand());

        return ret;
    }
}
}
