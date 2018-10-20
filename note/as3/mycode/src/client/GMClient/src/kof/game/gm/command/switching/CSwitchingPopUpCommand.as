//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.switching {

import QFLib.Foundation;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CSwitchingPopUpCommand extends CAbstractConsoleCommand {

    /**
     * Creates a new CSwitchingActivatedCommand
     */
    public function CSwitchingPopUpCommand( name : String = "st_popup",
                                            desc : String = "PopUp show an SystemBundle enabled by switching." ) {
        super( name, desc );
    }

    /**
     * @inheritDoc
     */
    override public function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) ) {
            if ( args.length <= 1 ) {
                Foundation.Log.logErrorMsg( "Arguments required in ConsoleCommand: " +
                        this.name );
                return false;
            }

            var idBundle : Number = Number( args[ 1 ] );
            if ( isNaN( idBundle ) ) {
                var tagBundle : String = String( args[ 1 ] );
                idBundle = SYSTEM_ID( tagBundle );
            }

            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( idBundle );
                if ( !pSystemBundle ) {
                    Foundation.Log.logWarningMsg( "No specified SystemBundle found by boundID: " + idBundle );
                } else {
                    pSystemBundleCtx.stopBundle( pSystemBundle ); // Make it stop first.

                    // triggered the validators.
                    var pSwitchingSystem :CAppSystem = system.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
                    if ( pSwitchingSystem ) {
                        var pTriggered:CSwitchingTriggerBridge = pSwitchingSystem.getHandler( CSwitchingTriggerBridge ) as CSwitchingTriggerBridge;
                        if ( pTriggered ) {
                            pTriggered.dispatchEvent( new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED ) );
                        }
                    }
                }
                return true;
            } else {
                Foundation.Log.logWarningMsg( "Unsupported boots, requires ISystemBundleContext." );
            }
        }
        return false;
    }

} // class CSwitchingActivatedCommand
} // package kof.game.switching.boots


