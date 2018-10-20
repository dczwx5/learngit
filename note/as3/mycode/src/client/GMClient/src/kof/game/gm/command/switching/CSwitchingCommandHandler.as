//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.switching {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;


/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingCommandHandler extends CAbstractCommandHandler {

    /**
     * Creates a new CSwitchingCommandHandler.
     */
    public function CSwitchingCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand( CSwitchingActivatedCommand );
        ret = ret && this.registerConsoleCommand( CSwitchingSetNotifyCommand );
        ret = ret && this.registerConsoleCommand( CSwitchingAddCommand );
        ret = ret && this.registerConsoleCommand( CSwitchingRemoveCommand );
        ret = ret && this.registerConsoleCommand( CSwitchingPopUpCommand );
        return ret;
    }

} // class CSwitchingCommandHandler
} // package kof.game.switching.boots

