//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/14.
 */
package kof.game.gm.command.arena {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CArenaRefreshWorshipCommand extends CAbstractConsoleCommand {
    public function CArenaRefreshWorshipCommand( ) {
        super();
        this.name = "arena_refresh_worship";
        this.description = "刷新当前玩家的所有膜拜与被膜拜次数";
        this.label = "刷新当前玩家的所有膜拜与被膜拜次数";

        this.syncToServer = true;
    }
}
}
