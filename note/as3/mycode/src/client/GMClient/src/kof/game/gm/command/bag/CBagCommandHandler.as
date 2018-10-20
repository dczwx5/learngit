//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/28.
 */
package kof.game.gm.command.bag {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CBagCommandHandler extends CAbstractCommandHandler {
    public function CBagCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CBagAddItemExpCommand());
        ret = ret && this.registerConsoleCommand(new CAddTypeItemCommand());

        return ret;
    }

}
}
