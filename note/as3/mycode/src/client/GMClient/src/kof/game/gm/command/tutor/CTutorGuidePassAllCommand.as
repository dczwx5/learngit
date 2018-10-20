//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CTutorGuidePassAllCommand extends CAbstractConsoleCommand {

    public function CTutorGuidePassAllCommand() {
        super();

        this.name = "passAllGuideTutor";
        this.description = "通过所有系统指引，Usage：" + this.name + " ...";
        this.label = "通过所有系统指引";
    }

    override public function onCommand( args : Array ) : Boolean {
        // request server for entering instance.
        if ( super.onCommand( args ) ) {
            var pTutorSystem : CTutorSystem = this.system.stage.getSystem( CTutorSystem ) as CTutorSystem;
            if ( pTutorSystem ) {
                pTutorSystem.manager.stopTutor();
                pTutorSystem.netHandler.sendTutorFinish( 65535 );
                return true;
            }
        }

        return false;
    }
}
}
