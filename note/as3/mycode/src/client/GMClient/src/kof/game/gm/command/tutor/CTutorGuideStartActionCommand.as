//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 从Action推导引导组启动
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorGuideStartActionCommand extends CAbstractConsoleCommand {

    public function CTutorGuideStartActionCommand() {
        super();

        this.name = "startGuideAction";
        this.description = "根据引导ActionID启动系统指引，Usage：" + this.name + " <ActionTutorID> ...";
        this.label = "启动ActionID系统指引";
    }

    override public function onCommand( args : Array ) : Boolean {
        // request server for entering instance.
        if ( super.onCommand( args ) ) {
            if ( args.length <= 1 )
                return false;
            var id : int = parseInt( args[ 1 ] );
            var pTutorSystem : CTutorSystem = this.system.stage.getSystem( CTutorSystem ) as CTutorSystem;
            if ( pTutorSystem ) {
                var pHandler : CTutorHandler = pTutorSystem.getHandler( CTutorHandler ) as CTutorHandler;
                if ( pHandler ) {
                    pHandler.startByActionIndexID( id );
                }
                return true;
            }
        }

        return false;
    }
}
}
