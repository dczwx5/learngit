//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import QFLib.Foundation;
import QFLib.Foundation.CAssetVersion;
import QFLib.Foundation.CPath;
import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLSwf;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.Utils.CFlashVersion;
import QFLib.Utils.CHideSwfUtil;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;

import kof.framework.CStandaloneApp;
import kof.framework.IApplication;
import kof.framework.IConfiguration;
import kof.framework.INetworking;
import kof.framework.events.CEventPriority;
import kof.game.common.CLang;
import kof.login.CLoginStage;
import kof.util.CAssertUtils;

import morn.core.handlers.Handler;
import morn.core.managers.ResLoader;

import mx.events.Request;

CONFIG::debug {
//import debug.manager.DebugManager;
}

/**
 * @author Jeremy (jeremy@qifun.com)
 */
[SWF(frameRate="60", backgroundColor="#000000", width="1500", height="900")]
public class CMain extends Sprite {

    public function CMain() {
        if ( stage )
            addedToStage();
        else
            addEventListener( Event.ADDED_TO_STAGE, addedToStage );
    }

    // internal 只是为了去除Warning
    internal var _app : CTestMainApp;

    final public function get application() : IApplication {
        return _app;
    }

    protected function addedToStage( event : Event = null ) : void {
        if ( !_app ) {
            _app = new CTestMainApp( stage );

            if ( !_app.initialize() ) {
                Foundation.Log.logErrorMsg( "CMain Application initialize failed." );
                _app = null;
            }

            if ( _app.eventDispatcher ) {
                _app.eventDispatcher.addEventListener( "ENV_SETUP", _app_envSetupEventHandler, false, 0, true );
            }
        }

        CONFIG::debug {
//        DebugManager.instance.setup(stage);
        }
    }

    private function _app_envSetupEventHandler( event : Request ) : void {
        event.currentTarget.removeEventListener( event.type, _app_envSetupEventHandler );
        var sCdnURI : String = "";
        var configMap : Object = event.value; // as map
        if ( configMap && 'CdnURI' in configMap ) {
            sCdnURI = configMap[ 'CdnURI' ];
            sCdnURI = CPath.addRightSlash( sCdnURI );
        }

        var pAssetVersion : CAssetVersion = null;
        if ( configMap && 'asset_version' in configMap ) {
            pAssetVersion = configMap[ 'asset_version' ] as CAssetVersion;
        }

        if ( pAssetVersion ) {
            CResourceLoaders.instance().insertAssetVersion( pAssetVersion );
            _onAssetVersionCompleted( null, 0 );
        } else {
            CResourceLoaders.instance().createAssetVersion( sCdnURI + "assets/asset_version.txt", "assets", _onAssetVersionCompleted );
        }

        CLang.initialize(configMap["language"]);
        delete configMap["language"];
    }

    private function _onAssetVersionCompleted( pFile : CURLFile, idError : int ) : void {
        if ( idError == 0 ) {
            var sCdnURI : String = application.configuration.getString( "CdnURI", null );
            CResourceLoaders.instance().absoluteURI = sCdnURI;

            var sUIAssetsURI : String = application.configuration.getString( "uiAssetsURI", "assets/ui" );
            Config.resPath = CPath.addRightSlash( sCdnURI || "" ) + CPath.addRightSlash( sUIAssetsURI );

            Config.GAME_FPS = this.stage.frameRate;
            Config.uiPath = "ui.swf";
            Config.tipFollowMove = true;
            Config.tipDelay = 640;
            App.init( this );
            App.loader.retryNum = App.mloader.retryNum = 3;
            ResLoader.minBytePre5Second = 1; // 5秒钟检测1个字节的下载量判定是否重新连接

            if ( Boolean( Config.uiPath ) ) {
                App.loader.loadDB( Config.uiPath, new Handler( onUIloadComplete ) );
            }
        }
    }

    private function onUIloadComplete( content : * ) : void {
        const config : IConfiguration = application.configuration;
        if ( 'dummy' == config.getString( 'external.ip', config.getString( 'ip' ) ) ) {
            // request to dummy mode.
            // load the external dummy module.
            loadDummyModule( onMainEntraince );
        } else {
            onMainEntraince();
        }
    }

    private function loadDummyModule( pfnFinished : Function ) : void {
        var sUrl : String = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion( "assets/bin/GameDummy.swf" );
        var cf : CURLSwf = new CURLSwf( sUrl );
        cf.allowCodeImport = true;
        cf.startLoad( _onFinished, null );

        function _onFinished( file : CURLSwf, idError : int ) : void {
            Foundation.Log.logMsg( "Dummy Module load Finished ( " + idError + " ): " + sUrl );
            if ( 0 == idError ) {
                var info : LoaderInfo = file.loader.contentLoaderInfo;
                CHideSwfUtil.hideSWF( info.bytes );
                if ( 'start' in info.content ) {
                    var fun : Function = info.content[ 'start' ];
                    fun( application );
                }

                if ( null != pfnFinished ) {
                    pfnFinished();
                }
            } else {
                Foundation.Log.logErrorMsg( "Failed to load dummy module: " + file.loadingURL );
            }
        }
    }

    protected function onMainEntraince() : void {
        _app.eventDispatcher.addEventListener( CStandaloneApp.RESTART, _onApplicationRestart, false, CEventPriority.DEFAULT, true );
        _app.runWithStage( new this.stageClass );
    }

    private function _onApplicationRestart( event : Event ) : void {
        this.restart();
    }

    protected function restart() : void {
        var external : Boolean = CFlashVersion.isSandboxPlayer();

        if ( external )
            ExternalInterface.call( "function() { window.location.href = window.location.href }" );

        var pNetworking : INetworking = this.application.runningStage.getSystem( INetworking ) as INetworking;
        CAssertUtils.assertNotNull( pNetworking );
        pNetworking.close();

        if ( !external )
            this.application.replaceStage( new stageClass );
    }

    protected function get stageClass() : Class {
        return CLoginStage;
    }

}
}

import QFLib.Foundation.CLog;

import flash.display.Stage;

import kof.framework.CDelegateNetworkApp;

/**
 * CMain entrance.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class CTestMainApp extends CDelegateNetworkApp {

    function CTestMainApp( stage : Stage ) {
        super( stage );

        this.addItemUpdateListener( "ConfigRaw", _onConfiguration );
    }

    override public function dispose() : void {
        super.dispose();

        this.removeItemUpdateListener( "ConfigRaw", _onConfiguration );
    }

    override protected function _appName() : String {
        return "KOFAdvanced";
    }

    private function _onConfiguration() : void {
        var configXML : XML = configuration.getXML( "ConfigRaw" );
        if ( !configXML )
            return;

        try {
            var logLevelCfg : String = configXML..logLevel.toString();
            var logLevel : int = int( CLog[ "LOG_LEVEL_" + logLevelCfg ] );
            CLog.LOG_THRESHOLD = logLevel;
        } catch ( e : Error ) {
            // ignore.
        }
    }

}

