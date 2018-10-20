//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.boots {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CBootstrapCommandHandler extends CAbstractCommandHandler {

    public function CBootstrapCommandHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( CSendToServerConsoleCommand );

        return ret;
    }

}
}
