//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.config {

import QFLib.Foundation;

import kof.framework.IConfiguration;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 设置配置项命令
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFConfigSetCommand extends CAbstractConsoleCommand {

    public function CKOFConfigSetCommand() {
        super( "set_config", "设置配置项: set_config key value" );
        syncToServer = false;
    }

    override public virtual function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) && args.length > 1 ) {
            var pConfig : IConfiguration = this.system.stage.getBean( IConfiguration ) as IConfiguration;
            if ( pConfig ) {
                var pOriginValue : * = pConfig.getRaw( args[ 1 ] );
                var pValue : * = undefined;
                if ( args.length > 2 )
                    pValue = args[ 2 ];

                pConfig.setConfig( args[ 1 ], pValue );

                if ( pOriginValue == undefined ) pOriginValue = "undefined";
                if ( pValue == undefined ) pValue = "undefined";
                if ( pOriginValue == null ) pOriginValue = null;
                if ( pValue == null ) pValue = null;

                Foundation.Log.logMsg( "Set config item value: " + pOriginValue.toString() + " => " + pValue.toString() );
                return true;
            }
        }
        return false;
    }

}
}
