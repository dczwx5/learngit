//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.lobby {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 * 游戏大厅（调试）控制台命令控制器管理
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLobbyCommandHandler extends CAbstractCommandHandler {

    /**
     * Creates a new CLobbyCommandHandler.
     */
    public function CLobbyCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand( CLobbyShowCommand );
        ret = ret && this.registerConsoleCommand( CLobbyHideCommand );
        ret = ret && this.registerConsoleCommand( CFightBeginCommand );
        return ret;
    }

}
}
