//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/18.
 */
package kof.game.gm.command.task {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CTaskNpcDialougeCommand extends CAbstractConsoleCommand {
    public function CTaskNpcDialougeCommand( ) {
        super( );

        name = "npc_dialouge";
        description = "npc对话，Usage：" + this.name + " npcID talkID";
        this.label = "npc对话";

        this.syncToServer = true;
    }
}
}
