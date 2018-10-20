//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import QFLib.Application.Component.CLifeCycleEvent;
import QFLib.Foundation;
import QFLib.Foundation.CTime;
import QFLib.Foundation.CTimeDog;
import QFLib.Interface.IUpdatable;

import flash.events.ErrorEvent;
import flash.external.ExternalInterface;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.framework.CSystemHandler;
import kof.framework.IApplication;
import kof.framework.IConfiguration;
import kof.framework.INetworking;
import kof.framework.vfs.IFile;
import kof.game.CGameStage;
import kof.io.CVFSSystem;
import kof.message.Account.AccountLoginRequest;
import kof.message.Account.AccountLoginResponse;
import kof.message.Account.RoleLoginRequest;
import kof.message.Account.RoleLoginResponse;
import kof.message.Account.RoleMessageResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Demo.GameModeRequest;
import kof.message.kof_message;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;
import kof.util.ClientLog;

import mx.events.Request;

use namespace kof_message;

/**
 * 登陆控制组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLoginHandler extends CSystemHandler implements IUpdatable {

    private var m_TimeLeftDog : CTimeDog;

    /**
     * Constructor
     */
    public function CLoginHandler() {
        super();
    }

    override protected function onSetup() : Boolean {
        // registering net-protocol packet opcode mapping here.
        networking.bind( AccountLoginResponse ).toHandler( loginResponseMessageHandler );
        networking.bind( RoleLoginResponse ).toHandler( enterGameMessageHandler );
        networking.bind( RoleMessageResponse ).toHandler( roleInfoUpdateHandler );

        return true;
    }

    override protected function onShutdown() : Boolean {
        networking.unbind( RoleMessageResponse );
        networking.unbind( RoleLoginResponse );
        networking.unbind( AccountLoginResponse );

        return true;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
    }

    /**
     * @private
     * Login to server.
     */
    public function login( data : CLoginData ) : void {
        var config : IConfiguration = system.stage.configuration;
        CAssertUtils.assertNotNull( config );

        var nPort : uint = 2546;

        if ( data.gatewayIP == 'dummy' ) {
            // Dummy enabled.
            config.setConfig( 'dummy', true ); // Mark 'dummy' to true then 'networking' will starting with DUMMY mode.
            config.setConfig( 'networking.encrypt', false );
        }

        networking.connect( data.gatewayIP, data.gatewayPort || nPort, function ( errorOrChannel : * ) : void {
            if ( errorOrChannel is Error ) {
                ClientLog.log( 1021 );
                LOG.logErrorMsg( "Connected failed." );
                toShowErrorMessage( "服务器维护中……", 3 );
            } else {
                ClientLog.log( 1020 );
                onConnectCompleted( data );
            }
        } );
    }

    protected function toShowErrorMessage( str : String, iCountDown : int = 3 ) : void {
        m_TimeLeftDog = new CTimeDog( _onErrorMessageCountDownHit );
        m_TimeLeftDog.start( 1.0 );

        showErrorMessage( str, iCountDown );

        function _onErrorMessageCountDownHit() : void {
            if ( iCountDown > 1 ) {
                toShowErrorMessage( str, iCountDown - 1 );
            } else {
                // location to the home.
                m_TimeLeftDog.dispose();
                m_TimeLeftDog = null;

                locationToHomeUrl();
            }
        }
    }

    private function showErrorMessage( str : String, iCountDown : int = 0 ) : void {
        if ( iCountDown > 0 ) {
            str += "\n<font color='#00FF00'>" + iCountDown + "秒</font>后跳转至官网...";
        }

        var pApp : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( pApp && pApp.eventDispatcher ) {
            var errorEvent : ErrorEvent = new ErrorEvent( "_showMessage", false, false, str );
            pApp.eventDispatcher.dispatchEvent( errorEvent );
        }
    }

    protected function locationToHomeUrl() : void {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "toHome" );
            } catch ( e : Error ) {
                // ignore.
            }
        }
    }

    private function onConnectCompleted( data : CLoginData ) : void {
        LOG.logMsg( "Connected to server completed. Auth next step." );

        var config : IConfiguration = system.stage.configuration;
        CAssertUtils.assertNotNull( config );

        var accountLoginRequest : AccountLoginRequest = networking.getMessage( AccountLoginRequest ) as AccountLoginRequest;
        accountLoginRequest.account = data.account;
        accountLoginRequest.OS = data.os;
        accountLoginRequest.userAgent = data.userAgent;
        accountLoginRequest.flashVersion = data.flashVersion;

        accountLoginRequest.queryString = data.queryString;
        accountLoginRequest.platform = data.platform;
        accountLoginRequest.loginWay = data.loginWay;

        accountLoginRequest.client3DMode = data.driverInfo;
        accountLoginRequest.platformServerID = data.platformServerID;
        accountLoginRequest.serverID = data.serverID;

        // Send to the remote end-point.
        networking.send( accountLoginRequest );
    }

    protected function showRoleSelectView() : void {
        // ConfigHandler.
        var pConfigHandler : CPlaySelectConfigHandler = this.system.getBean( CPlaySelectConfigHandler );
        if ( !pConfigHandler ) {
            pConfigHandler = new CPlaySelectConfigHandler();
            this.system.addBean( pConfigHandler, MANAGED );
            pConfigHandler.start();
        }

        // ViewHandler.
        var playSelectViewHandler : CPlaySelectViewHandler = new CPlaySelectViewHandler();
        system.addBean( playSelectViewHandler, MANAGED ); // MANAGED 标注托管为父级管理

        playSelectViewHandler.start();
        playSelectViewHandler.addEventListener( CLifeCycleEvent.STARTED, function ( event : CLifeCycleEvent ) : void {
            event.currentTarget.removeEventListener( event.type, arguments.callee );
            playSelectViewHandler.show();
        }, false, 0 );

        playSelectViewHandler.addEventListener( CPlaySelectViewHandler.EVT_START_GAME, _onGameStartEventHandler, false );
    }

    private function _onGameStartEventHandler( event : Request ) : void {
        event.currentTarget.removeEventListener( event.type, _onGameStartEventHandler );

        // Enter game.
        var roleId : uint = 0;
        if ( event.value && 'roleId' in event.value )
            roleId = uint( event.value.roleId );

        var pvp : Boolean = false;
        if ( event.value && 'pvp' in event.value )
            pvp = Boolean( event.value.pvp );

        var profession : uint = 1;
        if ( event.value && 'id' in event.value ) {
            profession = int( event.value.id );
        }

        selectedMode( pvp );
        roleLogin( roleId, profession );
    }

    //----------------------------------
    // MessageHandler[s]
    //----------------------------------

    /**
     * 角色列表
     */
    private function loginResponseMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var theResponseMsg : AccountLoginResponse = message as AccountLoginResponse;
        if ( theResponseMsg.loginResult == 0 ) // success
        {
            if ( theResponseMsg.loginMode == 2 ) // preview mode
            {
                system.removeBean( CLoginViewHandler );
                showRoleSelectView();
            }
        }
        else {
            var iCountDown : int = 3;
            var strMessage : String;
            // show error message
            switch ( theResponseMsg.loginResult ) {
                case -1: {
                    strMessage = "服务器爆满中,请稍后再尝试！";
                    ClientLog.log( 3001 );
                    break;
                }
                case 11: {
                    strMessage = "重复登录";
                    break;
                }
                case 12: {
                    strMessage = "不支持的平台";
                    iCountDown = 0;
                    break;
                }
                case 13: {
                    strMessage = "平台登录验证失败";
                    iCountDown = 0;
                    break;
                }
                case 14: {
                    strMessage = "服务器繁忙（承载达到上限）";
                    break;
                }
                case 15: {
                    strMessage = "该账号已被封停，请联系客服";
                    break;
                }
                case 16: {
                    strMessage = "服务器内部错误";
                    break;
                }
                default: {
                    strMessage = "服务器维护中！";
                    ClientLog.log( 3002 );
                    break;
                }
            }

            if ( iCountDown == 0 ) {
                locationToHomeUrl();
            } else {
                toShowErrorMessage( strMessage, iCountDown );
            }
        }

        CTime.loginServerTimestamp = isNaN( theResponseMsg.serverTime ) ? 0 : theResponseMsg.serverTime;
        CTime.timeFromFlashStart = getTimer();

        CTime.setServerOpenTimeInfo( theResponseMsg.serverStartTime );
        CTime.timeZone = theResponseMsg.timeZone;
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
        roleLoginRequest.roleID = profession;
//        roleLoginRequest.roleID = roleId;
//        roleLoginRequest.profession = profession;
//        roleLoginRequest.sex = gender;

        networking.send( roleLoginRequest );
    }

    /**
     * 创建角色
     */
    private function createRoleMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var vfs : CVFSSystem = system.stage.getSystem( CVFSSystem ) as CVFSSystem;
        if ( !vfs ) {
            LOG.logErrorMsg( "CVFSSystem required." );
            return;
        }

        var selectRoleSwf : IFile = vfs.getFile( "/RoleCreate.swf" );
        selectRoleSwf.open( function ( bytes : ByteArray ) : void {
            if ( bytes ) {
                // load success.
            } else {
                // load error.
            }
        } );
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
            // clone msg's data as object.
            var data : Object = CObjectUtils.cloneObject( msg );
            system.stage.configuration.setConfig( "role.data", data );
        }
    }

    public function update( delta : Number ) : void {
        if ( m_TimeLeftDog ) {
            m_TimeLeftDog.update( delta );
        }
    }
}
}

