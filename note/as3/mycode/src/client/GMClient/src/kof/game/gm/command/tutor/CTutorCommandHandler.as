//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

public class CTutorCommandHandler extends CAbstractCommandHandler {
    public function CTutorCommandHandler() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( new CTutorCommand(system.stage.getSystem(CTutorSystem) as CTutorSystem) );
        ret = ret && this.registerConsoleCommand( new CTutorGuideCommand() );
        ret = ret && this.registerConsoleCommand( new CTutorGuideStopCommand() );
        ret = ret && this.registerConsoleCommand( new CTutorGuideStartActionCommand() );
        ret = ret && this.registerConsoleCommand( new CTutorGuidePassAllCommand() );
        ret = ret && this.registerConsoleCommand( new CTutorGuideCloseStartGroupConditionCommand() );

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        // NOOP.
        return ret;
    }

}
}
