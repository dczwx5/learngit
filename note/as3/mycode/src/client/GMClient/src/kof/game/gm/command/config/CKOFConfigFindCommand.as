//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.config {

import QFLib.Foundation;

import kof.framework.IConfiguration;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 查找配置项命令
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFConfigFindCommand extends CAbstractConsoleCommand {

    public function CKOFConfigFindCommand() {
        super( "find_config", "查找配置项: find_config key" );
        syncToServer = false;
    }

    override public virtual function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) && args.length > 1 ) {
            var pConfig : IConfiguration = this.system.stage.getBean( IConfiguration ) as IConfiguration;
            if ( pConfig ) {
                var pValue : * = pConfig.getRaw( args[ 1 ] );
                if ( pValue == undefined )
                    Foundation.Log.logMsg( "underfined" );
                else if ( null == pValue )
                    Foundation.Log.logMsg( "null" );
                else
                    Foundation.Log.logMsg( pValue.toString() );
                return true;
            }
        }
        return false;
    }

}
}
