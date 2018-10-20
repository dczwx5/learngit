//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.ui.master.debug.LoginUI;
import kof.util.CRandCode;

import morn.core.handlers.Handler;

import mx.events.Request;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CLoginViewHandler extends CViewHandler {

    private var m_pAssets : Array = [
        "login.swf",
        "tgs_login.swf",
        "frame_logoloop.swf",
        "frameclip_startbutton.swf"
    ];

    private var m_loginUI : LoginUI;
    private var m_listServers : Array;
    private var m_bServerListDirty : Boolean;
    private var m_strErrorMessage : String;
    private var m_pRandCode : CRandCode;

    public function CLoginViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        // TODO: DISPOSE UI resources.
        detachEventListeners();

        m_loginUI = null;
        m_strErrorMessage = null;
        m_listServers = null;
    }

    [Inline]
    public function get serverList() : Array {
        return m_listServers;
    }

    public function set serverList( list : Array ) : void {
        if ( this.m_listServers == list )
            return;
        this.m_listServers = list;
        this.m_bServerListDirty = true;
        this.invalidateData();
    }

    public function get errorMessage() : String {
        return m_strErrorMessage;
    }

    public function set errorMessage( value : String ) : void {
        this.m_strErrorMessage = value;
        this.invalidateDisplay();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.loadAssets();
        ret = ret && this.initialize();

        return ret;
    }

    override protected function onShutdown() : Boolean {
        hide( true );

        detachEventListeners();

        return true;
    }

    private function loadAssets() : Boolean {
        var bLoaded : Boolean = true;
        for each ( var str : String in m_pAssets ) {
            if ( !App.mloader.getResLoaded( str ) ) {
                bLoaded = false;
                break;
            }
        }

        if ( !bLoaded ) {
            App.mloader.loadAssets( m_pAssets, new Handler( _onAssetsCompleted ), null, null, false );
        }

        return bLoaded;
    }

    private function _onAssetsCompleted( ... args ) : void {
        LOG.logTraceMsg( "ON 'login.swf' load completed..." );
        this.makeStarted();
        this.initialize();
    }

    protected function initialize() : Boolean {
        m_loginUI = new LoginUI();

        m_loginUI.txtErrorMsg.text = null;

        m_loginUI.radioServerInfo.selectedIndex = 0;
        m_loginUI.radioServerInfo.selectHandler = new Handler( _onServerListSelected );

        m_loginUI.centerX = 0;
        m_loginUI.centerY = 0;

        attachEventListeners();

        return true;
    }

    protected function attachEventListeners() : void {
        if ( !m_loginUI )
            return;
        //       m_loginUI.txtAccount.text = "auto100002";
        //       m_loginUI.txtServerAddr.text = "10.10.17.188"; // hunker
//        m_loginUI.txtServerAddr.text = "10.10.17.101"; // black
//        m_loginUI.txtServerAddr.text = "10.10.17.41"; // black

        m_loginUI.txtAccount.addEventListener( KeyboardEvent.KEY_UP, txtInputsKeyboardUpEventHandler, false );
        m_loginUI.txtPassword.addEventListener( KeyboardEvent.KEY_UP, txtInputsKeyboardUpEventHandler, false );
        m_loginUI.addEventListener( MouseEvent.CLICK, buttonsMouseClickEventHandler, false );
        m_loginUI.lnkRandName.addEventListener( MouseEvent.CLICK, lnkRandNameMouseClickEventHandler, false );

        //for testing
        // m_loginUI.lnkRandName.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
    }

    protected function detachEventListeners() : void {
        if ( !m_loginUI )
            return;
        m_loginUI.txtAccount.removeEventListener( KeyboardEvent.KEY_UP, txtInputsKeyboardUpEventHandler );
        m_loginUI.txtPassword.removeEventListener( KeyboardEvent.KEY_UP, txtInputsKeyboardUpEventHandler );
        m_loginUI.removeEventListener( MouseEvent.CLICK, buttonsMouseClickEventHandler );
    }

    private function buttonsMouseClickEventHandler( event : MouseEvent ) : void {
        switch ( event.target.name ) {
            case '进入游戏':
                this.onValidateLogin();
                break;
        }
    }

    override protected function updateData() : void {
        super.updateData();
        if ( !m_loginUI ) {
            this.invalidateData();
            return;
        }

        m_loginUI.radioServerInfo.labels = this.serverList.map( function ( item : *, index : int, array : Array ) : Object {
            if ( item ) {
                return item[ 'label' ];
            }
            return null;
        } ).join( ',' );
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();
        m_loginUI.txtErrorMsg.text = this.errorMessage;
    }

    private function lnkRandNameMouseClickEventHandler( event : MouseEvent ) : void {
        if ( !m_pRandCode )
            m_pRandCode = new CRandCode();
        var strName : String = m_pRandCode.generateCode( 8, 11 );
        m_loginUI.txtAccount.text = strName;
    }

    private function txtInputsKeyboardUpEventHandler( event : KeyboardEvent ) : void {
        if ( !event.altKey && !event.ctrlKey && !event.shiftKey && event.charCode == 13 ) {
            // enter.
            this.onValidateLogin();
        }
    }

    private function _onServerListSelected( idx : int ) : void {
        if ( 0 > idx || idx >= m_listServers.length )
            return;

        var pData : Object = m_listServers[ idx ];
        if ( !pData )
            return;

        if ( pData.host == 'dummy' ) {
            m_loginUI.txtServerAddr.text = '';
        } else {
            m_loginUI.txtServerAddr.text = pData.host;
        }
    }

    private function onValidateLogin() : void {
        if ( m_loginUI.txtAccount.text == "" )
            return;

        var strAccountName : String = m_loginUI.txtAccount.text;
        var strAccountPwd : String = m_loginUI.txtPassword.text;
        var strServerAddr : String = m_loginUI.txtServerAddr.text;

        var pServerInfo : Object = serverList ? serverList[ m_loginUI.radioServerInfo.selectedIndex ] : {
            host : null,
            port : 0
        };

        var strHost : String = pServerInfo.host;
        var nPort : uint = uint( pServerInfo.port );

        if ( strServerAddr && strServerAddr.length > 0 ) {
            var arrServerInfos : Array = strServerAddr.split( ':' );
            if ( arrServerInfos.length > 0 )
                strHost = arrServerInfos[ 0 ];
            if ( arrServerInfos.length > 1 ) {
                nPort = uint( arrServerInfos[ 1 ] );
            }
        }

        dispatchEvent( new Request( "login", false, false, {
            account : strAccountName,
            password : strAccountPwd,
            host : strHost,
            port : nPort
        } ) );
    }

    public function show() : void {
        if ( m_loginUI ) {
            uiCanvas.rootContainer.addChild( m_loginUI );
        }
    }

    public function hide( removed : Boolean = true ) : void {
        if ( m_loginUI ) {
            if ( removed ) {
                if ( m_loginUI.parent ) {
                    m_loginUI.parent.removeChild( m_loginUI );
                }
            } else {
                m_loginUI.alpha = 0;
            }
        }
    }

}
}
