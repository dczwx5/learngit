//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/14.
 */
package kof.game.gm.command.arena {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 * 竞技场调试命令控制器
 *
 * @author Dendi (dendi@qifun.com)
 */
public class CArenaCommandHandler extends CAbstractCommandHandler {
    public function CArenaCommandHandler() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( new CArenaChangeRankCommand() );
        ret = ret && this.registerConsoleCommand( new CArenaRefreshWorshipCommand() );


        return ret;
    }
}
}
