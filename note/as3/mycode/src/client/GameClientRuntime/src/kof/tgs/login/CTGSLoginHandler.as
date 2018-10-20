//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.tgs.login {

import QFLib.Application.Component.CLifeCycleEvent;
import flash.events.Event;

import kof.framework.CSystemHandler;
import kof.framework.IApplication;
import kof.framework.IConfiguration;
import kof.framework.INetworking;
import kof.game.CGameStage;
import kof.login.CPlaySelectViewHandler;
import kof.message.Account.AccountLoginResponse;
import kof.message.Account.AccountLoginRequest;
import kof.message.Account.RoleLoginRequest;
import kof.message.Account.RoleLoginResponse;
import kof.message.Account.RoleMessageResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Demo.GameModeRequest;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;
import kof.util.CRandCode;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTGSLoginHandler extends CSystemHandler {

    private var m_pRandCode : CRandCode;

    public function CTGSLoginHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        networking.bind( AccountLoginResponse ).toHandler( roleListMessageHandler );
        networking.bind( RoleLoginResponse ).toHandler( enterGameMessageHandler );
        networking.bind( RoleMessageResponse ).toHandler( roleInfoUpdateHandler );

        return ret;
    }

    public function nextAccount() : String {
        if ( !m_pRandCode )
            m_pRandCode = new CRandCode();
        return m_pRandCode.generateCode( 8, 11 );
    }

    private function _displayErrorMessage( msg : String ) : void {
        var viewHandler : CTGSLoginViewHandler = system.getBean( CTGSLoginViewHandler ) as CTGSLoginViewHandler;
        if ( viewHandler ) {
            viewHandler.errorMessage = msg;
        }
    }

    public function loginWithRandomAccount( data : Object = null ) : void {
        _displayErrorMessage( null );

        if ( !this.networking.isConnected ) {
            var config : IConfiguration = system.stage.configuration;
            CAssertUtils.assertNotNull( config );

            var strHost : String = config.getString( "server.host", "127.0.0.1" );
            var nPort : uint = config.getInt( "server.port", 2546 );

            data = data || {};

            // Replaces with given data config if exists
            strHost = data.host || strHost;
            nPort = data.port || nPort;

            if ( strHost == 'dummy' ) {
                // Dummy enabled.
                config.setConfig( 'dummy', true ); // Mark 'dummy' to true then 'networking' will starting with DUMMY mode.
            }

            networking.connect( strHost, nPort, function ( errorOrChannel : * ) : void {
                if ( errorOrChannel is Error ) {
                    LOG.logErrorMsg( "Connected failed." );
                    _displayErrorMessage( (errorOrChannel as Error).message );
                } else {
                    LOG.logTraceMsg( "Connected to server completed. Auth next step." );
                    onConnectCompleted();
                }
            } );
        } else {
            this.onConnectCompleted();
        }
    }

    private function onConnectCompleted() : void {
        var account : String = this.nextAccount();

        LOG.logTraceMsg( "Login with Account: " + account );

        var msg : AccountLoginRequest = this.networking.getMessage( AccountLoginRequest ) as AccountLoginRequest;
        msg.account = account;

        this.networking.send( msg );
    }

    private function roleListMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        system.removeBean( CTGSLoginViewHandler );

        var playSelectViewHandler : CPlaySelectViewHandler = new CPlaySelectViewHandler();
        system.addBean( playSelectViewHandler, MANAGED ); // MANAGED 标注托管为父级管理
        playSelectViewHandler.addEventListener( CPlaySelectViewHandler.EVT_START_GAME, function ( event : Event ) : void {
            event.currentTarget.removeEventListener( CPlaySelectViewHandler.EVT_START_GAME, arguments.callee );

            // Enter game.
            var roleId : uint = playSelectViewHandler.roleID;

            selectedMode( false );
            roleLogin( roleId, 0 );

        }, false, 0 );

        playSelectViewHandler.start();
        playSelectViewHandler.addEventListener( CLifeCycleEvent.STARTED, function ( event : CLifeCycleEvent ) : void {
            event.currentTarget.removeEventListener( event.type, arguments.callee );

            playSelectViewHandler.show();
        }, false, 0 );
    }

    /**
     * 同步Demo开始模式到服务器
     *
     * @param pvp 是否选择PVP模式
     */
    private function selectedMode( pvp : Boolean ) : void {
        var gameModeRequest : GameModeRequest = new GameModeRequest();
        gameModeRequest.pvp = pvp;

        networking.send( gameModeRequest );
    }

    /**
     * 角色登录请求
     */
    private final function roleLogin( roleId : int, profession : int = 0, gender : int = 0 ) : void {
        var roleLoginRequest : RoleLoginRequest = networking.getMessage( RoleLoginRequest ) as RoleLoginRequest;
        roleLoginRequest.roleID = roleId;

        networking.send( roleLoginRequest );
    }

    /**
     * 进入游戏，未进入到场景前的初始准备
     */
    private function enterGameMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        // Next to GameStage.
        var app : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( app ) {
            app.replaceStage( new CGameStage() );
        }
    }

    /**
     * 收到玩家登陆的角色数据，缓存到App作用域，传递给GameStage使用
     */
    private function roleInfoUpdateHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : RoleMessageResponse = message as RoleMessageResponse;
        if ( msg ) {
            var data : Object = CObjectUtils.toObject( msg, [
                "roleID",
                "name",
                "prototypeID",
                "curExp",
                "atk",
                "level",
                "hp",
                "moveSpeed",
                "mp",
                "money",
                "diamond",
                "x",
                "y",
                "dirX",
                "dirY",
                "line",
                "mapID",
                "mapType",
                "battleValue"
            ] );
            system.stage.configuration.setConfig( "role.data", data );
        }
    }

}
}
