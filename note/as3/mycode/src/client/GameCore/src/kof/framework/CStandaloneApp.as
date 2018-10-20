//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Application.CApp;
import QFLib.Application.Component.CContainerLifeCycle;
import QFLib.Foundation;
import QFLib.Foundation.CLog;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import com.adobe.flascc.vfs.IVFS;

import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import kof.framework.vfs.CActionScript3VFS;

import mx.events.Request;
import mx.utils.StringUtil;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CStandaloneApp extends CApp implements IApplication, IConfiguration, IDisposable {

    public static const RESTART : String = "__RESTART";

    public function CStandaloneApp( stage : Stage ) {
        super();
        this._stage = stage;
        if ( !this._stage )
            throw "Null stage pushed.";

        _eventDispatcher = new EventDispatcher();

        Foundation.Log = new CLog( null, true );
        Foundation.Log.logTraceMsg( "Constructs the CStandaloneApp instance." );

        this.eventDispatcher.addEventListener( "ENV_SETUP", _onEnvSetupRequest, false, 0, true );
    }

    private var _stage : Stage;
    private var _appStages : Vector.<CAppStage>;
    //noinspection JSFieldCanBeLocal
    private var _sendCleanupToStage : Boolean;
    private var _nextStage : CAppStage;
    private var _runningStage : CAppStage;
    private var _timer : IAppTimer;
    private var _pause : Boolean;
    private var _eventDispatcher : EventDispatcher;
    private var _vfs : IVFS;
    private var _deltaFactor : Number = 1.0;
    public var _baseDeltaFactor : Number = 1.0;

    override protected function _initialize() : Boolean {
        Foundation.Log.logTraceMsg( "CStandaloneApp _Initialize." );

        if ( !_appStages )
            _appStages = new <CAppStage>[];

        _timer = new ASTimer();
        _configMap = new CMap();
        _vfs = new CActionScript3VFS();

        _sendCleanupToStage = false;
        _nextStage = null;
        _runningStage = null;

        return true;
    }

    public function dispose() : void {
        // FIXME: dispose the Application.
    }

    override protected function _appName() : String {
        return "KOFAdvanced";
    }

    override protected function _unInitialize() : void {
        Foundation.Log.logTraceMsg( "CStandaloneApp _Uninitialize." );
    }

    // @private
    private function _onEnvSetupRequest( event : Request ) : void {
        this.eventDispatcher.removeEventListener( "ENV_SETUP", _onEnvSetupRequest );
        if ( event.value ) {
            for ( var k : String in event.value ) {
                setConfig( k, event.value[ k ] );
            }
        }
    }

    final public function get deltaFactor() : Number {
        return _deltaFactor;
    }

    final public function set deltaFactor( value : Number ) : void {
        _deltaFactor = value;
    }

    //noinspection JSUnusedGlobalSymbols
    final public function get timer() : IAppTimer {
        return _timer;
    }

    //noinspection JSUnusedGlobalSymbols
    final public function get pause() : Boolean {
        return _pause;
    }

    //noinspection JSUnusedGlobalSymbols
    final public function set pause( value : Boolean ) : void {
        _pause = value;
    }

    final public function get eventDispatcher() : IEventDispatcher {
        return _eventDispatcher;
    }

    protected function runTick() : void {
        if ( !_stage )
            throw "_stage is null.";

        _stage.addEventListener( Event.ENTER_FRAME, _tick, false, 0, true );
    }

    private function _tick( event : Event ) : void {
        _timer.update();

        if ( _pause )
            return;

        if ( _nextStage ) {
            _setNextStage();
        }

        if ( _runningStage ) {
            _runningStage.tickUpdate( _timer.timePerFrame * deltaFactor * _baseDeltaFactor );
        }

        // TODO(Jeremy): Constants "afterFrameUpdated".
        _eventDispatcher.dispatchEvent( new Event( "afterFrameUpdated" ) );
    }

    private function _setNextStage() : void {
        if ( _runningStage ) {
            _runningStage.stop();
            // clean up _runningStage.
            _runningStage.dispose();
        }

        _runningStage = _nextStage;
        _nextStage = null;

        if ( _runningStage ) {
            if ( !_runningStage.isInitialized ) {
                this.buildRunningStage( _runningStage );
            }
            _runningStage.start(); // start the running stage.
        }
    }

    protected function buildRunningStage( runningStage : CAppStage ) : void {
        // FIXME(Jeremy): Configures the stage with external configuration.
        runningStage.initWithStage( _stage, {
            align : StageAlign.TOP_LEFT,
            scaleMode : StageScaleMode.NO_SCALE
        } );

        runningStage.kof_framework::addBean( this as IConfiguration, CContainerLifeCycle.UNMANAGED ); // Just as IConfiguration.
        runningStage.kof_framework::addBean( _vfs, CContainerLifeCycle.UNMANAGED ); // VFS supported.
        // _runningStage.eventDispatcher = this._eventDispatcher;
    }

    public function get runningStage() : CAppStage {
        return _runningStage;
    }

    public function runWithStage( stage : CAppStage ) : void {
        if ( !stage )
            throw "Null Pointer stage submitted.";

        if ( _runningStage )
            throw "_runningStage should be nullptr.";

        pushStage( stage );
        runTick();
    }

    public function pushStage( appStage : CAppStage ) : void {
        _sendCleanupToStage = false;
        _appStages.push( appStage );
        _nextStage = appStage;
    }

    //noinspection JSUnusedGlobalSymbols
    public function popStage() : void {
        _appStages.pop();
        if ( _appStages.length == 0 ) {
            // TODO: end all.
        }
        else {
            _sendCleanupToStage = true;
            _nextStage = _appStages[ _appStages.length - 1 ];
        }
    }

    //noinspection JSUnusedGlobalSymbols
    public function popToRootStage() : void {
        this.popToStageStackLevel( 1 );
    }

    public function popToStageStackLevel( level : int ) : void {
        if ( level == 0 ) {
            // TODO: end all.
            return;
        }

        var c : int = _appStages.length;

        // current level or lower -> nothing.
        if ( level >= c ) {
            return;
        }

        var back : CAppStage = _appStages[ c - 1 ];
        if ( back == _runningStage ) {
            _appStages.pop();
            --c;
        }

        // pop stack until reaching desired level.
        while ( c > level ) {
            var current : CAppStage = _appStages[ c - 1 ];
            if ( current.isRunning ) {
                // EXIT current stage.
                current.stop();
            }

            // UNLOAD.
            current.dispose();
            _appStages.pop();
            --c;
        }

        _nextStage = _appStages[ _appStages.length - 1 ];

        // cleanup running stage.
        _sendCleanupToStage = true;
    }

    //noinspection JSUnusedGlobalSymbols
    public function replaceStage( stage : CAppStage ) : void {
        if ( !stage )
            throw "The stage should not be null.";

        if ( !_runningStage ) {
            runWithStage( stage );
            return;
        }

        if ( _nextStage == stage )
            return;

        if ( _nextStage ) {
            if ( _nextStage.isRunning ) {
                _nextStage.stop();
            }
            _nextStage.dispose();
            _nextStage = null;
        }

        var size : int = _appStages.length;

        _sendCleanupToStage = true;
        _appStages[ size - 1 ] = stage;
        _nextStage = stage;
    }

    //------------------------------------------------------------------------------
    // IConfiguration implementations.
    //------------------------------------------------------------------------------

    /** @private */
    private var _configMap : CMap;

    public function getRaw( key : String, defaultVal : * = undefined ) : * {
        var config : CMap = _configMap;
        return config[ key ];
    }

    public function getInt( key : String, defaultVal : int = 0 ) : int {
        var config : CMap = _configMap;
        return (key in config) ? int( config[ key ] ) : defaultVal;
    }

    public function getString( key : String, defaultVal : String = null ) : String {
        var config : CMap = _configMap;
        return (key in config) ? String( config[ key ] ) : defaultVal;
    }

    public function getBoolean( key : String, defaultValue : Boolean = false ) : Boolean {
        var config : CMap = _configMap;
        var val : * = config[ key ];
        var ret : Boolean = defaultValue;
        if ( val is String ) {
            ret = !!(val == "true" || val == "TRUE");
        } else if ( val is int ) {
            ret = !(val == 0);
        } else {
            if ( val == undefined )
                return ret;
            ret = Boolean( val );
        }

        return ret;
    }

    public function getNumber( key : String, defaultValue : Number = NaN ) : Number {
        var config : CMap = _configMap;
        return (key in config) ? Number( config[ key ] ) : defaultValue;
    }

    public function getXML( key : String, defaultValue : XML = null ) : XML {
        var config : CMap = _configMap;
        return (key in config) ? XML( config[ key ] ) : defaultValue;
    }

    public function getJSONObject( key : String, defaultValue : Object = null ) : Object {
        var strJSON : String = getString( key );
        var ret : Object = defaultValue;
        if ( strJSON && StringUtil.trim( strJSON ) != "" )
            ret = JSON.parse( strJSON );
        return ret;
    }

    public function setConfig( key : String, value : * ) : * {
        var oldValue : * = null;
        if ( _configMap ) {
            oldValue = _configMap[ key ];
            _configMap[ key ] = value;
        }

        notifyItemUpdateListeners( key );
        notifyUpdateListeners();

        return oldValue;
    }

    public function get configuration() : IConfiguration {
        return this;
    }

    private var _updateListeners : Vector.<Function>;
    private var _itemUpdateListeners : CMap;

    public function addUpdateListener( func : Function ) : void {
        if ( !_updateListeners )
            _updateListeners = new <Function>[];

        var i : int = _updateListeners.indexOf( func );
        if ( i >= 0 )
            return;
        _updateListeners.push( func );
    }

    public function removeUpdateListener( func : Function ) : Boolean {
        if ( !_updateListeners || !_updateListeners.length )
            return false;
        var i : int = _updateListeners.indexOf( func );
        if ( i <= 0 )
            return false;
        _updateListeners.splice( i, 1 );
        return true;
    }

    private function _notifyUpdateListeners( listeners : Vector.<Function> ) : void {
        if ( !listeners || !listeners.length )
            return;
        for each ( var l : Function in listeners ) {
            this.notifyUpdateListener( l );
        }
    }

    [Inline]
    protected function notifyUpdateListeners() : void {
        if ( !_updateListeners )
            return;
        this._notifyUpdateListeners( _updateListeners );
    }

    protected function notifyUpdateListener( func : Function ) : void {
        if ( null == func )
            return;
        func();
    }

    public function addItemUpdateListener( key : String, func : Function ) : void {
        if ( !_itemUpdateListeners )
            _itemUpdateListeners = new CMap();

        var itemQueue : Vector.<Function> = _itemUpdateListeners.find( key );
        if ( !itemQueue ) {
            itemQueue = new Vector.<Function>();
            _itemUpdateListeners.add( key, itemQueue );
        }

        var i : int = itemQueue.indexOf( func );
        if ( i >= 0 )
            return;
        itemQueue.push( func );
    }

    public function removeItemUpdateListener( key : String, func : Function = null ) : Boolean {
        if ( !_itemUpdateListeners || !_itemUpdateListeners.length )
            return false;
        var itemQueue : Vector.<Function> = _itemUpdateListeners.find( key );
        if ( !itemQueue )
            return false;

        if ( null != func ) {
            var i : int = itemQueue.indexOf( func );
            if ( i <= 0 )
                return false;

            itemQueue.splice( i, 1 );
            return true;
        }

        _itemUpdateListeners.remove( key );
        return true;
    }

    protected function notifyItemUpdateListeners( key : String ) : void {
        if ( !_itemUpdateListeners || !_itemUpdateListeners.length || !key )
            return;

        var listeners : Vector.<Function> = _itemUpdateListeners.find( key );
        this._notifyUpdateListeners( listeners );
    }

}
}

import flash.utils.getTimer;

import kof.framework.IAppTimer;

/**
 * A ActionScript3 GetTimer implementation of IAppTimer.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class ASTimer implements IAppTimer {

    function ASTimer() {
        reset();
    }

    private var _startTime : Number;
    private var _previousTime : Number;
    private var _tpf : Number;
    private var _fps : Number;
    private var _fc : uint;

    public function get time() : Number {
        var t : Number = getTimer();
        t -= _startTime;
        return t;
    }

    public function get frameRate() : Number {
        return _fps;
    }

    public function get frameCounter() : uint {
        return _fc;
    }

    public function get timePerFrame() : Number {
        return _tpf;
    }

    public function get resolution() : Number {
        return 1000;
    }

    public function update() : void {
        var t : Number = this.time;
        this._tpf = (t - _previousTime) / resolution;
        this._fps = 1.0 / this._tpf;
        _previousTime = t;
        _fc++;
    }

    public function reset() : void {
        _startTime = getTimer();
        _previousTime = this.time;
        _tpf = 0;
        _fps = 0;
    }

    public function get timeInSeconds() : Number {
        return time / resolution;
    }

}

