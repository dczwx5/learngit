//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.message {
/**
 * Created by user on 2017/8/5.
 */

    import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.message.CDynamicPackMessage;

    public class CKOFDynamicPackCommand extends CAbstractConsoleCommand {

        public function CKOFDynamicPackCommand() {
            super( "dynp", "动态封包命令：dynp \"tokenId\" [data sequence ...]" );
            syncToServer = false;
        }

        override public virtual function onCommand( args : Array ) : Boolean {

            var title : String = args.shift();
            var tokenID : int = args.shift();
            var commandLine : String = args.join( " " );

            var arr : Array = JSON.parse( commandLine ) as Array;

            // dynp 123 [1, 2, 3, { "name": "hello" }]
            // 123 1 "abc edf"
            // args = [ 1, "abc, edf" ];
            // args = [ 1, "abc edf" ];

            var msg : CDynamicPackMessage = new CDynamicPackMessage();
            msg.setToken( tokenID );
            msg.setData( arr );

            return networking.send( msg );


    //        if ( super.onCommand( args ) && args.length > 1 ) {
    //            for each (var v : * in args) {
    //                Foundation.Log.logWarningMsg("    " + v);
    //            }
    //        }
    //        return false;
        }

    }

}