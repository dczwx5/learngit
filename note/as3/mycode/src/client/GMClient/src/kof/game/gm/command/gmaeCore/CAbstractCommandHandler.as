//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.gmaeCore {

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.IConsoleCommand;

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.util.CAssertUtils;

/**
 * GM命令抽象的AppSystem控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractCommandHandler extends CAbstractHandler {

    /**
     * Creates a new CAbstractCommandHandler.
     */
    public function CAbstractCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        // NOOP.
    }

    protected function registerConsoleCommand( clsOrInstance : * ) : Boolean {
        var cmd : IConsoleCommand = null;
        if ( clsOrInstance is Class ) {
            var cls : Class = clsOrInstance as Class;
            cmd = new cls;
        } else {
            cmd = clsOrInstance as IConsoleCommand;
        }

        CAssertUtils.assertNotNull( cmd, "clsOrInstance is none of class or" +
                " instance implements from IConsoleCommand." );

        if ( cmd is CAbstractConsoleCommand ) {
            (cmd as CAbstractConsoleCommand).m_pSystem = this.system;
        }

        return this.addBean( cmd );
    }

    public function get dashBoard() : CDashBoard {
        if ( system && system.stage ) {
            return system.stage.getBean( CDashBoard ) as CDashBoard;
        }
        return null;
    }

    public function get consolePage() : CConsolePage {
        var pDashBoard : CDashBoard = this.dashBoard;
        if ( pDashBoard ) {
            return pDashBoard.findPage( "ConsolePage" ) as CConsolePage;
        }
        return null;
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        var pConsolePage : CConsolePage = this.consolePage;
        if ( pConsolePage ) {
            var pNetworking : INetworking = system.stage.getBean( INetworking ) as INetworking;
            for each ( var o : Object in this.beanIterator ) {
                var cmd : IConsoleCommand = o.object as IConsoleCommand;
                if ( cmd ) {
                    // add to console page.
                    pConsolePage.commandHandler.commandMap.remove(cmd.name);
                    pConsolePage.commandHandler.registerCommand( cmd );
                    if ( cmd is CAbstractConsoleCommand ) {
                        (cmd as CAbstractConsoleCommand).networking  = pNetworking;
                    }
                }
            }
        }
    }

}
}
