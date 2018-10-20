//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Foundation.CMap;

import flash.geom.Point;

import kof.ui.IUICanvas;

/**
 * View handler, providing a lazy updated for data and display.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CViewHandler extends CAbstractHandler {

    public static const STAGE_LEFT_TOP : Point = new Point();

    private var _viewId : int = 0;

    private var _uiCanvas : IUICanvas;
    private var _dataDirty : Boolean;
    private var _displayUpdateNeeded : Boolean;
    private var _callbacks : CMap;

    kof_framework var _pfnLaterCall : Function;
    kof_framework var _pfnUITickRegister : Function;
    kof_framework var _pfnUITickUnregister : Function;

    private var _loadViewByDefault : Boolean;

    /**
     * Constructor.
     */
    public function CViewHandler( bLoadViewByDefault : Boolean = false ) {
        super();
        _callbacks = new CMap(); // pfn => [ timer, args ... ]
        this._loadViewByDefault = bLoadViewByDefault;
    }

    override public function dispose() : void {
        super.dispose();

        if ( _callbacks )
            _callbacks.clear();
        _callbacks = null;

        kof_framework::_pfnLaterCall = null;
        kof_framework::_pfnUITickRegister = null;
        kof_framework::_pfnUITickUnregister = null;
        _uiCanvas = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }
        return ret;
    }

    public function get loadViewByDefault() : Boolean {
        return this._loadViewByDefault;
    }

    public function set loadViewByDefault( value : Boolean ) : void {
        this._loadViewByDefault = value;
    }

    public function get viewClass() : Array {
        return null;
    }

    protected function onInitialize() : Boolean {
        return true;
    }

    public function get isAssetsCached() : Boolean {
        return true;
    }

    protected function get additionalAssets() : Array {
        return null;
    }

    protected virtual function onAssetsLoadCompleted() : void {
        makeStarted();
    }

    protected virtual function onAssetsLoadProgress( rate : Number ) : void {

    }

    protected virtual function onAssetsLoadError() : void {
        stop();
    }

    /**
     * Load assets for the specify view by the class of view.
     *
     * @param viewClass The class of a view.
     * @param pfnCompleted The callback function triggered when assets all load completed.
     * @param pfnProgress The callback function triggered when assets progress loading.
     * @param pfnError The callback function triggered when occurs any errors during the loading.
     * @return True if no loading required, false otherwise. If true is return, none of callbacks should be called.
     */
    public function loadAssetsByView( viewClasses : Array, pfnCompleted : Function = null,
                                      pfnProgress : Function = null, pfnError : Function = null ) : Boolean {
        if ( ( viewClasses && viewClasses.length ) || ( additionalAssets && additionalAssets.length ) ) {
            function _onAssetsLoadCompleted( ... args ) : void {
                void( args );
                pfnCompleted = pfnCompleted || onAssetsLoadCompleted;
                pfnCompleted();
            }

            function _onAssetsLoadProgress( rate : Number ) : void {
                try {
                    pfnProgress = pfnProgress || onAssetsLoadProgress;
                    pfnProgress( rate );
                } catch ( e : Error ) {
                    // ignore.
                }
            }

            function _onAssetsLoadError( url : String ) : void {
                LOG.logErrorMsg( "Assets load failed: " + url );
                pfnError = pfnError || onAssetsLoadError;
                pfnError();
            }

            var ret : Boolean = _uiCanvas.loadAssetsByViewClass( viewClasses, additionalAssets,
                    _onAssetsLoadCompleted, _onAssetsLoadProgress,
                    _onAssetsLoadError, isAssetsCached );

            if ( ret ) {
                _onAssetsLoadCompleted();
            }

            return ret;
        } else {
            return true;
        }
    }

    protected function onInitializeView() : Boolean {
        return true;
    }

    public function get isDataDirty() : Boolean {
        return _dataDirty;
    }

    public function get isDisplayUpdateNeeded() : Boolean {
        return _displayUpdateNeeded;
    }

    public function get uiCanvas() : IUICanvas {
        return _uiCanvas;
    }

    kof_framework function set uiCanvas( value : IUICanvas ) : void {
        _uiCanvas = value;
    }

    /**
     * Invalidate all.
     */
    public function invalidate() : void {
        this.invalidateData();
        this.invalidateDisplay();
    }

    /**
     * Invalidate data only.
     */
    public function invalidateData() : void {
        _dataDirty = true;

        callLater( updateData );
    }

    /**
     * Invalidate display only.
     */
    public function invalidateDisplay() : void {
        _displayUpdateNeeded = true;

        callLater( updateDisplay );
    }

    protected virtual function updateData() : void {
        _dataDirty = false; // reset dirty flag.
    }

    protected virtual function updateDisplay() : void {
        _displayUpdateNeeded = false; // reset dirty flag.
    }

    protected function callLater( fn : Function, ... args ) : void {
        if ( null != kof_framework::_pfnLaterCall ) {
            kof_framework::_pfnLaterCall( fn, args );
        }
    }

    private function _newScheduleInfo( iType : int, fTime : Number, args : Array ) : CViewScheduleTickInfo {
        var ret : CViewScheduleTickInfo = new CViewScheduleTickInfo( iType, fTime );
        ret.args = args;
        return ret;
    }

    protected function schedule( fInterval : Number, pfnCallback : Function, ... args ) : void {
        if ( isNaN( fInterval ) )
            return;

        if ( pfnCallback in _callbacks )
            return;

        var info : CViewScheduleTickInfo = this._newScheduleInfo( CViewScheduleTickInfo.TYPE_SCHEDULE, fInterval, args );
        _callbacks.add( pfnCallback, info );

        this._resumeScheduleTick();
    }

    protected function unschedule( pfnCallback : Function ) : void {
        if ( null == pfnCallback )
            return;

        if(_callbacks){
            _callbacks.remove( pfnCallback );
        }
        this._pauseScheduleTickIfNoop();
    }

    protected function delayCall( fDelay : Number, pfnCallback : Function, ... args ) : void {
        if ( isNaN( fDelay ) )
            return;

        if ( pfnCallback in _callbacks )
            return;

        var info : CViewScheduleTickInfo = this._newScheduleInfo( CViewScheduleTickInfo.TYPE_DELAY, fDelay, args );
        _callbacks.add( pfnCallback, info );

        this._resumeScheduleTick();
    }

    private function _scheduleTick( fDelta : Number ) : void {
        if ( _callbacks && _callbacks.length ) {
            var removed : Array = null;
            for ( var pfn : Function in _callbacks ) {
                if ( null != pfn ) {
                    var info : CViewScheduleTickInfo = _callbacks[ pfn ] as CViewScheduleTickInfo;
                    if ( !info )
                        continue;
                    if ( info.timer.isOnTime() ) {
                        var delta : Number = info.timer.seconds();
                        info.timer.reset();
                        if ( info.type == CViewScheduleTickInfo.TYPE_DELAY ) {
                            pfn.apply( null, info.args );
                            // remove by running once.
                            if ( !removed )
                                removed = [];
                            removed.push( pfn );
                        } else {
                            pfn.apply( null, [ delta ].concat( info.args ) );
                        }
                    }
                }
            }

            if ( removed && removed.length ) {
                for each ( pfn in removed ) {
                    _callbacks.remove( pfn );
                }
            }
        }
    }

    private function _resumeScheduleTick() : void {
        if ( _callbacks && _callbacks.length ) {
            // resume.
            this.kof_framework::_pfnUITickRegister( _scheduleTick );
        }
    }

    private function _pauseScheduleTickIfNoop() : void {
        if ( _callbacks && !_callbacks.length ) {
            // pause
            this.kof_framework::_pfnUITickUnregister( _scheduleTick );
        }
    }

    public function get viewId() : int {
        return _viewId;
    }

    public function set viewId( value : int ) : void {
        _viewId = value;
    }
}
}

import QFLib.Foundation.CTimer;

class CViewScheduleTickInfo {

    static public const TYPE_SCHEDULE : int = 1;
    static public const TYPE_DELAY : int = 2;

    public var timer : CTimer;
    public var args : Array;
    public var type : int;

    public function CViewScheduleTickInfo( iType : int, fTime : Number ) {
        this.type = iType;
        this.timer = new CTimer( fTime );
    }

}
