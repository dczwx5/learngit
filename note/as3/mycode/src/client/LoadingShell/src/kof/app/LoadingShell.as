package kof.app {

import QFLib.Foundation;
import QFLib.Foundation.CAssetVersion;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CProcedureManager;
import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLSwf;
import QFLib.Foundation.CURLXml;
import QFLib.Utils.CClassUtil;
import QFLib.Utils.CHideSwfUtil;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.filters.GlowFilter;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.net.navigateToURL;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.events.Request;
import mx.utils.StringUtil;

[SWF(backgroundColor="#000000", frameRate="60", width="1500", height="900")]
/**
 * Loading Main entrance.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class LoadingShell extends Sprite {

    private static const EXTERNAL : String = "external";

    [Embed(source="../../../libs/VendorShow.swf", mimeType="application/x-shockwave-flash", symbol="frameclip_chuxianxiaoshi")]
    private static const embedVendorLogoMC : Class;

    initOnClassLoaded();

    /**
     * Global startup static initialization.
     */
    private static function initOnClassLoaded() : void {
        CClassUtil.registerClassAlias( "VendorLogo", embedVendorLogoMC );
//        CClassUtil.registerClassAlias( "VendorLogo", CompanyLogo );
//        CClassUtil.registerClassAlias( "LoadingBarMovieClip", LoadingBarMovieClip );
    }

    private static function clientLog( logID : int ) : void {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "window.client_log", logID );
            } catch ( e : Error ) {
                // ignore.
//                Foundation.Log.logWarningMsg("client_log error: " + e.message );
            }
        }
    }

    private var _logo : MovieClip;
    private var _stage3d : Stage3D;
    private var _loadingView : LoadingBarMovieClip;

    private var _procedureManager : CProcedureManager;
    private var _configMap : CMap;
    private var m_fElapsedTime : Number = NaN;
    private var m_fDummyProgressTimeTotal : Number = 110;
    private var m_fDummyProgressTimeRemaining : Number = m_fDummyProgressTimeTotal;
    private var m_fDummyProgressFactor : Number;
    private var m_bDummyProgressEnabled : Boolean;
    private var m_sPreventCache : String;
    private var m_pAssetVersion : CAssetVersion;
    private var m_pAppEventDelegate : IEventDispatcher;
    private var m_iCategoryOfLoadingView : uint;

    /**
     * Constructor
     */
    public function LoadingShell() {
        if ( stage ) {
            this.addedToStage( null );
        }
        else {
            this.addEventListener( Event.ADDED_TO_STAGE, addedToStage );
        }
    }

    /**
     * 载入舞台处理
     */
    private function addedToStage( event : Event ) : void {
        CHideSwfUtil.hideSWF( this.loaderInfo.bytes );

        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.stage.align = StageAlign.TOP_LEFT;
        this.initialize();
    }

    /**
     * 初始化
     */
    private function initialize() : void {
        stage.addEventListener( Event.RESIZE, stage_resizeEventHandler, false, 0, true );

        try { Security.allowDomain( '*' ); } catch (e:*) {} // Air doesn't support this, so fix it as try catch.

        if ( ExternalInterface.available ) {
            ExternalInterface.addCallback( "getCrashLog", getCrashLog );
        }

        _configMap = _configMap || new CMap();
        _configMap.clear();

        for ( var k : String in this.loaderInfo.parameters ) {
            _configMap.add( EXTERNAL + "." + k, this.loaderInfo.parameters[ k ] );
        }

        m_sPreventCache = _configMap.find( 'external.timestamp' );
        if ( !m_sPreventCache ) {
            m_sPreventCache = new Date().valueOf().toString();
        }

        var _configXML : String = _configMap.find( EXTERNAL + ".configXML" );
        var _cdnXML : String = _configMap.find( EXTERNAL + ".cdnXML" );
        var _skipDriverValidation : Boolean = _configMap.find( EXTERNAL + ".skipDriver" );

        clientLog( 1004 );

        _procedureManager = _procedureManager || new CProcedureManager( stage.frameRate );
        _procedureManager.addSequential( sayHello, "Hello, Welcome to KO fighting." );
        _procedureManager.addParallel( showVendorLogo );
        _procedureManager.addSequential( loadCdnUrls, ( _cdnXML || "cdn.xml" ) + "?_=" + m_sPreventCache );
        if ( !_skipDriverValidation )
            _procedureManager.addSequential( stage3dValidation );
        _procedureManager.addSequential( loadVersionTxt, "version.txt?_=" + m_sPreventCache );
        _procedureManager.addParallel( loadAssetVersionTxt );
        _procedureManager.addSequential( progressLoadingStatus, CLoadingStatusView );

        _procedureManager.addParallel( startWithXmlConfig, ( _configXML || "config.xml" ) + "?_=" + m_sPreventCache, true );

        _procedureManager.addParallel( showRandomTips );
        _procedureManager.addSequential( loadLanguageXml );
        _procedureManager.addSequential( loadGameDll );

        // Hacking detection.
        // CLoadingMain.swf必需是作为最顶级容器载入运行
//        CONFIG::release {
//            if ( root.name != "root1" ) {
        //noinspection InfiniteLoopJS
//                while ( true ) {
//                }
//            }
//        }
    }

    /**
     * 舞台重定义大小事件控制
     */
    private function stage_resizeEventHandler( event : Event ) : void {
        // TODO(Jeremy): handle stage resize.
        Foundation.Log.logMsg( "Stage resize ..., handle required." );
        this.layoutVendorLogo();
        this.layoutLoadingStatusView();
    }

    /** @private */
    private static function stage_mouseRightClickEventHandler( event : MouseEvent ) : void {
        // Prevent RIGHT-CLICK.
        if ( !event.shiftKey )
            event.preventDefault();
    }

    /** @private */
    private function stage_enterFrameHandler( event : Event ) : void {
        var fElapsedTime : Number = getTimer();
        if ( isNaN( m_fElapsedTime ) )
            m_fElapsedTime = fElapsedTime;
        var delta : Number = fElapsedTime - m_fElapsedTime;
        m_fElapsedTime = fElapsedTime;
        if ( delta )
            update( delta / 1000.0 );
    }

    protected function update( delta : Number ) : void {
        if ( m_bDummyProgressEnabled )
            this.progressDummySingleRatioLoading( delta );
    }

    /**
     * 居中布局VendorLogo
     */
    private function layoutVendorLogo() : void {
        if ( !_logo )
            return;
//        _logo.x = stage.stageWidth - _logo.width >> 1;
//        _logo.y = stage.stageHeight - _logo.height >> 1;
        _logo.x = stage.stageWidth >> 1;
        _logo.y = stage.stageHeight >> 1;
    }

    public function get loadingStatusView() : Sprite {
        return _loadingView;
    }

    /**
     * 正确布局载入进度显示页
     */
    private function layoutLoadingStatusView() : void {
//        if ( !loadingStatusView )
//            return;
//        loadingStatusView.scaleX = Math.max(1, stage.stageWidth / 1500);
//        loadingStatusView.scaleY = Math.max(1, stage.stageHeight / 900);
    }

    //noinspection JSMethodCanBeStatic
    private function sayHello( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        Foundation.Log.flush();
        Foundation.Log.logMsg( theProcedureTags.arguments[ 0 ] );
        return true;
    }

    public function get cdnURI() : String {
        var ret : String = null;
        if ( _configMap && 'CdnURI' in _configMap ) {
            ret = _configMap[ 'CdnURI' ];
        }

        if ( null == ret ) {
            ret = "";
        } else if ( ret.length > 0 ) {
            if ( ret.charAt( ret.length - 1 ) != '/' )
                ret += '/';
        }
        return ret;
    }

    private var _dummy : BitmapData;
    private var _dummyTimer : Timer;

    /**
     * 验证Stage3D的合法性
     */
    private function stage3dValidation( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        _stage3d = stage.stage3Ds[ 0 ];
        _stage3d.addEventListener( Event.CONTEXT3D_CREATE, stage3d_createContextEventHandler );
        _stage3d.addEventListener( ErrorEvent.ERROR, stage3d_errorEventHandler );
        _stage3d.requestContext3D();

        var bDone : Boolean = false;

        function stage3d_errorEventHandler( event : Event ) : void {
            _stage3d.removeEventListener( Event.CONTEXT3D_CREATE, stage3d_createContextEventHandler );
            _stage3d.removeEventListener( ErrorEvent.ERROR, stage3d_errorEventHandler );

            Foundation.Log.logMsg( "Context3D Created." );

            showError( "Context3D created failed!!!" );

            bDone = false;
        }

        function stage3d_createContextEventHandler( event : Event ) : void {
            _stage3d.removeEventListener( Event.CONTEXT3D_CREATE, stage3d_createContextEventHandler );
            _stage3d.removeEventListener( ErrorEvent.ERROR, stage3d_errorEventHandler );

            Foundation.Log.logMsg( "Context3D Created." );

            var driverInfo : String = _stage3d.context3D.driverInfo;

            if ( _configMap ) {
                _configMap.add( "driverInfo", driverInfo );
            }

            if ( driverInfo.slice( 0, 8 ).toLowerCase() == "software" ) {
                // 软件模式不能运行
                if ( driverInfo.indexOf( "Hw_disabled=userDisabled" ) >= 0 ) {
                    // prompt guide tutorial.
                    showSoftwareUserDisabledGuideView();
                    clientLog( 1006 );
                    bDone = false;
                } else {
                    clientLog( 1007 );
                    // showError( "当前FlashPlayer不支持3D硬件加速，不能正常进行游戏！！！" );
                    showSoftwareUnavailableGuideView();
                    stage.addEventListener("_SoftwareModeIgnoredGaming_", _stage_onSoftwareModeIgnoredGamingEventHandler, false, 0 );

                    function _stage_onSoftwareModeIgnoredGamingEventHandler( event : Event ) : void {
                        // 强制软件模式运行游戏
                        stage.removeEventListener( "_SoftwareModeIgnoredGaming_", _stage_onSoftwareModeIgnoredGamingEventHandler );

                        m_iCategoryOfLoadingView = 2;
                        bDone = true;
                    }
                }
            } else {
                bDone = true;
                clientLog( 1005 );
            }

            _stage3d.context3D.dispose();
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            return bDone;
        };
        return true;
    }

    private function showSoftwareUnavailableGuideView() : void {
        var pGuideBgLoader : Loader = new Loader();
        var sGuideBg : String = "assets/ui/loading/software.swf";
        sGuideBg = cdnURI + sGuideBg;
        sGuideBg += "?_=" + m_sPreventCache;

        var vUrlRequest : URLRequest = new URLRequest( sGuideBg );
        var vUrlStream : URLStream = new URLStream();
        vUrlStream.load( vUrlRequest );

        var vStreamData : ByteArray = new ByteArray();

        vUrlStream.addEventListener( ProgressEvent.PROGRESS, _onProgress );
        vUrlStream.addEventListener( Event.COMPLETE, _onComplete );
        vUrlStream.addEventListener( ErrorEvent.ERROR, _onComplete );
        vUrlStream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
        pGuideBgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onBytesComplete );

        stage.addEventListener( Event.RESIZE, _stage_resizeEventHandler, false, 0, true );
        stage.addEventListener("_SoftwareModeIgnoredGaming_", _stage_onSoftwareModeIgnoredGamingEventHandler, false, 0 );

        function _stage_onSoftwareModeIgnoredGamingEventHandler( event : Event ) : void {
            stage.removeEventListener( "_SoftwareModeIgnoredGaming_", _stage_onSoftwareModeIgnoredGamingEventHandler );

            if ( pGuideBgLoader && pGuideBgLoader.parent )
                pGuideBgLoader.parent.removeChild( pGuideBgLoader );
        }

        function _stage_resizeEventHandler( event : Event ) : void {
            _relayoutLoader( pGuideBgLoader, null, pGuideBgLoader.contentLoaderInfo.width, pGuideBgLoader.contentLoaderInfo.height );
        }

        function _onProgress( e : ProgressEvent ) : void {
            var iLen : int = vStreamData.length;
            vUrlStream.readBytes( vStreamData, vStreamData.length );
            if ( vStreamData.length > iLen ) {
                pGuideBgLoader.loadBytes( vStreamData );
            }
        }

        function _onBytesComplete( event : Event ) : void {
            pGuideBgLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _onBytesComplete );
            _relayoutLoader( pGuideBgLoader, null, pGuideBgLoader.contentLoaderInfo.width, pGuideBgLoader.contentLoaderInfo.height );
        }

        function _onComplete( e : Event ) : void {
            stage.addChild( pGuideBgLoader );

            vUrlStream.close();
            vUrlStream.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
            vUrlStream.removeEventListener( Event.COMPLETE, _onComplete );
            vUrlStream.removeEventListener( ErrorEvent.ERROR, _onComplete );
            vUrlStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
        }
    }

    protected function showSoftwareUserDisabledGuideView() : void {
        var pGuideBgLoader : Loader = new Loader();
        var sGuideBg : String = "assets/ui/loading/hw_user_disabled_tip.jpg";
        sGuideBg = cdnURI + sGuideBg;
        sGuideBg += "?_=" + m_sPreventCache;

        var vUrlRequest : URLRequest = new URLRequest( sGuideBg );
        var vUrlStream : URLStream = new URLStream();
        vUrlStream.load( vUrlRequest );

        var vStreamData : ByteArray = new ByteArray();

        vUrlStream.addEventListener( ProgressEvent.PROGRESS, _onProgress );
        vUrlStream.addEventListener( Event.COMPLETE, _onComplete );
        vUrlStream.addEventListener( ErrorEvent.ERROR, _onComplete );
        vUrlStream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
        pGuideBgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onBytesComplete );

        stage.addEventListener( Event.RESIZE, _stage_resizeEventHandler, false, 0, true );

        function _stage_resizeEventHandler( event : Event ) : void {
            _relayoutLoader( pGuideBgLoader );
        }

        function _onProgress( e : ProgressEvent ) : void {
            var iLen : int = vStreamData.length;
            vUrlStream.readBytes( vStreamData, vStreamData.length );
            if ( vStreamData.length > iLen ) {
                pGuideBgLoader.loadBytes( vStreamData );
            }
        }

        function _onBytesComplete( event : Event ) : void {
            pGuideBgLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _onBytesComplete );
            _relayoutLoader( pGuideBgLoader );
        }

        function _onComplete( e : Event ) : void {
            _relayoutLoader( pGuideBgLoader );
            stage.addChild( pGuideBgLoader );

            vUrlStream.close();
            vUrlStream.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
            vUrlStream.removeEventListener( Event.COMPLETE, _onComplete );
            vUrlStream.removeEventListener( ErrorEvent.ERROR, _onComplete );
            vUrlStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
        }

        Security.showSettings( SecurityPanel.DISPLAY );
        _dummyTimer = new Timer( 200 );
        _dummyTimer.addEventListener( TimerEvent.TIMER, _delayTickUserDisabledGuide );
        _dummyTimer.start();
    }

    final private function _relayoutLoader( pLoader : Loader, content : DisplayObject = null, width : Number = NaN, height : Number = NaN ) : void {
        content = content || pLoader.contentLoaderInfo.content;
        if ( pLoader && content ) {
            width = isNaN(width) ? content.width : width;
            height = isNaN(height) ? content.height : height;

            pLoader.x = stage.stageWidth - width >> 1;
            pLoader.y = stage.stageHeight - height >> 1;
        }
    }

    private function _delayTickUserDisabledGuide( e : TimerEvent ) : void {
        if ( !_dummy )
            _dummy = new BitmapData( 1, 1 );

        if ( _dummy ) {
            var closed : Boolean = true;
            try {
                _dummy.draw( stage );
            } catch ( error : Error ) {
                closed = false;
            }

            if ( closed ) {
                if ( _dummyTimer )
                    _dummyTimer.stop();
                if ( ExternalInterface.available ) {
                    navigateToURL( new URLRequest( ExternalInterface.call( "window.location.href.toString" ) ), "_self" );
                }
            }
        }

    }

    private var m_theMessageTF : TextField = new TextField();
    private var m_pMessageBgLoader : Loader = new Loader();

    private function showMessage( strMessage : String = null ) : void {
        if ( !m_pMessageBgLoader.parent ) {
            var sImgURL : String = "assets/ui/loading/tipbg.png";
            sImgURL = cdnURI + sImgURL;
            sImgURL += "?_=" + m_sPreventCache;

            var vUrlRequest : URLRequest = new URLRequest( sImgURL );
            var vUrlStream : URLStream = new URLStream();
            vUrlStream.load( vUrlRequest );

            var vStreamData : ByteArray = new ByteArray();

            vUrlStream.addEventListener( ProgressEvent.PROGRESS, _onProgress );
            vUrlStream.addEventListener( Event.COMPLETE, _onComplete );
            vUrlStream.addEventListener( ErrorEvent.ERROR, _onComplete );
            vUrlStream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
            m_pMessageBgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onBytesComplete );

            stage.addEventListener( Event.RESIZE, _stage_resizeEventHandler, false, 0, true );

            function _stage_resizeEventHandler( event : Event ) : void {
                _relayoutLoader( m_pMessageBgLoader );
                m_theMessageTF.x = stage.stageWidth / 2 - 74;
                m_theMessageTF.y = stage.stageHeight / 2 - 36;
            }

            function _onProgress( e : ProgressEvent ) : void {
                var iLen : int = vStreamData.length;
                vUrlStream.readBytes( vStreamData, vStreamData.length );
                if ( vStreamData.length > iLen ) {
                    m_pMessageBgLoader.loadBytes( vStreamData );
                }
            }

            function _onBytesComplete( event : Event ) : void {
                m_pMessageBgLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _onBytesComplete );
                stage.addChild( m_pMessageBgLoader );
                _relayoutLoader( m_pMessageBgLoader );

                var format : TextFormat = new TextFormat();
                format.font = "微软雅黑,Arial,SimSum";
                format.size = 14;
                format.bold = true;
                format.color = 0xFFFFFF;
                m_theMessageTF.defaultTextFormat = format;
                m_theMessageTF.filters = [ new GlowFilter( 0x170702, 0.8, 2, 2, 10, 1 ) ];
                m_theMessageTF.x = stage.stageWidth / 2 - 74;
                m_theMessageTF.y = stage.stageHeight / 2 - 36;
                m_theMessageTF.mouseEnabled = m_theMessageTF.selectable = false;
                m_theMessageTF.wordWrap = true;
                m_theMessageTF.multiline = true;
                m_theMessageTF.width = 300;
                m_theMessageTF.height = 100;
                stage.addChild( m_theMessageTF );

                setMessage(strMessage);
            }

            function _onComplete( e : Event ) : void {
                vUrlStream.close();
                vUrlStream.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
                vUrlStream.removeEventListener( Event.COMPLETE, _onComplete );
                vUrlStream.removeEventListener( ErrorEvent.ERROR, _onComplete );
                vUrlStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete );
            }
        } else {
            setMessage(strMessage);
        }

        function setMessage(str:String):void {
            m_theMessageTF.htmlText = str;
        }
    }

    /**
     * 显示Software 3D兼容错误提示
     */
    private function showError( errorMessage : String = null ) : void {
        var bg : Sprite = new Sprite();
        var w : int = 400;
        var h : int = 100;
        bg.graphics.beginFill( 0xAA0000 );
        bg.graphics.drawRoundRect( stage.stageWidth - w >> 1, stage.stageHeight - h >> 1, w, h, 4, 4 );
        bg.graphics.endFill();
        addChild( bg );

        var tf : TextField = new TextField();
        var fmt : TextFormat = new TextFormat();
        fmt.font = "微软雅黑,SimSun,宋体";
        fmt.size = 12;
        tf.defaultTextFormat = fmt;

        tf.filters = [ new GlowFilter( 0x0, 1.0, 2, 2, 10 ) ];
        tf.text = errorMessage || "Error caught!!!";
        tf.width = w;
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.x = stage.stageWidth - tf.width >> 1;
        tf.y = stage.stageHeight - tf.height >> 1;
        tf.selectable = false;
        tf.textColor = 0xFFFFFF;

        addChild( tf );
    }

    /**
     * 显示开发商等版权信息
     */
    private function showVendorLogo( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        if ( !_logo ) {
            var logoClass : Class = CClassUtil.getClassByAliasName( "VendorLogo", MovieClip );
            if ( logoClass )
                _logo = new logoClass();
        }

        if ( !_logo ) {
            return true;
        }

        _logo.addEventListener( Event.ENTER_FRAME, _vendorLogoEnterFrameHandler, false, 0, true );

        this.layoutVendorLogo();

        if ( !_logo.parent )
            this.addChild( _logo );

        var bDone : Boolean = false;
        var iLastTimer : Number = getTimer();

        function _vendorLogoEnterFrameHandler( event : Event ) : void {
            if ( _logo.currentFrame == _logo.totalFrames - 1 ) {
                // Play all.
                _logo.removeEventListener( Event.ENTER_FRAME, _vendorLogoEnterFrameHandler );
                _logo.stop();
                if ( _logo.parent ) {
                    _logo.parent.removeChild( _logo );
                }

                Foundation.Log.logMsg( "VendorLog PlayEnd." );
                bDone = true;
            } else {
                var iNow : Number = getTimer();
                if ( iNow - iLastTimer >= ( 1000 / 24 ) ) {
                    iLastTimer = iNow;
                    _logo.gotoAndStop( _logo.currentFrame + 1 );
                }
            }
        }

        _logo.gotoAndStop( 0 );

        theProcedureTags.isProcedureFinished = function () : Boolean {
            return bDone;
        };

        return true;
    }

    /**
     * 载入CDN的URI列表
     */
    private function loadCdnUrls( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        var strCdnXmlUrl : String = theProcedureTags.arguments[ 0 ];

        Foundation.Log.logMsg( "Start loading CDN urls, filepath: " + strCdnXmlUrl );

        var bDone : Boolean = false;
        var urlXML : CURLXml = new CURLXml( strCdnXmlUrl );
        urlXML.startLoad( _onFinished, null );

        function _onFinished( file : CURLXml, error : int ) : void {
            if ( 0 == error ) {
                var xml : XML = file.xmlObject as XML;
                var cdnList : Array = [];
                for each ( var cdnXMLItem : XML in xml..cdn ) {
                    cdnList.push( String( cdnXMLItem ) );
                }

                cdnList = cdnList.filter( function ( item : *, idx : int, arr : Array ) : * {
                    if ( item && item.toString() ) {
                        return true;
                    }
                    return false;
                } );

                Foundation.Log.logMsg( "CDNs: " + cdnList.join( ', ' ) );
                if ( cdnList.length )
                    _configMap.add( "CdnURI", cdnList[ 0 ] );
                else
                    _configMap.add( "CdnURI", "" );
            } else {
                var errorMessage : String = "Loaded CDN urls [" + file.loadingURL + "] failed, error code " + error;
                Foundation.Log.logErrorMsg( errorMessage );
                showError( errorMessage );
                throw errorMessage;
            }

            bDone = true;
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( urlXML )
                urlXML.update();
            return bDone;
        };

        return true;
    }

    private function loadVersionTxt( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        var strVersionTxtUrl : String = theProcedureTags.arguments[ 0 ];

        strVersionTxtUrl = cdnURI + strVersionTxtUrl;

        Foundation.Log.logMsg( "Start loading VERSION txt, filepath: " + strVersionTxtUrl );

        var bDone : Boolean = false;
        var curl : CURLFile = new CURLFile( strVersionTxtUrl );
        curl.startLoad( _onFinished, null );

        function _onFinished( file : CURLFile, error : int ) : void {
            if ( 0 == error ) {
                var strContent : String = file.readAllText();
                var lines : Array = strContent.split( "\n" );
                var tmpArr : Array;
                var majorNumber : int, minorNumber : int, fixNumber : int, branchNumber : int;
                for each ( var line : String in lines ) {
                    if ( !line )
                        continue;
                    line = StringUtil.trim( line );
                    if ( line == '' || line == '\r' || line.charAt( 0 ) == '#' )
                        continue;
                    if ( line.slice( 0, 5 ) == 'MAJOR' ) {
                        line = line.slice( 5 );
                        if ( line.lastIndexOf( '=' ) >= 0 ) {
                            tmpArr = line.split( '=' );
                            line = tmpArr[ tmpArr.length - 1 ];
                            line = line.replace( "'", '' ).replace( '"', '' );
                            majorNumber = parseInt( line );
                        }
                    } else if ( line.slice( 0, 5 ) == 'MINOR' ) {
                        line = line.slice( 5 );
                        if ( line.lastIndexOf( '=' ) >= 0 ) {
                            tmpArr = line.split( '=' );
                            line = tmpArr[ tmpArr.length - 1 ].replace( "'", '' ).replace( '"', '' );
                            minorNumber = parseInt( line );
                        }
                    } else if ( line.slice( 0, 3 ) == 'FIX' ) {
                        line = line.slice( 3 );
                        if ( line.lastIndexOf( '=' ) >= 0 ) {
                            tmpArr = line.split( '=' );
                            line = tmpArr[ tmpArr.length - 1 ].replace( "'", '' ).replace( '"', '' );
                            fixNumber = parseInt( line );
                        }
                    } else if ( line.slice( 0, 6 ) == 'BRANCH' ) {
                        line = line.slice( 6 );
                        if ( line.lastIndexOf( '=' ) >= 0 ) {
                            tmpArr = line.split( '=' );
                            line = tmpArr[ tmpArr.length - 1 ].replace( "'", '' ).replace( '"', '' );
                            branchNumber = parseInt( line );
                        }
                    } else {
                        //ignore.
                    }
                }

                var strBuildVersion : String = [ majorNumber, minorNumber, fixNumber, branchNumber ].join( '.' );
                Foundation.Log.logMsg( "Parsed VERSION txt to build version: " + strBuildVersion );

                _configMap.add( 'build_version', strBuildVersion );

            } else {
                // Ignore the version.txt load failed.
//                var errorMessage : String = "Loaded VERSION txt [" + file.loadingURL + "] failed, error code " + error;
//                Foundation.Log.logErrorMsg( errorMessage );
//                showError( errorMessage );
//                throw errorMessage;
            }

            bDone = true;
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( curl )
                curl.update();
            return bDone;
        };

        return true;
    }

    private function loadAssetVersionTxt( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        var sFilePath : String = theProcedureTags.arguments.length > 1 ?
                theProcedureTags.arguments[ 0 ] : "assets/asset_version.txt";

        Foundation.Log.logMsg( "Start loading asset_version.txt, path: " + sFilePath );

        sFilePath = cdnURI + sFilePath;

        var pAssetVersion : CAssetVersion = new CAssetVersion();
        pAssetVersion.loadFile( sFilePath, "assets", _onAssetVersionLoadCompleted );

        var bDone : Boolean = false;

        function _onAssetVersionLoadCompleted( pFile : CURLFile, idError : int ) : void {
            if ( idError == 0 ) {
                // load success.
                m_pAssetVersion = pAssetVersion;
                _configMap.add( 'asset_version', pAssetVersion );
            } else {
                Foundation.Log.logErrorMsg( "Can't load asset version file: " + sFilePath );
            }

            bDone = true;
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( pAssetVersion ) {
                pAssetVersion.update( 0 );
            }
            return bDone;
        };

        return true;
    }

    /**
     * 载入config.xml
     */
    private function startWithXmlConfig( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        Foundation.Log.logMsg( "Start loading XML config, path: " + theProcedureTags.arguments[ 0 ] );

        var bDone : Boolean = false;

        var cdnURI : String = _configMap && theProcedureTags.arguments[ 1 ] === true ? this.cdnURI : "";

        var urlXML : CURLXml = new CURLXml( cdnURI + theProcedureTags.arguments[ 0 ] );
        urlXML.startLoad( _onFinished, null );

        function _onFinished( file : CURLXml, error : int ) : void {
            if ( error == 0 ) {
                clientLog( 1008 );
                Foundation.Log.logMsg( "Loaded XML config [" + file.loadingURL + "]." );
                var xml : XML = file.xmlObject as XML;

                // NOTE(Jeremy): Test data below.
                Foundation.Log.logMsg( "Debug Version: " + Boolean( int( xml..isDebugVersion ) ) );
                Foundation.Log.logMsg( "Bin Encryption: " + Boolean( int( xml..isEncryption ) ) );
                Foundation.Log.logMsg( "Config Encryption: " + Boolean( int( xml..isConfigEncryption ) ) );
                Foundation.Log.logMsg( "Protocol Encryption: " + Boolean( int( xml..enableProtocolEncryption ) ) );
                Foundation.Log.logMsg( "Language: " + String( xml..language ) );
                Foundation.Log.logMsg( "Sandbox: " + int( xml..sandbox.@port ) );

                _configMap.add( "ConfigRaw", xml );

                bDone = true;
            } else {
                clientLog( 1009 );
                // error caught.
                var errorMessage : String = "Load XML config [" + file.loadingURL + "] failed, error code " + error;
                Foundation.Log.logErrorMsg( errorMessage );
                showError( errorMessage );
                throw errorMessage;
            }
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( urlXML )
                urlXML.update();
            return bDone;
        };

        return true;
    }

    /**
     * 载入LoadingStatusView到舞台显示列表
     */
    private function progressLoadingStatus( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        if ( _logo && _logo.parent )
            _logo.parent.removeChild( _logo );

        try {
            if ( !loadingStatusView )
                createLoadingStatusView();
        }
        catch ( e : Error ) {
            // Import classes error caught ?
            Foundation.Log.logErrorMsg( "Creating CLoadingStatusView ERROR CAUGHT: " + e.message );
        }

        // this.layoutLoadingStatusView();

        if ( loadingStatusView )
            addChild( loadingStatusView );

        clientLog( [ 2001, 2002 ] [ m_iCategoryOfLoadingView ]);

        this._loadingView.ratioSingle = 0.0;
        this._loadingView.ratioTotal = 0.3;
        m_fDummyProgressFactor = 1.0;
        m_bDummyProgressEnabled = true;

        stage.addEventListener( Event.ENTER_FRAME, stage_enterFrameHandler, false, 0, true );

        Foundation.Log.logMsg( "Progress loading status, show the view ..." );

        theProcedureTags.isProcedureFinished = function () : Boolean {
            return true;
        };

        return true;
    }

    private function createLoadingStatusView() : void {
        var bgUrls : Array = [
            "assets/ui/loading/bg_loading_02.jpg",
            "assets/ui/loading/bg_loading_01.swf",
            "assets/ui/loading/bg_loading_software.swf",
        ];

        if ( m_pAssetVersion ) {
            for ( var i : int = 0; i < bgUrls.length; ++i ) {
                bgUrls[ i ] = m_pAssetVersion.mappingFilenameWithVersion( bgUrls[ i ] );
            }
        }

        // m_iCategoryOfLoadingView = int( ( Math.random() * 1000 ) % 2 );
        if ( m_iCategoryOfLoadingView == 0 )
            m_iCategoryOfLoadingView = 1;

        _loadingView = new LoadingBarMovieClip( {
            background : cdnURI + bgUrls[ m_iCategoryOfLoadingView ]
        } );
    }

    private function progressDummySingleRatioLoading( delta : Number ) : void {
        if ( !this._loadingView )
            return;

        if ( this._loadingView.ratioTotal >= 1.0 ) {
            this._loadingView.ratioSingle = 1.0;
        } else {
            if ( this._loadingView.ratioSingle >= 1.0 ) {
                this._loadingView.ratioSingle = 0.0;
                m_fDummyProgressFactor = 0.2 + Math.random();
            } else {
                var inc : Number = delta * ( m_fDummyProgressFactor + -0.5 + Math.random() );
                this._loadingView.ratioSingle += Math.max( inc, 0 );
            }
        }

        // emulation total progress.
        m_fDummyProgressTimeRemaining -= delta;
        m_fDummyProgressTimeRemaining = Math.max( m_fDummyProgressTimeRemaining, 0 );

        var p : Number = ( m_fDummyProgressTimeTotal - m_fDummyProgressTimeRemaining ) / m_fDummyProgressTimeTotal;
        p = Math.min( p, 1 );
        p = Math.sqrt( 1 - ( p = p - 1 ) * p );

        var fRatioTotal : Number = 0.3 + p * ( 0.9999 - 0.3 );
        if ( fRatioTotal > 0.9999 )
            fRatioTotal = 0.9999;
        this._loadingView.ratioTotal = fRatioTotal;
    }

    /**
     * 依照config.xml的配置随机在LoadingStatusView中显示提示
     */
    private function showRandomTips( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        Foundation.Log.logMsg( "Random show tips at loading status." );

        var configXML : XML = _configMap[ 'ConfigRaw' ] as XML;
        if ( configXML && loadingStatusView ) {
            // FIXME: loadingStatusView.startShowRandomTips( configXML );
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            return true;
        }
        ;
        return true;
    }

    /**
     * 加载GameDLL游戏主程序
     */
    private function loadGameDll( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        stage.addEventListener( MouseEvent.RIGHT_CLICK, stage_mouseRightClickEventHandler, false, 0, true );

//        this._loadingView.loadingMessage = "正在加载主程序...";
        this._loadingView.loadingMessage = "";

        Foundation.Log.logMsg( "Ready loading GameDLL ..." );

        var bDone : Boolean = false;

        var strGameClientSwf : String = "assets/bin/GameClient.swf";

        CONFIG::release {
            if ( m_pAssetVersion ) {
                strGameClientSwf = m_pAssetVersion.mappingFilenameWithVersion( strGameClientSwf );
            }
        }

        CONFIG::debug {
            strGameClientSwf = strGameClientSwf + "?_=" + m_sPreventCache;
        }

        strGameClientSwf = cdnURI + strGameClientSwf;

        var swf : CURLSwf = new CURLSwf( strGameClientSwf );
        swf.allowCodeImport = true;

        swf.startLoad( _onFinished, _onProgress );

        function _onFinished( file : CURLFile, error : int ) : void {
            if ( error == 0 ) {
                var info : LoaderInfo = swf.loader.contentLoaderInfo;
                CHideSwfUtil.hideSWF( info.bytes );

                clientLog( 1010 );

                Foundation.Log.logMsg( "Loaded GameClient Content & Added to stage." );
                Foundation.Log.logMsg( "//------------------------------------------------------------------------------" );

                addChild( info.content );

                var pEventDispatcher : IEventDispatcher = stage;
                var pApplication : Object = info.content[ 'application' ];
                if ( pApplication && pApplication.hasOwnProperty( 'eventDispatcher' ) ) {
                    pEventDispatcher = pApplication.eventDispatcher as IEventDispatcher;
                }

                m_bDummyProgressEnabled = true;

                pEventDispatcher.addEventListener( "_applicationProgress", _onApplicationProgress, false, 0, true );
                pEventDispatcher.addEventListener( "_fatalError", _onApplicationFatalError, false, 0, true );
                pEventDispatcher.addEventListener( "_showMessage", _onApplicationFatalError, false, 0, true );
                pEventDispatcher.dispatchEvent( new Request( "ENV_SETUP", false, false, _configMap ) );

                m_pAppEventDelegate = pEventDispatcher;

                bDone = true;

            } else {
                var errorMessage : String = "Loaded " + file.loadingURL + " Failed: " + error;
                Foundation.Log.logErrorMsg( errorMessage );
                showError( errorMessage );
                throw errorMessage;
            }
        }

        function _onProgress( file : CURLFile, loadedBytes : Number, totalBytes : Number ) : void {
            // TODO: onProgress.
//            if ( loadingStatusView )
//                loadingStatusView.setStatus( 1, 1, loadedBytes, totalBytes, "GameClient" );
            var fRatio : Number = loadedBytes / totalBytes;
            if ( _loadingView && _loadingView.ratioSingle < fRatio ) {
                _loadingView.ratioSingle = fRatio;
//                _loadingView.ratioTotal = fRatio * 0.3;
            }
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( swf )
                swf.update();
            return bDone;
        };

        return true;
    }
    /**
     * 加载GameDLL游戏主程序
     */
    private function loadLanguageXml( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        var language:String = _configMap["ConfigRaw"]..language;
        var sFilePath : String = "assets/" + language + ".xml";


        CONFIG::release {
            if ( m_pAssetVersion ) {
                sFilePath = m_pAssetVersion.mappingFilenameWithVersion( sFilePath );
            }
        }
        CONFIG::debug {
            sFilePath = sFilePath + "?_=" + m_sPreventCache;
        }


        Foundation.Log.logMsg( "Start loading zh_cn.xml, path: " + sFilePath );

        sFilePath = cdnURI + sFilePath;

        var urlXML : CURLXml = new CURLXml( sFilePath );
        urlXML.startLoad( _onFinished, null );

        var bDone:Boolean;
        function _onFinished( file : CURLXml, error : int ) : void {
            if ( error == 0 ) {
                Foundation.Log.logMsg( "Loaded XML config [" + file.loadingURL + "]." );
                var xml : XML = file.xmlObject as XML;
                _configMap.add( "language", xml );
                bDone = true;
            } else {
                // error caught.
                var errorMessage : String = "Load XML config [" + file.loadingURL + "] failed, error code " + error;
                Foundation.Log.logErrorMsg( errorMessage );
                showError( errorMessage );
                throw errorMessage;
            }
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( urlXML )
                urlXML.update();
            return bDone;
        };

        return true;
    }

    private function _onApplicationFatalError( e : ErrorEvent ) : void {
        this.removeChildren();
        if ( e.type == "_showMessage" ) {
            this.showMessage( e.text );
        } else {
            this.showError( e.text );
        }
    }

    private function _onApplicationProgress( e : ProgressEvent ) : void {
        var fRatioTotal : Number = e.bytesLoaded / e.bytesTotal;
        if ( fRatioTotal >= 1.0 ) {
            m_bDummyProgressEnabled = false;

            e.currentTarget.removeEventListener( e.type, _onApplicationProgress );
            _procedureManager.addSequential( _removePreloading );
            this._loadingView.ratioTotal = fRatioTotal;
        }
    }

    private function _removePreloading( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        var bDone : Boolean = false;

        if ( !('endLine' in theProcedureTags ) ) {
            theProcedureTags[ 'endLine' ] = getTimer() + 3000;
        }

        clientLog( [ 2003, 2004, 2004 ][ m_iCategoryOfLoadingView ] );

        stage.removeEventListener( Event.ENTER_FRAME, stage_enterFrameHandler );
        this._loadingView.ratioSingle = 1.0;

        theProcedureTags.isProcedureFinished = function () : Boolean {
            if ( getTimer() >= theProcedureTags.endLine ) {
                // finished.
                stage.removeEventListener( Event.RESIZE, stage_resizeEventHandler );

                if ( _loadingView.parent ) {
                    _loadingView.parent.removeChild( _loadingView );
                }

                stage.dispatchEvent(new Event("LoginSucc"));
                bDone = true;
            }

            return bDone;
        };

        return true;
    }

    public function getCrashLog() : * {
        if ( m_pAppEventDelegate ) {
            var value : Object = {};
            m_pAppEventDelegate.dispatchEvent( new Request( "GET_CRASH_LOG", false, false, value ) );
            for ( var key : String in value )
                return value;
        }
        return null;
    }

}
}
// vi:ft=as3 tw=120 sw=4 ts=4 expandtab tw=120
