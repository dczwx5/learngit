//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.config {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 * 配置GM命令管理器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFConfigCommandHandler extends CAbstractCommandHandler {

    public function CKOFConfigCommandHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( CKOFConfigFindCommand );
        ret = ret && this.registerConsoleCommand( CKOFConfigSetCommand );

        return ret;
    }

}
}
