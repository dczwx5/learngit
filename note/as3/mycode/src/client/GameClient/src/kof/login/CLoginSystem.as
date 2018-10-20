//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import QFLib.Interface.IUpdatable;

import flash.external.ExternalInterface;
import flash.system.Capabilities;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLoginSystem extends CAppSystem implements IUpdatable {

    public function CLoginSystem() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            // CLoginHandler is a CSystemHandler, so CLoginSystem.handler is a instance of CLoginHandler.
            this.addBean( new CLoginHandler() );
//            this.addBean( new CLoginViewHandler() );
        }

        return ret;
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        // Invoke on current CAppStage setup completed.
        this.login();
    }

    public function login() : void {
        LOG.logTraceMsg( "Ready to login to server, retrieves the networking interface and send the login packet." );

        var pLoginData : CLoginData = new CLoginData();

        if ( ExternalInterface.available ) {
            pLoginData.userAgent = ExternalInterface.call( "eval", "navigator.userAgent" );
        } else {
            pLoginData.userAgent = Capabilities.playerType;
        }

        pLoginData.gatewayIP = stage.configuration.getString( 'external.ip', stage.configuration.getString( 'ip' ) );
        pLoginData.gatewayPort = stage.configuration.getInt( 'external.port', stage.configuration.getInt( 'port' ) );
        pLoginData.account = stage.configuration.getString( 'external.account', stage.configuration.getString( 'account' ) );
        pLoginData.os = Capabilities.os + ":" + Capabilities.language;

        pLoginData.flashVersion = Capabilities.version + " " + ( Capabilities.isDebugger ? "d" : "r");
        pLoginData.queryString = stage.configuration.getString( 'external.queryString', stage.configuration.getString( 'queryString ', "" ) );
        pLoginData.platform = stage.configuration.getString( 'external.platform', stage.configuration.getString( 'platform', "" ) );
        pLoginData.loginWay = stage.configuration.getString( 'external.loginWay', stage.configuration.getString( 'loginWay', "" ) );

        pLoginData.driverInfo = stage.configuration.getString( 'driverInfo', 'Unknown' );
        pLoginData.platformServerID = stage.configuration.getInt( 'external.ptsid', stage.configuration.getInt( 'ptsid' ) );
        pLoginData.serverID = stage.configuration.getInt( 'external.sid', stage.configuration.getInt( 'sid' ) );
        pLoginData.wdUrl = stage.configuration.getString( 'external.wdUrl', stage.configuration.getString( 'wdUrl' ) );

        LOG.logMsg( "External overridden data: " + JSON.stringify( pLoginData ) );

        var pHandler : CLoginHandler = this.handler as CLoginHandler;
        pHandler.login( pLoginData );
    }

    public function update( delta : Number ) : void {
        var h : IUpdatable = handler as IUpdatable;
        if ( h ) {
            h.update( delta );
        }
    }

}
}
