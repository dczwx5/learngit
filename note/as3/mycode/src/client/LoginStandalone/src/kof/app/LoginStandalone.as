//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.app {

import QFLib.Foundation;
import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLXml;
import QFLib.Interface.IDisposable;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.SharedObject;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import kof.ui.master.debug.LoginUI;

import morn.core.handlers.Handler;

[SWF(backgroundColor="#000000", frameRate="60", width="1500", height="900")]
/**
 * 简单的黑屏加载
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class LoginStandalone extends Sprite implements IDisposable {

    static private const LOGIN_STORAGE_NAME : String = "KOF_DebugLoginInfo";

    /**
     * @private
     */
    private var m_pLoginUI : LoginUI;
    private var m_pAssets : Array = [
        "login.swf",
        "tgs_login.swf",
        "frame_logoloop.swf",
        "frameclip_startbutton.swf"
    ];

    private var m_sAccount : String;
    private var m_sPassword : String;
    private var m_sServerAddr : String;
    private var m_sErrorMessage : String;
    private var m_pServerList : Array;
    private var m_pRandCode : CRandCode;

    private var m_bMainLoading : Boolean;

    /**
     * Creates a new LoginStandalone.
     */
    public function LoginStandalone() {
        super();

        if ( stage ) {
            addToStage( null );
        } else {
            addEventListener( Event.ADDED_TO_STAGE, addToStage, false, 0, true );
        }
    }

    public function dispose() : void {
        removeEventListener( Event.ADDED_TO_STAGE, addToStage );
        removeEventListener( Event.REMOVED_FROM_STAGE, removeFromStage );

        if ( m_pLoginUI ) {
            m_pLoginUI.btnSubmit.removeEventListener( MouseEvent.CLICK, _onSubmitValidation );
            m_pLoginUI.txtAccount.removeEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler );
            m_pLoginUI.txtPassword.removeEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler );
            m_pLoginUI.txtServerAddr.removeEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler );

            m_pLoginUI.txtAccount.removeEventListener( Event.CHANGE, _txtInputsChangeEventHandler );
            m_pLoginUI.txtPassword.removeEventListener( Event.CHANGE, _txtInputsChangeEventHandler );
            m_pLoginUI.txtServerAddr.removeEventListener( Event.CHANGE, _txtInputsChangeEventHandler );
        }

        m_pLoginUI = null;
        m_pRandCode = null;
    }

    private function addToStage( event : Event ) : void {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        Config.GAME_FPS = this.stage.frameRate;
        Config.resPath = "assets/ui/";
        Config.uiPath = "ui.swf";

        App.init( this );

        if ( Boolean( Config.uiPath ) ) {
            App.loader.loadDB( Config.uiPath, new Handler( onUIloadComplete ) );
        }
    }

    private function onUIloadComplete( content : * ) : void {
        this.loadAssets();
    }

    protected function loadAssets() : void {
        var bLoaded : Boolean = true;
        for each ( var str : String in m_pAssets ) {
            if ( !App.mloader.getResLoaded( str ) ) {
                bLoaded = false;
                break;
            }
        }

        if ( !bLoaded ) {
            App.mloader.loadAssets( m_pAssets, new Handler( _onFinished ), null,
                    null, false );
            return;
        }

        function _onFinished() : void {
            initialize();
            addToDisplayList();
        }

        _onFinished();
    }

    protected function initialize() : void {
        if ( !m_pLoginUI ) {
            m_pLoginUI = new LoginUI;
        }

        this.m_pRandCode = new CRandCode();
        this.errorMessage = null;

        // load server list infos.
        var preventCache : String = "?_=" + Math.random();
        var pServerXMLs : CURLXml = new CURLXml( "serverList.xml" + preventCache );
        pServerXMLs.startLoad( _onFinished );

        function _onFinished( pFile : CURLXml, idError : int ) : void {
            if ( idError == 0 ) {
                // success.
                var xml : XML = pFile.xmlObject as XML;
                var xmlListServers : XMLList = xml..server;
                var nLen : uint = xmlListServers.length();
                var ret : Array = [];
                for ( var i : int = 0; i < nLen; ++i ) {
                    ret.push( {
                        host : xmlListServers[ i ].@host,
                        port : uint( xmlListServers[ i ].@port ),
                        label : xmlListServers[ i ].@label.toString()
                    } );
                }

                serverList = ret;
            } else {
                // ignore.
                serverList = [];
            }
        }

        this.readFromSharedObject();
        this.updateData();

        addEventListener( Event.REMOVED_FROM_STAGE, removeFromStage, false, 0, true );

        m_pLoginUI.btnSubmit.addEventListener( MouseEvent.CLICK, _onSubmitValidation, false, 0, true );
        m_pLoginUI.txtAccount.addEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler, false, 0, true );
        m_pLoginUI.txtPassword.addEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler, false, 0, true );
        m_pLoginUI.txtServerAddr.addEventListener( KeyboardEvent.KEY_UP, _txtInputsKeyboardUpEventHandler, false, 0, true );

        m_pLoginUI.txtAccount.addEventListener( Event.CHANGE, _txtInputsChangeEventHandler, false, 0, true );
        m_pLoginUI.txtPassword.addEventListener( Event.CHANGE, _txtInputsChangeEventHandler, false, 0, true );
        m_pLoginUI.txtServerAddr.addEventListener( Event.CHANGE, _txtInputsChangeEventHandler, false, 0, true );

        m_pLoginUI.radioServerInfo.selectHandler = new Handler( _onServerInfoSelected );

        m_pLoginUI.lnkRandName.addEventListener( MouseEvent.CLICK, _onRandomAccountRequest, false, 0, true );

    }

    protected function removeFromStage( event : Event ) : void {
        removeEventListener( Event.REMOVED_FROM_STAGE, removeFromStage );
    }

    public function addToDisplayList() : void {
        if ( !m_pLoginUI )
            return;

        stage.addEventListener( Event.RESIZE, onStageResize, false, 0, true );
        stage.addChild( m_pLoginUI );

        exeResize();
    }

    public function removeFromDisplayList() : void {
        stage.removeEventListener( Event.RESIZE, onStageResize );

        if ( !m_pLoginUI )
            return;

        m_pLoginUI.remove();
    }

    protected function onStageResize( event : Event ) : void {
        App.render.callLater( exeResize );
    }

    protected function exeResize() : void {
        var w : Number = stage.stageWidth;
        var h : Number = stage.stageHeight;

        m_pLoginUI.x = w - m_pLoginUI.width >> 1;
        m_pLoginUI.y = h - m_pLoginUI.height >> 1;
    }

    private function _onSubmitValidation( event : MouseEvent ) : void {
        // NOTE: Submit.
        this.validateOnSubmit();
    }

    private function _txtInputsKeyboardUpEventHandler( event : KeyboardEvent ) : void {
        // NOTE: if keycode == 13 (ENTER), then run Submit.
        if ( !event.altKey && !event.ctrlKey && !event.shiftKey && event.keyCode == Keyboard.ENTER ) {
            this.validateOnSubmit();

            event.stopPropagation();
        }
    }

    private function _txtInputsChangeEventHandler( event : Event ) : void {
        if ( m_pLoginUI ) {
            this.account = m_pLoginUI.txtAccount.text;
            this.password = m_pLoginUI.txtPassword.text;
            this.serverAddr = m_pLoginUI.txtServerAddr.text;
        }
    }

    protected function validateOnSubmit() : void {
        if ( m_bMainLoading )
            return;
        Foundation.Log.logMsg( "Submit on validation." );
        Foundation.Log.logMsg( " - ServerAddr: " + this.serverAddr );
        Foundation.Log.logMsg( " - Account   : " + this.account );
        Foundation.Log.logMsg( " - Password  : " + this.password );

        this.saveToSharedObject();

        this.startGameLoad( function () : void {
            removeFromDisplayList();
            dispose();
        } );
    }

    protected function readFromSharedObject() : void {
        var so : SharedObject = SharedObject.getLocal( LOGIN_STORAGE_NAME, "/" );

        this.account = so.data.account;
        this.password = so.data.password;
        if ( so.data.serverAddr != "dummy" )
            this.serverAddr = so.data.serverAddr;

        if ( m_pLoginUI ) {
            if ( !this.account ) this.account = m_pLoginUI.txtAccount.text;
            if ( !this.password ) this.password = m_pLoginUI.txtPassword.text;
        }
    }

    protected function saveToSharedObject() : void {
        var so : SharedObject = SharedObject.getLocal( LOGIN_STORAGE_NAME, "/" );

        if ( this.account )
            so.data.account = this.account || "jeremy";
        if ( this.password )
            so.data.password = this.password;
        if ( this.serverAddr )
            so.data.serverAddr = this.serverAddr;
        else {
            var idx : int = m_pLoginUI.radioServerInfo.selectedIndex;
            if ( 0 <= idx && idx < this.serverList.length ) {
                var pData : Object = this.serverList[ idx ];
                if ( pData && pData.host == 'dummy' )
                    so.data.serverAddr = 'dummy';
            }
        }

        so.flush();
    }

    protected function startGameLoad( pfnCallback : Function ) : void {
        var preventCache : String = "?_=" + Math.random();
        var cf : CURLFile = new CURLFile( "LoadingShell.swf" + preventCache );
        cf.startLoad( _onFinished );

        var loginStandalone : LoginStandalone = this;

        function _onFinished( pFile : CURLFile, idError : int ) : void {
            if ( idError == 0 ) {
                // success.
                var bytes : ByteArray = pFile.readAllBytes();

                var pLoaderContext : LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
                pLoaderContext.allowCodeImport = true;
                pLoaderContext.parameters = loaderInfo.parameters;

                if ( !('configXML' in pLoaderContext.parameters ) ) {
                    pLoaderContext.parameters[ 'configXML' ] = 'config-debug.xml';
                }

                pLoaderContext.parameters[ 'account' ] = loginStandalone.account;
                if ( !loginStandalone.serverAddr ) {
                    pLoaderContext.parameters[ 'ip' ] = 'dummy';
                } else {
                    var serverAddrParts : Array = loginStandalone.serverAddr.split( ':', 2 );
                    pLoaderContext.parameters[ 'ip' ] = serverAddrParts[ 0 ];
                    pLoaderContext.parameters[ 'port' ] = (serverAddrParts[ 1 ] || 2546).toString();
                }

                var pLoader : Loader = new Loader();
                pLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onBytesLoadedCompleted );
                pLoader.contentLoaderInfo.addEventListener( ErrorEvent.ERROR, _onBytesLoadedFailed );

                pLoader.loadBytes( bytes, pLoaderContext );
            } else {
                // error.
                errorMessage = "Load 'LoadingShell.swf' falied: #" + idError;
            }
        }

        function _onBytesLoadedCompleted( event : Event ) : void {
            var pInfo : LoaderInfo = event.currentTarget as LoaderInfo;
            stage.addChild( pInfo.content );

            if ( pfnCallback )
                pfnCallback();
            m_bMainLoading = false;
        }

        function _onBytesLoadedFailed( event : ErrorEvent ) : void {
            errorMessage = "Import 'LoadingShell.swf' failed: " + event.toString();
            m_bMainLoading = false;
        }

        m_bMainLoading = true;
    }

    private function _onServerInfoSelected( idx : int ) : void {
        if ( 0 > idx || idx >= this.serverList.length )
            return;

        var pData : Object = this.serverList[ idx ];
        if ( 'dummy' != pData.host )
            this.serverAddr = pData.host + ( pData.port ? ":" + pData.port : "" );
        else
            this.serverAddr = null;
    }

    private function _onRandomAccountRequest( event : MouseEvent ) : void {
        this.account = this.m_pRandCode.generateCode( 9, 13 );
    }

    protected function updateData() : void {
        if ( m_pLoginUI ) {
            m_pLoginUI.txtAccount.text = this.account;
            m_pLoginUI.txtPassword.text = this.password;
            m_pLoginUI.txtServerAddr.text = this.serverAddr;
            m_pLoginUI.txtErrorMsg.text = this.errorMessage;

            if ( !this.serverList )
                return;

            var sHost : String = null;
            var sPort : String = null;
            var iSelectedIndex : int = -1;

            if ( this.serverAddr ) {
                var pSplitArr : Array = this.serverAddr.split( ':' );
                sHost = pSplitArr[ 0 ];
                if ( pSplitArr.length > 1 )
                    sPort = pSplitArr[ 1 ];
            }

            m_pLoginUI.radioServerInfo.dataSource = this.serverList.map(
                    function ( val : Object, idx : int, arr : Array ) : Object {
                        if ( val && val.hasOwnProperty( 'host' ) ) {
                            if ( val.host == sHost || ( val.host == 'dummy' && !sHost ) ) {
                                if ( val.host == 'dummy' ) {
                                    iSelectedIndex = idx;
                                    return val.label;
                                } else {
                                    if ( !sPort || !val.hasOwnProperty( 'port' ) || (val.hasOwnProperty( 'port' ) && val.port.toString() == sPort ) ) {
                                        iSelectedIndex = idx;
                                    }
                                }
                            }
                        }
                        return val.label;
                    } );

            // update the server selected index.
            m_pLoginUI.radioServerInfo.selectedIndex = iSelectedIndex;
        }
    }

    public function get account() : String {
        return m_sAccount;
    }

    public function set account( value : String ) : void {
        if ( m_sAccount == value )
            return;
        m_sAccount = value;
        App.render.callLater( updateData );
    }

    public function get password() : String {
        return m_sPassword;
    }

    public function set password( value : String ) : void {
        if ( m_sPassword == value )
            return;
        m_sPassword = value;
        App.render.callLater( updateData );
    }

    public function get serverAddr() : String {
        return m_sServerAddr;
    }

    public function set serverAddr( value : String ) : void {
        if ( m_sServerAddr == value )
            return;
        m_sServerAddr = value;
        App.render.callLater( updateData );
    }

    public function get errorMessage() : String {
        return m_sErrorMessage;
    }

    public function set errorMessage( value : String ) : void {
        if ( m_sErrorMessage == value )
            return;
        m_sErrorMessage = value;
        App.render.callLater( updateData );
    }

    public function get serverList() : Array {
        return m_pServerList;
    }

    public function set serverList( value : Array ) : void {
        if ( m_pServerList == value )
            return;
        m_pServerList = value;
        App.render.callLater( updateData );
    }

}
}

final class CRandCode {

    static private var CODES : Array = [
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    ];

    public function CRandCode() {

    }

    public function generateCode( iMinLength : int, iMaxLength : int = -1 ) : String {
        if ( iMinLength <= 0 )
            return null;

        iMaxLength = iMaxLength <= 0 ? iMinLength : iMaxLength;

        const nCodes : uint = CODES.length;
        // length between min - max
        var nLen : uint = iMinLength + int( Math.random() * ( iMaxLength - iMinLength ) );
        var ret : String = '';

        for ( var i : uint = 0; i < nLen; ++i ) {
            var idx : uint = Math.random() * nCodes;
            ret += CODES[ idx ];
        }

        return ret;
    }
}


