//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.support {

import flash.events.Event;
import flash.external.ExternalInterface;

import kof.framework.CAbstractHandler;
import kof.framework.IApplication;
import kof.net.CNetworkSystem;

import mx.events.Request;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDisconnectLogHandler extends CAbstractHandler {

    public function CDisconnectLogHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initialize();
        return ret;
    }

    private function initialize() : Boolean {
        var pNetworking : CNetworkSystem = system.stage.getSystem( CNetworkSystem ) as CNetworkSystem;
        if ( pNetworking ) {
            pNetworking.addEventListener( Event.CLOSE, _onNetworkingCloseEventHandler, false, 0, true );
        }
        var pApp : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( pApp && pApp.eventDispatcher ) {

        }
        return true;
    }

    private function _onNetworkingCloseEventHandler( event : Event ) : void {
        var pApp : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( pApp && pApp.eventDispatcher ) {
            var data : Object = {};
            pApp.eventDispatcher.dispatchEvent( new Request( "GET_CRASH_LOG", false, false, data ) );
            logIfExternalizeAbsent( data );
        }
    }

    private function logIfExternalizeAbsent( pData : Object ) : void {
        if ( !pData )
            return;

        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "report_disconn_crash", pData );
            } catch ( e : Error ) {
                // ignore.
            }
        }
    }


}
}
