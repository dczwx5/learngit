//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{

import QFLib.Foundation.CLog;
import QFLib.Foundation.CMap;
import QFLib.Memory.CSmartObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.getQualifiedClassName;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractLifeCycle extends CSmartObject implements ILifeCycle, IEventDispatcher
{

    public static const STARTING : String = "STARTING";
    public static const STOPPING : String = "STOPPING";
    public static const STOPPED : String = "STOPPED";
    public static const STARTED : String = "STARTED";
    public static const FAILED : String = "FAILED";

    protected static const LOG : CLog = new CLog( null, true );

    private static const __FAILED : int = -1;
    private static const __STOPPED : int = 0;
    private static const __STARTING : int = 1;
    private static const __STARTED : int = 2;
    private static const __STOPPING : int = 3;

    private static var _phases : CMap;

    initPhases();

    private static function initPhases() : void
    {
        _phases = new CMap();

        _phases.add( __STOPPED, __STARTING );
        _phases.add( __STARTING, __STARTED );
        _phases.add( __STARTED, __STOPPING );
        _phases.add( __STOPPING, __STOPPED );
    }

    // Result Flags:
    public static const NO_TRANSITION : int = 998;
    public static const PENDING : int = 999;
    public static const SUCCEEDED : int = 1000;
    public static const CANCELLED : int = 1001;

    // Error Flags:
    public static const INVALID_TRANSITION : int = 100;
    public static const PENDING_TRANSITION : int = 101;
    public static const INVALID_CALLBACK : int = 101;

    // state holding
    private var _state : int = __STOPPED;
    private var _transition : Function;

    private var _eventDelegate : IEventDispatcher;
    private var _className : String;

    // Constructor
    public function CAbstractLifeCycle()
    {
        this._eventDelegate = new EventDispatcher( this );
    }

    [Inline]
    final public function get className() : String
    {
        if ( !_className )
            _className = getQualifiedClassName( this );
        return _className;
    }

    [Inline]
    final public function get isFailed() : Boolean
    {
        return __FAILED == _state;
    }

    [Inline]
    final public function get isStarted() : Boolean
    {
        return __STARTED == _state;
    }

    [Inline]
    final public function get isStopped() : Boolean
    {
        return __STOPPED == _state;
    }

    [Inline]
    final public function get isStopping() : Boolean
    {
        return __STOPPING == _state;
    }

    [Inline]
    final public function get isStarting() : Boolean
    {
        return __STARTING == _state;
    }

    [Inline]
    final public function get isRunning() : Boolean
    {
        return __STARTED == _state || __STARTING == _state;
    }

    [Inline]
    final public function get stateValue() : int
    {
        return _state;
    }

    public static function getState( lc : ILifeCycle ) : String
    {
        if ( lc )
        {
            if ( lc.isStarting ) return STARTING;
            if ( lc.isStarted ) return STARTED;
            if ( lc.isStopping ) return STOPPING;
            if ( lc.isStopped ) return STOPPED;
        }
        return FAILED;
    }

    [Inline]
    final public function getState() : String
    {
        return CAbstractLifeCycle.getState( this );
    }

    public function start() : void
    {
        if ( __STARTED == _state || __STARTING == _state )
            return;

        try
        {
            this._state = __STOPPED;
            _next();

            // this.setStarting();
            // this.doStart();
            // this.setStarted();
        }
        catch ( e : Error )
        {
            this.setFailed( e );
            throw  e;
        }
    }

    public function stop() : void
    {
        if ( __STOPPING == _state || __STOPPED == _state )
            return;

        try
        {
            this._state = __STARTED;
            _next();

            // this.setStopping();
            // this.doStop();
            // this.setStopped();
        }
        catch ( e : Error )
        {
            this.setFailed( e );
            throw e;
        }
    }

    public function addLifeCycleListener( func : Function ) : void
    {
        if ( null == func )
            return;

        _eventDelegate.addEventListener( CLifeCycleEvent.FAILED, func, false, 0, true );
        _eventDelegate.addEventListener( CLifeCycleEvent.STARTED, func, false, 0, true );
        _eventDelegate.addEventListener( CLifeCycleEvent.STARTING, func, false, 0, true );
        _eventDelegate.addEventListener( CLifeCycleEvent.STOPPED, func, false, 0, true );
        _eventDelegate.addEventListener( CLifeCycleEvent.STOPPING, func, false, 0, true );
    }

    public function removeLifeCycleListener( func : Function ) : void
    {
        if ( null == func )
            return;

        _eventDelegate.removeEventListener( CLifeCycleEvent.FAILED, func, false );
        _eventDelegate.removeEventListener( CLifeCycleEvent.STARTED, func, false );
        _eventDelegate.removeEventListener( CLifeCycleEvent.STARTING, func, false );
        _eventDelegate.removeEventListener( CLifeCycleEvent.STOPPED, func, false );
        _eventDelegate.removeEventListener( CLifeCycleEvent.STOPPING, func, false );
    }

    protected virtual function doStart() : Boolean
    {
        return true;
    }

    protected virtual function doStop() : Boolean
    {
        return true;
    }

    protected function setFailed( e : Error ) : void
    {
        _state = __FAILED;
        LOG.logErrorMsg( FAILED + " " + this.toString() + ": " + e.message );
        dispatchEvent( new CLifeCycleEvent( CLifeCycleEvent.FAILED ) );
    }

    protected function setStopped() : void
    {
        _state = __STOPPED;
        LOG.logTraceMsg( STOPPED + " " + this.toString() );
        dispatchEvent( new CLifeCycleEvent( CLifeCycleEvent.STOPPED ) );
    }

    protected function setStopping() : void
    {
        _state = __STOPPING;
        LOG.logTraceMsg( STOPPING + " " + this.toString() );
        dispatchEvent( new CLifeCycleEvent( CLifeCycleEvent.STOPPING ) );
    }

    protected function setStarted() : void
    {
        _state = __STARTED;
        LOG.logTraceMsg( STARTED + " " + this.toString() );
        dispatchEvent( new CLifeCycleEvent( CLifeCycleEvent.STARTED ) );
    }

    protected function setStarting() : void
    {
        _state = __STARTING;
        LOG.logTraceMsg( STARTING + " " + this.toString() );

        var event : CLifeCycleEvent = new CLifeCycleEvent( CLifeCycleEvent.STARTING );
        dispatchEvent( event );
        if ( event.isDefaultPrevented() )
            event.stopPropagation();
    }

    protected function afterStarting() : void {
        var event : CLifeCycleEvent = new CLifeCycleEvent( CLifeCycleEvent.AFTER_STARTING );
        dispatchEvent( event );
        if ( event.isDefaultPrevented() )
            event.stopPropagation();
    }

    private function _next( ) : int
    {
        var from : int = this._state;
        var to : int = (from in _phases) ? _phases[from] : from;

        if ( null != _transition )
        {
            // TODO(Jeremy): Incorrect next phase, on transitioning.
            return PENDING_TRANSITION;
        }

        if ( !beforePhase( from, to ) )
        {
            return CANCELLED;
        }

        if ( from == to )
        {
            afterPhase( from, to );
            return NO_TRANSITION;
        }

        this._transition = _transitionCallback;

        var leave : * = leavePhase( from, to );
        if ( !leave )
        {
            this.addEventListener(CLifeCycleEvent.TRANSITION_COMPLETED, _onTransition, false, 0, true);
            return PENDING;
        }
        else
        {
            if ( this._transition )
            {
                return this._transition(from, to);
            }

            return SUCCEEDED;
        }

    }
    
    private function _onTransition( event : CLifeCycleEvent ) : void {
        var from : int = this._state;
        var to : int = (from in _phases) ? _phases[from] : from;
        this._transitionCallback( from, to );
    }

    // prepare a transition method for use EITHER lower down.
    private function _transitionCallback(from:int, to:int) : int
    {
        _transition = null;
        _state = to;

        enterPhase( from, to );
        changePhase( from, to );
        afterPhase( from, to );

        return SUCCEEDED;
    }

    protected virtual function beforePhase( from : int, to : int ) : Boolean
    {
        // NOOP.
        return true;
    }

    protected virtual function afterPhase( from : int, to : int ) : void
    {
        if ( from == __STOPPED && to == __STARTING )
            _next();
        else if ( from == __STARTED && to == __STOPPING )
            _next();
    }

    protected virtual function enterPhase( from : int, to : int ) : void
    {
        if ( from == __STOPPED && to == __STARTING )
            setStarting();
        else if ( from == __STARTED && to == __STOPPING )
            setStopping();
    }

    protected virtual function changePhase( from : int, to : int ) : void
    {
        if ( from == __STARTING && to == __STARTED )
            setStarted();
        else if ( from == __STOPPING && to == __STOPPED )
            setStopped();
    }

    protected virtual function leavePhase( from : int, to : int ) : Boolean
    {
        try
        {
            if ( from == __STARTING && to == __STARTED )
                return doStart();
            else if ( from == __STOPPING && to == __STOPPED )
                return doStop();
        }
        catch ( e : Error )
        {
            setFailed( e );
            throw e;
        }

        return true;
    }

    //------------------------------------------------------------------------------
    // Delegate functions (IEventDispatcher)
    //------------------------------------------------------------------------------

    [Inline]
    final public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
    {
        this._eventDelegate.addEventListener( type, listener, useCapture, priority, useWeakReference );
    }

    [Inline]
    final public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
    {
        this._eventDelegate.removeEventListener( type, listener, useCapture );
    }

    [Inline]
    final public function dispatchEvent( event : Event ) : Boolean
    {
        return this._eventDelegate.dispatchEvent( event );
    }

    [Inline]
    final public function hasEventListener( type : String ) : Boolean
    {
        return this._eventDelegate.hasEventListener( type );
    }

    [Inline]
    final public function willTrigger( type : String ) : Boolean
    {
        return this._eventDelegate.willTrigger( type );
    }

    public function toString() : String
    {
        return this.className + " [ state : (" + stateValue + "-" + CAbstractLifeCycle.getState( this ) + ") ]";
    }

} // class CAbstractLifeCycle
}
