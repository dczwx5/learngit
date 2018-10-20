//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/14.
 */
package kof.game.gm.command.arena {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CArenaChangeRankCommand extends CAbstractConsoleCommand {
    public function CArenaChangeRankCommand( ) {
        super();
        this.name = "arena_change_rank";
        this.description = "直接和xxx(排名)互换排名，如send arena_change_rank 100";
        this.label = "直接和xxx(排名)互换排名，如send arena_change_rank 100";

        this.syncToServer = true;
    }
}
}
