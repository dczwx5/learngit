//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.boots {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.message.GM.GMCommandRequest;
import kof.util.CAssertUtils;

public class CSendToServerConsoleCommand extends CAbstractConsoleCommand {

    public function CSendToServerConsoleCommand( name : String = null, desc : String = null ) {
        super( name, desc );

        this.name = "send";
        this.description = "Send the arguments as GM boots to the server.";
        this.syncToServer = false;
    }

    override public virtual function onCommand( args : Array ) : Boolean {
        if ( super.onCommand( args ) ) {
            if ( args && args.length >= 2 ) {
                var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
                CAssertUtils.assertNotNull( request );

                request.command = args[ 1 ];
                request.args = args.slice( 2 );

                this.networking.send( request );
                return true;
            }
        }
        return false;
    }
}
}
