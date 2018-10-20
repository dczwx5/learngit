//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/2.
//----------------------------------------------------------------------
package kof.game.gm.command.lobby {

import kof.game.character.fight.CFightHandler;
import kof.game.core.CECSLoop;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.lobby.CLobbySystem;


public class CFightBeginCommand extends CAbstractConsoleCommand{

    public function CFightBeginCommand( name : String = "fight_begin", desc : String = "Execute the dummy fight." ) {
        super( name , desc );
    }

    override public virtual function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) ) {
            var pCESLoopSys : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
            var pLobbySys : CLobbySystem = system.stage.getSystem(CLobbySystem) as CLobbySystem;
            if ( pLobbySys ) {
                pLobbySys.fightUIEnabled = true;
            }

            if( pCESLoopSys )
            {
                var pFightHandle : CFightHandler = pCESLoopSys.getHandler( CFightHandler ) as CFightHandler;
                pFightHandle.enabled = true;
            }
            return true;
        }

        return false;
    }
}
}
