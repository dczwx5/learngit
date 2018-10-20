//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy.handler {

import kof.dummy.CDummyDatabase;
import kof.dummy.CDummyServer;
import kof.framework.CAbstractHandler;
import kof.message.Account.AccountLoginRequest;
import kof.message.Account.AccountLoginResponse;
import kof.message.Account.RoleLoginRequest;
import kof.message.Account.RoleLoginResponse;
import kof.message.Account.RoleMessageResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Demo.GameModeRequest;
import kof.message.Player.PlayerInfoRequest;
import kof.message.Player.PlayerInfoResponse;
import kof.util.CAssertUtils;

/**
 * 登录类别的数据包模拟逻辑处理
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CDummyLoginHandler extends CAbstractHandler {

    public function CDummyLoginHandler() {
        super();
    }

    final public function get server() : CDummyServer {
        return system as CDummyServer;
    }

    final public function get database() : CDummyDatabase {
        return server.getBean( CDummyDatabase ) as CDummyDatabase;
    }

    override protected virtual function onSetup() : Boolean {
        this.server.listen( AccountLoginRequest, onAccountLogin );
        this.server.listen( RoleLoginRequest, onRoleLogin );
        this.server.listen( GameModeRequest, onGameModeConfirm );
        this.server.listen( PlayerInfoRequest, onGetPlayerInfo );//

        return true;
    }

    protected function onGetPlayerInfo(request:PlayerInfoRequest) : void {
        var response:PlayerInfoResponse = new PlayerInfoResponse();
        server.send(response);
    }

    protected function onAccountLogin( request : CAbstractPackMessage ) : void {
        var msg : AccountLoginRequest = request as AccountLoginRequest;
        CAssertUtils.assertNotNull( msg );

        LOG.logMsg( "Account Login in DummyServer: " + msg.account );

        // Building role list and response.

        var response : AccountLoginResponse = new AccountLoginResponse();
        response.loginMode = 2;
        response.loginResult = 0;

        server.send( response );
    }

    private final function onRoleLogin( request : RoleLoginRequest ) : void {
        var response : RoleLoginResponse = new RoleLoginResponse();
        response.loginSuccess = true;
        server.send( response );

        var data : Object = database.data;

        request.roleID = request.roleID || 1;

        // data.role.roleID = request.roleID;
        // data.role.prototypeID = request.profession;
        // data.role.gender = request.sex;

        data.role.prototypeID = request.roleID;

        this.sendRoleInfoUpdated();

        var mapInstance : CDummyMapInstanceHandler = system.getBean( CDummyMapInstanceHandler ) as CDummyMapInstanceHandler;
        CAssertUtils.assertNotNull( mapInstance );

        mapInstance.startLogin( data.role );
    }

    final private function sendRoleInfoUpdated() : void {
        var response : RoleMessageResponse = new RoleMessageResponse();
        for (var p : String in database.data.role ) {
            if ( p && response.hasOwnProperty( p ) ) {
                response[ p ] = database.data.role[ p ];
            }
        }

        // CObjectUtils.extend( response, database.data.role );

        // response.roleID = database.data.roleID;

        server.send( response );
    }

    final private function onGameModeConfirm( request : GameModeRequest ) : void {
        var data : Object = database.data;
        data.server_runtime.pvp = request.pvp;
    }

}
}
