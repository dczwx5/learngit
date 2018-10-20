//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.lobby {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.lobby.CLobbySystem;

/**
 * 显示主界面
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CLobbyShowCommand extends CAbstractConsoleCommand {

    static private const DEFAULT_DURATION : Number = 1.0;

    public function CLobbyShowCommand( name : String = "lobby_show", desc : String = "Execute the show effect on lobby view." ) {
        super( name, desc );
        this.syncToServer = false;
        this.label = "显示主界面";

    }

    override public virtual function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) ) {
            var fDuration : Number = args.length > 1 ? Number( args[ 1 ] ) : NaN;
            var bTween : Boolean = !isNaN( fDuration );

            var pLobbySys : CLobbySystem = system.stage.getSystem(CLobbySystem) as CLobbySystem;
            if ( pLobbySys ) {
//                pLobbySys.tweenEffect = bTween;
//                pLobbySys.enabled = true;
                pLobbySys.slideOut();
            }
            return true;
        }

        return false;
    }

}
}
