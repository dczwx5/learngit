/**
 * Created by user on 2016/12/13.
 */
package preview.game.level {
import flash.net.SharedObject;

import kof.framework.IConfiguration;
import kof.login.CLoginData;
import kof.login.CLoginSystem;

public class CLevelPreviewSystem extends CLoginSystem {
    public function CLevelPreviewSystem() {
        super();
    }

    public var hadler:CLevelPreviewHandler;

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            // CLoginHandler is a CSystemHandler, so CLoginSystem.handler is a instance of CLoginHandler.
            hadler = new CLevelPreviewHandler();
            this.addBean( hadler );
//            this.addBean( new CLoginViewHandler() );
        }

        return ret;
    }

    override public function login() : void {
        LOG.logTraceMsg( "Ready to login to server, retrieves the networking interface and send the login packet." );

        // 1. load from SharedObject.
        // 2. load from external.parameters overwrite it if absent.

        var so : SharedObject = SharedObject.getLocal( "KOF_DebugLoginInfo", "/" );

        var account : String = (9999*Math.random()).toString();//so.data.account;
//        var serverAddr : String = "10.10.17.123"//"127.0.0.1"//so.data.serverAddr;
//        var serverAddr : String = "10.10.17.48"//"127.0.0.1"//so.data.serverAddr;
        var serverAddr : String = "127.0.0.1"//so.data.serverAddr
//
        var pConfig : IConfiguration = this.stage.configuration;
        if ( !pConfig.getString( "server.host" ) ) {
            pConfig.setConfig( "server.host", serverAddr );
        }

        if ( !pConfig.getString( "account" ) ) {
            pConfig.setConfig( "account", account );
        }

        var data:CLoginData = new CLoginData();
        data.account = account;
        data.gatewayIP = serverAddr;
        data.gatewayPort = 2546;
        data.loginWay = "";
        data.platform = "";
        data.queryString  = "";
        data.flashVersion  = "";
        data.os  = "";
        data.userAgent  = "";

        data.driverInfo = "";
        data.platformServerID = 0;
        data.serverID = 0;
        var pHandler : CLevelPreviewHandler = this.handler as CLevelPreviewHandler;
        pHandler.login( data );

        // Shows the login interact view.
//        var viewHandler : CLoginViewHandler = getBean( CLoginViewHandler ) as CLoginViewHandler;
//
//        if ( viewHandler ) {
//            viewHandler.show();
//        }

    }
}
}
