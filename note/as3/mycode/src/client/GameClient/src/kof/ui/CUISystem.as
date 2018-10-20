//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import QFLib.Interface.IUpdatable;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.CShowDialogTweenData;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.currency.tipview.CTipsViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.loading.CDoublePVPLoadingViewHandler;
import kof.game.loading.CMultiplePVPLoadingViewHandler;
import kof.game.loading.CPVPLoadingData;
import kof.game.loading.CPVPLoadingViewHandler;
import kof.game.loading.CScenarioLoadingViewHandler;
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.mask.CHoldingMaskViewHandler;
import kof.game.mask.CMaskViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.scenario.CBlackScreenDialogueViewHandler;
import kof.game.scenario.CComViewHandler;
import kof.game.scenario.CPlotViewHandler;
import kof.game.scenario.CSingleDialogueViewHandler;
import kof.table.GamePrompt;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.components.registerCustomMornUIComps;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.Container;
import morn.core.components.Dialog;
import morn.core.components.View;
import morn.core.handlers.Handler;
import morn.core.managers.DialogLayer;
import morn.core.managers.DialogManager;
import morn.core.managers.ResLoader;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CUISystem extends CAppSystem implements IUICanvas, IUpdatable {

    /** @{ 层级，由里到外，对应以下由上到下排列 */
    private var m_uiRoot : Container;
    private var m_pDialogLayer : DialogLayer;
    private var m_pTipLayer : DialogLayer;
    private var m_pEffectLayer : Container;
    private var m_pPromptLayer : DialogLayer;
    private var m_plotLayer : DialogLayer;
    private var m_pTutorLayer : Container;
    private var m_pTutorArrowLayer : Container;
    private var m_pMsgLayer : Container;
    private var m_loadingRoot : Container;
    private var m_pAppPromptLayer : DialogLayer;

    private var m_listAllLayers : Vector.<DisplayObjectContainer>;

    private var m_pUIDeps : Object;

    /** UI页面加载资源请求数量 */
    private var m_iCountOfUIPageLoadingRequests : Number = NaN;
    private var m_bShowUILoading : Boolean;

    private var _gamePromptTable:IDataTable;


    /** @} */

    public function CUISystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( this.m_listAllLayers && this.m_listAllLayers.length )
            this.m_listAllLayers.splice( 0, this.m_listAllLayers.length );
        this.m_listAllLayers = null;

        // uiRoot.
        this.removeLayer( m_uiRoot );
        m_uiRoot = null;

        this.removeLayer( m_pDialogLayer );
        m_pDialogLayer = null;

        this.removeLayer( m_pTipLayer );
        m_pTipLayer = null;

        this.removeLayer( m_pPromptLayer );
        m_pPromptLayer = null;

        this.removeLayer( m_plotLayer );
        m_plotLayer = null;

        this.removeLayer( m_pTutorLayer );
        m_pTutorLayer = null;

        this.removeLayer( m_pTutorArrowLayer );
        m_pTutorArrowLayer = null;

        this.removeLayer( m_pMsgLayer );
        m_pMsgLayer = null;

        this.removeLayer( m_loadingRoot );
        m_loadingRoot = null;

        this.removeLayer( m_pAppPromptLayer );
        m_pAppPromptLayer = null;

        this.removeLayer( m_pEffectLayer );
        m_pEffectLayer = null;

        m_pUIDeps = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.initializeMornUI();

        if ( !m_listAllLayers ) {
            m_listAllLayers = new <DisplayObjectContainer>[];
        }

        if ( !m_pAppPromptLayer ) {
            m_pAppPromptLayer = new DialogLayer();
            this.stage.flashStage.addChildAt( m_pAppPromptLayer, 0 );
            m_listAllLayers.push( m_pAppPromptLayer );
        }

        if ( !m_loadingRoot ) {
            m_loadingRoot = new Container();
            this.stage.flashStage.addChildAt( m_loadingRoot, 0 );
            m_listAllLayers.push( m_loadingRoot );

            m_loadingRoot.setPosition( 0, 0 );
            m_loadingRoot.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        if ( !m_pMsgLayer ) {
            m_pMsgLayer = new Container();
            m_pMsgLayer.mouseChildren = m_pMsgLayer.mouseEnabled = false;
            this.stage.flashStage.addChildAt( m_pMsgLayer, 0 );
            m_listAllLayers.push( m_pMsgLayer );

            m_pMsgLayer.setPosition( 0, 0 );
            m_pMsgLayer.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        if ( !m_pTutorArrowLayer ) {
            m_pTutorArrowLayer = new Container();
            m_pTutorArrowLayer.mouseChildren = false;
            m_pTutorArrowLayer.mouseEnabled = false;
            this.stage.flashStage.addChildAt( m_pTutorArrowLayer, 0 );
            m_listAllLayers.push( m_pTutorArrowLayer );

            m_pTutorArrowLayer.setPosition( 0, 0 );
            m_pTutorArrowLayer.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        if ( !m_pTutorLayer ) {
            m_pTutorLayer = new Container();
            this.stage.flashStage.addChildAt( m_pTutorLayer, 0 );
            m_listAllLayers.push( m_pTutorLayer );

            m_pTutorLayer.setPosition( 0, 0 );
            m_pTutorLayer.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        if ( !m_plotLayer ) {
            m_plotLayer = new DialogLayer();
            stage.flashStage.addChildAt( m_plotLayer, 0 );
            m_listAllLayers.push( m_plotLayer );
        }

        if ( !m_pPromptLayer ) {
            m_pPromptLayer = new DialogLayer();
            stage.flashStage.addChildAt( m_pPromptLayer, 0 );
            m_listAllLayers.push( m_pPromptLayer );
        }

        if ( !m_pEffectLayer ) {
            m_pEffectLayer = new Container();
            m_pEffectLayer.mouseChildren = m_pEffectLayer.mouseEnabled = false;
            this.stage.flashStage.addChildAt( m_pEffectLayer, 0 );
            m_listAllLayers.push( m_pEffectLayer );

            m_pEffectLayer.setPosition( 0, 0 );
            m_pEffectLayer.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        if ( !m_pTipLayer ) {
            m_pTipLayer = new DialogLayer();
            stage.flashStage.addChildAt( m_pTipLayer, 0 );
            m_listAllLayers.push( m_pTipLayer );
        }

        if ( !m_pDialogLayer ) {
            m_pDialogLayer = new DialogLayer();
            stage.flashStage.addChildAt( m_pDialogLayer, 0 );
            m_listAllLayers.push( m_pDialogLayer );
        }

        App.dialog = m_pDialogLayer;

        if ( !m_uiRoot ) {
            m_uiRoot = new Container();
            this.stage.flashStage.addChildAt( m_uiRoot, 0 );
            m_listAllLayers.push( m_uiRoot );

            m_uiRoot.setPosition( 0, 0 );
            m_uiRoot.setSize( stage.flashStage.stageWidth, stage.flashStage.stageHeight );
        }

        this.stage.flashStage.addEventListener( Event.RESIZE, _flashStage_resizeEventHandler, false, 0, true );

        ret = ret && this.loadBaseUIAssets();

        if ( ret ) {
            addUIHandlers();
        }

        {
            // all layer keyboard bubbles prevent.
            for each ( var pLayer : DisplayObjectContainer in m_listAllLayers ) {
                pLayer.addEventListener( KeyboardEvent.KEY_DOWN, _layer_keydownEventHandler, false, CEventPriority.DEFAULT, true );
                pLayer.addEventListener( KeyboardEvent.KEY_UP, _layer_keyupEventHandler, false, CEventPriority.DEFAULT, true );
            }
        }

        if(_instanceSystem){
            _instanceSystem.addEventListener( CInstanceEvent.LEVEL_ENTER, _onLevelHandler );
            _instanceSystem.addEventListener( CInstanceEvent.END_INSTANCE, _onLevelHandler );
            _instanceSystem.addEventListener( CInstanceEvent.LEVEL_EXIT, _onLevelHandler );
        }

        return ret;
    }

    protected function addUIHandlers() : Boolean {

        var uiDepsLoaded : Object = App.mloader.getResLoaded( "dep.bin" );
        m_pUIDeps = uiDepsLoaded;

        addBean( new CDebugStatsViewHandler() );

        addBean( new CTipsViewHandler() );
        addBean( new CDefaultTipViewHandler() );

        addBean( new CCursorViewHandler() );
        addBean( new CPlotViewHandler() );
        addBean( new CComViewHandler() );
        addBean( new CBlackScreenDialogueViewHandler() );
        addBean( new CSingleDialogueViewHandler() );
        addBean( new CGlobalViewHandler() );

        addBean( new CMaskViewHandler() );
        addBean( new CHoldingMaskViewHandler() );
        addBean( new CSceneLoadingViewHandler() );
        addBean( new CPVPLoadingViewHandler() );
        addBean( new CScenarioLoadingViewHandler() );
        addBean( new CMultiplePVPLoadingViewHandler() );
        addBean( new CDoublePVPLoadingViewHandler() );

        addBean( new CUIComponentAudioHandler() );
        addBean( new CUIComponentTutorHandler() );

        addBean( new CUILoadingViewHandler() );

        addBean( new CQQGroupOverlayViewHandler() );

        _registerTutorParser();

        return true;
    }

    private function _layer_keydownEventHandler( event : Event ) : void {
        event.stopPropagation();
    }

    private function _layer_keyupEventHandler( event : Event ) : void {
        event.stopPropagation();
    }

    protected function initializeMornUI() : Boolean {
        try {
            if ( !App.stage ) {
                Config.GAME_FPS = this.stage.flashStage.frameRate;
                if ( !Config.resPath )
                    Config.resPath = "assets/ui/";
                if ( !Config.uiPath )
                    Config.uiPath = "ui.swf";

                App.init( this.stage.flashStage.getChildAt( 0 ) as Sprite );
            }

            registerCustomMornUIComps();
            {
                // Components overridden for KOF client.
                View.registerComponent( "SpriteBlitFrameClip", CCharacterFrameClip );
            }

            // Custom properties parser pushing.
            var v_pUIAudioHandler : CUIComponentAudioHandler = getBean( CUIComponentAudioHandler ) as CUIComponentAudioHandler;
            if ( v_pUIAudioHandler )
                View.registerComponentCustomParser( v_pUIAudioHandler.visitUIComponent );
            else
                View.registerComponentCustomParser( this._parseCustomComponentProperties );

        } catch ( e : Error ) {
            LOG.logErrorMsg( "Error caught at CUISystem::initializeMornUI: " + e.message );
            return false;
        }

        return true;
    }

    [Inline]
    final public function get countOfUIPageLoadingRequests() : int {
        if ( isNaN( m_iCountOfUIPageLoadingRequests ) )
            return 0;
        return int( m_iCountOfUIPageLoadingRequests );
    }

    [Inline]
    final public function get showUILoading() : Boolean {
        return m_bShowUILoading;
    }

    final public function set showUILoading( value : Boolean ) : void {
        m_bShowUILoading = value;
    }

    /** @inheritDoc */
    public function loadAssetsByViewClass( viewClasses : Array, additions : Array = null, pfnCompleted : Function = null, pfnProgress : Function = null, pfnError : Function
            = null, isCached : Boolean = true ) : Boolean {

        var deps : Array;
        if ( viewClasses ) {
            for each ( var viewClass : Class in viewClasses ) {
                if ( !viewClass )
                    continue;

                var className : String = getQualifiedClassName( viewClass );
                if ( className )
                    className = className.replace( "::", "." );

                if ( className in m_pUIDeps ) {
                    deps = deps || [];
                }

                if ( deps )
                    deps = deps.concat( m_pUIDeps[ className ].deps );
            }
        }

        if ( !deps || !deps.length )
            deps = additions;
        else if ( additions )
            deps = deps.concat( additions );

        if ( deps && deps.length ) {

            var bLoadNeeded : Boolean = false;
            for each ( var dep : * in deps ) {
                var url : String = dep is String ? dep : dep.url;
                if ( !App.mloader.getResLoaded( url ) ) {
                    bLoadNeeded = true;
                    break;
                }
            }

            if ( bLoadNeeded ) {
                var pLoadingHandler : CUILoadingViewHandler = getHandler( CUILoadingViewHandler ) as CUILoadingViewHandler;
                if ( showUILoading ) {
                    if ( pLoadingHandler ) {
                        pLoadingHandler.value = 0;
                        pLoadingHandler.addDisplay();
                    }
                }

                function _completeWrapper( pfnDelegator : Function, ... args ) : void {
                    m_iCountOfUIPageLoadingRequests--;

                    if ( pLoadingHandler ) {
                        pLoadingHandler.removeDisplay();
                    }

                    if ( null != pfnDelegator ) {
                        pfnDelegator.apply( null, args );
                    }

                    CAssertUtils.assertFalse( m_iCountOfUIPageLoadingRequests < 0 );
                }

                function _progressWrapper( pfnDelegater : Function, fRatio : Number ) : void {
                    if ( pLoadingHandler ) {
                        pLoadingHandler.value = fRatio;
                    }

                    if ( null != pfnDelegater ) {
                        pfnDelegater( fRatio );
                    }
                }

//                    var pCompleteHandler : Handler = null == pfnCompleted ? null : new Handler( pfnCompleted );
//                    var pErrorHandler : Handler = null == pfnError ? null : new Handler( pfnError );
                var pCompleteHandler : Handler = new Handler( _completeWrapper, [ pfnCompleted ] );
                var pErrorHandler : Handler = new Handler( _completeWrapper, [ pfnError ] );
                var pProgressHandler : Handler = new Handler( _progressWrapper, [ pfnProgress ] );

                if ( isNaN( m_iCountOfUIPageLoadingRequests ) )
                    m_iCountOfUIPageLoadingRequests = 0;
                m_iCountOfUIPageLoadingRequests++;

                App.mloader.loadAssets( deps, pCompleteHandler,
                        pProgressHandler, pErrorHandler, isCached );

                return false;
            }
        }

        return true;
    }

    private function _registerTutorParser() : void {
        var tutorHandler : CUIComponentTutorHandler = getBean( CUIComponentTutorHandler ) as CUIComponentTutorHandler;
        if ( tutorHandler ) {
            View.registerComponentCustomParser( tutorHandler.visitUIComponent );
        }

    }

    override protected function setStarted() : void {
        super.setStarted();
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            this.stage.flashStage.removeEventListener( Event.RESIZE, _flashStage_resizeEventHandler );
            if(_instanceSystem){
                _instanceSystem.removeEventListener( CInstanceEvent.LEVEL_ENTER, _onLevelHandler );
                _instanceSystem.removeEventListener( CInstanceEvent.END_INSTANCE, _onLevelHandler );
                _instanceSystem.removeEventListener( CInstanceEvent.LEVEL_EXIT, _onLevelHandler );
            }
        }
        return ret;
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        LOG.logTraceMsg( "uiRoot width: " + m_uiRoot.width + ", height: " + m_uiRoot.height );
    }

    private function _flashStage_resizeEventHandler( event : Event ) : void {
        stage.callLater( onStageResized );
    }

    private function onStageResized( event : Event = null ) : void {
        // on stage resized...
        var fStageWidth : Number = stage.flashStage.stageWidth;
        var fStageHeight : Number = stage.flashStage.stageHeight;

        if ( m_uiRoot )
            m_uiRoot.setSize( fStageWidth, fStageHeight );

        if ( m_loadingRoot )
            m_loadingRoot.setSize( fStageWidth, fStageHeight );

        if ( m_pMsgLayer )
            m_pMsgLayer.setSize( fStageWidth, fStageHeight );

        if ( m_pTutorLayer )
            m_pTutorLayer.setSize( fStageWidth, fStageHeight );

        if (m_pTutorArrowLayer) {
            m_pTutorArrowLayer.setSize(fStageWidth, fStageHeight);
        }

        if (m_pEffectLayer) {
            m_pEffectLayer.setSize(fStageWidth, fStageHeight);
        }
    }

    public function update( delta : Number ) : void {
        if ( !isNaN( m_iCountOfUIPageLoadingRequests ) &&
                m_iCountOfUIPageLoadingRequests <= 0 ) {
            m_iCountOfUIPageLoadingRequests = NaN;

            dispatchEvent( new Event( Event.COMPLETE ) );
        }
    }

    final public function get rootContainer() : DisplayObjectContainer {
        return m_uiRoot;
    }

    final public function get plotLayer() : DialogLayer {
        return m_plotLayer;
    }

    final public function get tutorLayer() : Container {
        return m_pTutorLayer;
    }
    final public function get tutorArrowLayer() : Container {
        return m_pTutorArrowLayer;
    }

    final public function get msgLayer() : Container {
        return m_pMsgLayer;
    }

    final public function get loadingLayer() : DisplayObjectContainer {
        return m_loadingRoot;
    }

    final public function get effectLayer() : DisplayObjectContainer {
        return m_pEffectLayer;
    }

    private var m_pCommonUIRes : Array = [
//        "comp.swf",
//        "common.swf",
//        "imp_common.swf",
        {
            url : "dep.bin",
            type : ResLoader.DB,
            priority : 1
        }
    ];

    private function loadBaseUIAssets() : Boolean {
        var bLoadNeeded : Boolean = false;
        for each ( var s : Object in m_pCommonUIRes ) {
            if ( !App.mloader.getResLoaded( s is String ? String( s ) : s.url ) ) {
                bLoadNeeded = true;
                break;
            }
        }

        if ( bLoadNeeded ) {
            App.mloader.loadAssets( m_pCommonUIRes, new Handler(
                    _onBaseUIAssetsCompleted ), null, null, true );
            return false;
        }

        return true;
    }

    private function _onBaseUIAssetsCompleted() : void {
        addUIHandlers();
        this.makeStarted();
    }

    protected function removeLayer( pLayer : DisplayObjectContainer ) : void {
        if ( !pLayer )
            return;

        if ( pLayer is Container ) {
            (pLayer as Container).removeAllChild();
        } else if ( pLayer is DialogManager ) {
            (pLayer as DialogManager).closeAll();
        }

        if ( pLayer.parent )
            pLayer.parent.removeChild( pLayer );
    }

    public function showMaskView( callBackFun : Function = null, onStartFun : Function = null, onProcessFun : Function = null, showTime : Number = 3.0, color : uint = 0x000000 ) : void {
        var viewHandler : CMaskViewHandler = getBean( CMaskViewHandler ) as CMaskViewHandler;
        viewHandler.show( callBackFun, onStartFun, onProcessFun, showTime, color );
    }

    public function showHoldingMaskView() : void {
        var view : CHoldingMaskViewHandler = getBean( CHoldingMaskViewHandler ) as CHoldingMaskViewHandler;
        view.show();
    }

    public function hideHoldingMaskView() : void {
        var view : CHoldingMaskViewHandler = getBean( CHoldingMaskViewHandler ) as CHoldingMaskViewHandler;
        view.hide();
    }

    public function showPVPLoadingView() : void {
        var viewHandler : CPVPLoadingViewHandler = getBean( CPVPLoadingViewHandler ) as CPVPLoadingViewHandler;
        viewHandler.show();
    }

    public function removePVPLoadingView() : void {
        var pLoadingView : CPVPLoadingViewHandler = getBean( CPVPLoadingViewHandler );
        if ( pLoadingView )
            pLoadingView.remove();
    }

    public function showMultiplePVPLoadingView( data : CObjectData, isNeedPreload:Boolean = false ) : void {
        var pPvpLoadingView : CMultiplePVPLoadingViewHandler = getBean( CMultiplePVPLoadingViewHandler ) as CMultiplePVPLoadingViewHandler;
        pPvpLoadingView.data = data as CPVPLoadingData;
        pPvpLoadingView.show(isNeedPreload);
        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
            pLoadingView.forceHide = true;
        }
    }

    public function removeMultiplePVPLoadingView() : void {
        var pPvpLoadingView : CMultiplePVPLoadingViewHandler = getBean( CMultiplePVPLoadingViewHandler );
        if ( pPvpLoadingView )
            pPvpLoadingView.remove();
        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
            pLoadingView.forceHide = false;
        }
    }

    public function showDoublePVPLoadingView( data : CObjectData, isNeedPreload:Boolean = false ):void
    {
        var pPvpLoadingView : CDoublePVPLoadingViewHandler = getBean( CDoublePVPLoadingViewHandler ) as CDoublePVPLoadingViewHandler;
        pPvpLoadingView.data = data as CPVPLoadingData;
        pPvpLoadingView.show(isNeedPreload);
        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
            pLoadingView.forceHide = true;
        }
    }

    public function removeDoublePVPLoadingView() : void {
        var pPvpLoadingView : CDoublePVPLoadingViewHandler = getBean( CDoublePVPLoadingViewHandler );
        if ( pPvpLoadingView )
            pPvpLoadingView.remove();
        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
            pLoadingView.forceHide = false;
        }
    }

    public function removeAllLoadingView() : void {
        removeSceneLoading();
        removePVPLoadingView();
        removeMultiplePVPLoadingView();
        removeDoublePVPLoadingView();
    }

    public function showScenarioStartView( callBackFun : Function = null ) : void {
        var viewHandler : CScenarioLoadingViewHandler = getBean( CScenarioLoadingViewHandler ) as CScenarioLoadingViewHandler;
        viewHandler.playStartAnimation( callBackFun );
    }

    public function showScenarioEndView( callBackFun : Function = null ) : void {
        var viewHandler : CScenarioLoadingViewHandler = getBean( CScenarioLoadingViewHandler ) as CScenarioLoadingViewHandler;
        viewHandler.playEndAnimation( callBackFun );
    }


    public function removeScenarioLoadingView() : void {
        var pLoadingView : CScenarioLoadingViewHandler = getBean( CScenarioLoadingViewHandler );
        if ( pLoadingView )
            pLoadingView.remove();
    }

    public function removeMaskView() : void {
        var vh : CMaskViewHandler = getBean( CMaskViewHandler );
        if ( vh )
            vh.hide( true );
    }

    public function showMsgBox( msg : String, okFun : Function = null, closeFun : Function = null, cancelIsVisible : Boolean = true, okLable:String = null, cancelLable:String = null, closeBtnIsVisible:Boolean = true, showType : String = "") : void {
        ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showMsgBox( msg, okFun, closeFun, cancelIsVisible, okLable, cancelLable, closeBtnIsVisible, showType);
    }
    public function closeAllMsgBox(  ) : void {
        ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).closeAllMsgBox();
    }

    public function showMsgAlert( msg : String, type : int = CMsgAlertHandler.WARNING, playSound : Boolean = true ) : void {
        ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showMsgAlert( msg, type, playSound );
    }

    public function showPropMsgAlert( attrName : String, value:int, type : int = CMsgAlertHandler.WARNING, playSound : Boolean = true ) : void {
        ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showPropMsgAlert(attrName, value, type, playSound );
    }

    // show showGamePromptMsgAlert(1027, {v1:11, v2:33});
    //  replaceObject : 类似CLang的replaceObject
    public function showGamePromptMsgAlert( gamePromptID:int, replaceObject:Object = null, type : int = CMsgAlertHandler.WARNING, playSound : Boolean = true ) : void {
        var record:GamePrompt = gamePromptTable.findByPrimaryKey(gamePromptID);
        if (record) {
            var content:String = record.content;
            if (replaceObject) {
                for (var key:* in replaceObject) {
                    content = content.replace(key, replaceObject[key]);
                }
            }

            ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showMsgAlert( content, type, playSound );
        } else {
            ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showMsgAlert( gamePromptID.toString(), type, playSound );
        }
    }

    public function showMsgProperChange( addTxt : String ) : void {
        ( stage.getSystem( CReciprocalSystem ) as CReciprocalSystem ).showMsgProperChange( addTxt );
    }

    private var m_pSceneLoadingCompletedFuncCallbacks : Dictionary;

    public function showSceneLoading( pfnCompleted : Function = null, ... args ) : void {
        // this.showMaskView( null, int.MAX_VALUE >> 16 ); // passing a large enough duration to prevent auto removed.

        // show the loading view.
        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
//            this.removeEventListener(CSceneLoadingEvent.EVENT_LOADING_PROCESS, _onLoadingProcess);
//            this.addEventListener(CSceneLoadingEvent.EVENT_LOADING_PROCESS, _onLoadingProcess);
            pLoadingView.show();
        }

        if ( pfnCompleted && ( !m_pSceneLoadingCompletedFuncCallbacks || !(pfnCompleted in m_pSceneLoadingCompletedFuncCallbacks )) ) {
            if ( !m_pSceneLoadingCompletedFuncCallbacks )
                m_pSceneLoadingCompletedFuncCallbacks = new Dictionary();

            m_pSceneLoadingCompletedFuncCallbacks[ pfnCompleted ] = args;
        }
    }

    public function removeSceneLoading() : void {
        // this.removeMaskView();

        var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
        if ( pLoadingView ) {
//            this.removeEventListener(CSceneLoadingEvent.EVENT_LOADING_PROCESS, _onLoadingProcess);
            pLoadingView.remove();
        }

        // notify the callbacks.
        if ( m_pSceneLoadingCompletedFuncCallbacks ) {
            for ( var pfnCallback : Function in m_pSceneLoadingCompletedFuncCallbacks ) {
                if ( null == pfnCallback )
                    continue;
                var args : Array = m_pSceneLoadingCompletedFuncCallbacks[ pfnCallback ] || [];
                delete m_pSceneLoadingCompletedFuncCallbacks[ pfnCallback ];

                pfnCallback.apply( null, args );
            }
        }
    }

    public function hideRootNDialogLayer() : void {
        m_pDialogLayer.visible = false;
        m_uiRoot.visible = false;
    }
    public function showRootNDialogLayer() : void {
        m_pDialogLayer.visible = true;
        m_uiRoot.visible = true;
    }

//    private function _onLoadingProcess(e:CSceneLoadingEvent) : void {
//        if (e.type == CSceneLoadingEvent.EVENT_LOADING_PROCESS) {
//            var process:Number = e.data as Number;
//            var pLoadingView : CSceneLoadingViewHandler = getBean( CSceneLoadingViewHandler );
//            if ( pLoadingView ) {
//                pLoadingView.targetRate = process;
//            }
//        }
//    }

    public function addDialog( dialog : DisplayObject, closeOther : Boolean = false, tweenData:CShowDialogTweenData = null ) : void {
        var pDialog : Dialog = dialog as Dialog;

        CAssertUtils.assertNotNull( pDialog, "CUISystem::addDialog should passing a Base Dialog by MornUI" );

        if ( dialog ) {
            m_pDialogLayer.show( pDialog, closeOther );
        }
    }

    public function addPopupDialog( dialog : DisplayObject, closeOther : Boolean = false ) : void {
        var pDialog : Dialog = dialog as Dialog;

        CAssertUtils.assertNotNull( pDialog, "CUISystem::addDialog should passing a Base Dialog by MornUI" );

        if ( dialog ) {
            m_pDialogLayer.popup( pDialog, closeOther );
        }
    }

    public function addPrompt( dialog : DisplayObject, closeOther : Boolean = false ) : void {
        var pDialog : Dialog = dialog as Dialog;

        CAssertUtils.assertNotNull( pDialog, "CUISystem::addPrompt should passing a Base Dialog by MornUI" );

        if ( dialog ) {
            m_pPromptLayer.popup( pDialog, closeOther );
        }
    }

    public function addAppPrompt( dialog : DisplayObject, closeOther : Boolean = false ) : void {
        var pDialog : Dialog = dialog as Dialog;

        CAssertUtils.assertNotNull( pDialog, "CUISystem::addAppPrompt should passing a Base Dialog by MornUI" );

        if ( dialog ) {
            m_pAppPromptLayer.popup( pDialog, closeOther );
        }
    }

    // MornUI custom properties parsing processors.
    //--------------------------------------------------------------------------

    private function _parseCustomComponentProperties( comp : Component ) : void {
        if ( null == comp || !comp.tag )
            return;

        var v_pUIAudioHandler : CUIComponentAudioHandler = getBean( CUIComponentAudioHandler ) as CUIComponentAudioHandler;
        if ( v_pUIAudioHandler ) {
            v_pUIAudioHandler.visitUIComponent( comp );
        }
    }


    public function get dialogLayer() : DialogLayer {
        return m_pDialogLayer;
    }

    private function get gamePromptTable() : IDataTable {
        if (!_gamePromptTable) {
            _gamePromptTable = (stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        }
        return _gamePromptTable;
    }

    private function _onLevelHandler( evt : CInstanceEvent ):void{
        closeAllMsgBox();
    }

    private function get _instanceSystem():CInstanceSystem{
        return stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }

}
}
