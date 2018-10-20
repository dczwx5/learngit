//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 系统指引
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorGuideCommand extends CAbstractConsoleCommand {

    public function CTutorGuideCommand() {
        super();

        this.name = "startGuideTutor";
        this.description = "执行系统指引，Usage：" + this.name + " <tutor group id>";
        this.label = "执行系统指引";
    }

    override public function onCommand( args : Array ) : Boolean {
        // request server for entering instance.
        if ( super.onCommand( args ) ) {
            if ( args.length <= 1 )
                    return false;
            var id : int = parseInt( args[ 1 ] );
            var pTutorSystem : CTutorSystem = this.system.stage.getSystem( CTutorSystem ) as CTutorSystem;
            if ( pTutorSystem ) {
                pTutorSystem.manager.startTutor( id );
                return true;
            }
        }

        return false;
    }

}
}
