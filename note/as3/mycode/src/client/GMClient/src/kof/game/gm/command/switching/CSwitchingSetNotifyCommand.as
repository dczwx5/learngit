//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.switching {

import QFLib.Foundation;

import kof.SYSTEM_ID;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CSwitchingSetNotifyCommand extends CAbstractConsoleCommand {

    /**
     * Creates a new CSwitchingActivatedCommand
     */
    public function CSwitchingSetNotifyCommand( name : String = "st_notify",
                                                desc : String = "Notify the specified SystemBundle by switching." ) {
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
                    var pValue : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, "notification", false );
                    pSystemBundleCtx.setUserData( pSystemBundle, "notification", !pValue );
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


