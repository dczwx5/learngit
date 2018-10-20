//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.player {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 * 玩家指令
 *
 * @author auto
 */
public class CPlayerCommandHandler extends CAbstractCommandHandler {
    public function CPlayerCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CAddPlayerExpCommand());
        ret = ret && this.registerConsoleCommand(new CAddAllHeroCommand());
        ret = ret && this.registerConsoleCommand(new CAddSingleHeroCommand());
        ret = ret && this.registerConsoleCommand(new CSetAllHeroCommand());

        return ret;
    }

}
}
