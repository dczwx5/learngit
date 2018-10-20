//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;
import kof.game.instance.CInstanceSystem;

/**
 * 副本调试命令控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CInstanceCommandHandler extends CAbstractCommandHandler {

    /**
     * Creates a new CInstanceCommandHandler.
     */
    public function CInstanceCommandHandler() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.registerConsoleCommand( new CEnterInstanceCommand() );
        ret = ret && this.registerConsoleCommand( new CExitInstanceCommand() );
        ret = ret && this.registerConsoleCommand( new CPassInstanceCommand() );
        ret = ret && this.registerConsoleCommand( new CPassAllInstanceCommand() );
        ret = ret && this.registerConsoleCommand( new CRemoveOneCampCommand() );
        ret = ret && this.registerConsoleCommand( new CRemoveAllCampCommand() );
        ret = ret && this.registerConsoleCommand( new CRemoveOneDiffCampCommand() );
        ret = ret && this.registerConsoleCommand( new CRemoveAllDiffCampCommand() );
        ret = ret && this.registerConsoleCommand( new CKillCharacterCommand() );
        ret = ret && this.registerConsoleCommand( new CAddCharacterCommand() );
        ret = ret && this.registerConsoleCommand( new CPassLevelCommand() );
        ret = ret && this.registerConsoleCommand( new CModifyCharacterPropertyCommand() );


        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        // NOOP.
        return ret;
    }

}
}
