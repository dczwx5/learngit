//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.message {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 * 用于CDynamicPackMessage的GM命令控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFDynamicPackCommandHandler extends CAbstractCommandHandler {

    public function CKOFDynamicPackCommandHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( new CKOFDynamicPackCommand() );

        return ret;
    }
}
}


