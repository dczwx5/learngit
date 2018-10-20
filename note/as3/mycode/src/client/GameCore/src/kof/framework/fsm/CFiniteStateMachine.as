//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.fsm {

import QFLib.Interface.IDisposable;

import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

[Event(name="beforeEvent", type="kof.framework.fsm.CStateEvent")]
[Event(name="afterEvent", type="kof.framework.fsm.CStateEvent")]
[Event(name="enterState", type="kof.framework.fsm.CStateEvent")]
[Event(name="leaveState", type="kof.framework.fsm.CStateEvent")]
[Event(name="stageChange", type="kof.framework.fsm.CStateEvent")]
[Event(name="transitionComplete", type="kof.framework.fsm.CStateEvent")]
[Event(name="transitionCancelled", type="kof.framework.fsm.CStateEvent")]
/**
 * Finite-State-Machine (FSM)
 *
 * @author Jeremy
 */
public class CFiniteStateMachine extends EventDispatcher implements IDisposable {

    /** @private */
    public static const BUILTIN_STATES : Object = {
        NONE : 'none'
    };

    public static const Result : Object = {
        SUCCEEDED : 1,
        NO_TRANSITION : 2,
        CANCELLED : 3,
        PENDING : 4
    };

    public static const Error : Object = {
        INVALID_TRANSITION : 100,
        PENDING_TRANSITION : 200
    };

    public static const WILDCARD : String = "*";

    /**
     * Create a finite state-machine instance specified by the supplied <code>cfg</code>.
     *
     * @param cfg The configuration.
     * @return a finite state-machine.
     */
    public static function create( cfg : Object ) : CFiniteStateMachine {
        var fsm : CFiniteStateMachine = new CFiniteStateMachine( cfg );
        if ( fsm && fsm.init() )
            return fsm;
        return null;
    }

    /** Private constructor. */
    public function CFiniteStateMachine( cfg : Object ) {
        this.mCfg = cfg;
    }

    /** Configuration */
    private var mCfg : Object;
    /** The startup event object. */
    private var mInitial : Object;
    /** The terminal event object. */
    private var mTerminal : Object;
    /** Reference to Cfg.events as Array. */
    private var mEvents : Array;
    /** The tree of structure by state. */
    private var mEventMap : Object;
    /** The current CState. */
    private var mCurrent : String;
    /** The flag to mark transition behavior. */
    private var mTransition : Boolean;
    /** My Implementation. */

    private var mEventArgs : Array;

    private var mStates : Dictionary;

    final public function get current() : String {
        return mCurrent;
    }

    final public function get currentState() : CState {
        return getState( mCurrent );
    }

    final public function get config() : Object {
        return mCfg;
    }

    final public function get finished() : Boolean {
        return isState( mTerminal );
    }

    final public function isState( state : * ) : Boolean {
        return (state is Array) ? (state.indexOf( current ) >= 0) : (current == state);
    }

    final public function has( event : String ) : Boolean {
        return event in mEventMap;
    }

    final public function can( event : String ) : Boolean {
        return !mTransition && (mEventMap[ event ].hasOwnProperty( current ) || mEventMap[ event ].hasOwnProperty( CFiniteStateMachine.WILDCARD ));
    }

    final public function cannot( event : String ) : Boolean {
        return !can( event );
    }

    private function errorHandle( name : String, from : String, to : String, args : Array, errorCode : int, errorMessage : String ) : int {
        if ( mCfg.error is Function )
            return (mCfg.error as Function).call( null, name, from, to, args, errorCode, errorMessage );
        else
            throw errorMessage;
    }

    /**
     * Occurs a specified event now.
     *
     * @param event The name of event
     * @param args the addition argList.
     */
    public function on( event : String, ... args ) : int {
        var map : Object = mEventMap[ event ];
        const from : String = current;
        const to : String = map[ from ] || map[ WILDCARD ] || from;

        if ( mTransition ) {
            CONFIG::debug {
                return errorHandle( event, from, to, args, Error.PENDING_TRANSITION, " event " + event + " inappropriate because transition did not complete." );
            }
            CONFIG::release {
                return errorHandle( event, from, to, args, Error.PENDING_TRANSITION, null );
            }
        }

        if ( cannot( event ) ) {
            CONFIG::debug {
                return errorHandle( event, from, to, args, Error.INVALID_TRANSITION, " event " + event + " inappropriate in current state " + mCurrent );
            }
            CONFIG::release {
                return errorHandle( event, from, to, args, Error.INVALID_TRANSITION, null );
            }
        }

        mEventArgs = mEventArgs || [];
        if ( args.length >= mEventArgs.length )
            mEventArgs.length = args.length + 1;

        mEventArgs[0] = event;

        for ( var i : int = 1; i < mEventArgs.length; ++i ) {
            mEventArgs[ i ] = i <= args.length ? args[ i - 1 ] : null;
        }

        if ( !dispatchEvent( new CStateEvent( CStateEvent.BEFORE, from, to, mEventArgs ) ) )
            return Result.CANCELLED;

        if ( from == to ) {
            dispatchEvent( new CStateEvent( CStateEvent.AFTER, from, to, mEventArgs ) );
            return Result.NO_TRANSITION;
        }

        // Prepare a transition method for EITHER lower down, or by caller if they want an async transition (indicated by an ASYNC return value from leaveState).
        mTransition = true;
        addEventListener( CStateEvent.TRANSITION_COMPLETE, onTransition, false );
        addEventListener( CStateEvent.TRANSITION_CANCELLED, onTransition, false );

        var leave : Boolean = dispatchEvent( new CStateEvent( CStateEvent.LEAVE, from, to, mEventArgs.slice() ) );

        if ( !leave ) {
            return Result.PENDING;
        } else {
            dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_COMPLETE, from, to, mEventArgs ) );
            return Result.SUCCEEDED;
        }
    }

    /**
     * Retrieves the specified state by name.
     *
     * @param name The name of the state.
     * @return a state or null.
     */
    [Inline]
    final public function getState( name : String ) : CState {
        if ( mStates ) {
            return mStates[ name ];
        }
        return null;
    }

    /**
     * Adds the specified state.
     *
     * @param state CState
     * @return this
     */
    public function addState( state : CState ) : CFiniteStateMachine {
        if ( !mStates )
            mStates = new Dictionary();

        if ( !state.name )
            throw new IllegalOperationError( "Invalid name of CState in addState." );

        if ( state.name in mStates && state == mStates[ state.name ] )
            return this;

        mStates[ state.name ] = state;
        state.fsm = this;
        state.dispatchEvent( new Event( Event.ADDED ) );

        return this;
    }

    /**
     * Removes the specified state.
     *
     * @param state CState or state's name.
     * @param bDispose A flag to call dispose needed.
     * @return this
     */
    public function removeState( state : *, bDispose : Boolean = false ) : CFiniteStateMachine {
        if ( mStates ) {
            var name : String;
            if ( state is String )
                name = state;
            else if ( state is CState )
                name = state.name;

            if ( name && (name in mStates) ) {
                var origin : CState = mStates[ name ];
                delete mStates[ name ];
                origin.dispatchEvent( new Event( Event.REMOVED ) );
                if ( bDispose )
                    origin.dispose();
                origin.fsm = null;
            }
        }
        return this;
    }

    /**
     * Cleanup the Finite CState-Machine instance.
     */
    public function dispose() : void {
        if ( mStates ) {
            for ( var k : * in mStates ) {
                removeState( k, true );
            }
        }

        mTerminal = null;
        mStates = null;
        mInitial = null;
        mEventMap = null;
        mEvents.splice( 0, mEvents.length );
        mEvents = null;
        mCfg = null;

        detachEventListeners();
        removeEventListener( CStateEvent.TRANSITION_CANCELLED, onTransition );
        removeEventListener( CStateEvent.TRANSITION_COMPLETE, onTransition );
    }

    /** Initialize */
    protected function init() : Boolean {
        // Parse the configuration.
        if ( !mCfg )
            return false;

        this.mInitial = (mCfg.initial is String) ? {state : mCfg.initial} : mCfg.initial;
        this.mTerminal = mCfg.terminal || mCfg[ 'final' ];
        this.mEvents = mCfg.events || [];
        this.mEventMap = {};

        // Nested helper: constructs the event-state map.
        function add( e : * ) : void {
            var from : Array = (e.from is Array) ? e.from : (e.from ? [ e.from ] : [ CFiniteStateMachine.WILDCARD ]);
            mEventMap[ e.name ] = mEventMap[ e.name ] || {};
            for ( var n : int = 0; n < from.length; ++n ) {
                mEventMap[ e.name ][ from[ n ] ] = e.to || from[ n ];
            }
        }

        if ( mInitial ) {
            mInitial.event = mInitial.event || 'startup';
            add( {name : mInitial.event, from : BUILTIN_STATES.NONE, to : mInitial.state} );
        }

        for ( var n : int = 0; n < mEvents.length; ++n ) {
            add( mEvents[ n ] );
        }

        mCurrent = BUILTIN_STATES.NONE;

        if ( mInitial && !mInitial.defer ) {
            on( mInitial.event );
        }

        attachEventListeners();

        return true;
    }

    private function onTransition( event : CStateEvent ) : void {
        removeEventListener( CStateEvent.TRANSITION_CANCELLED, onTransition );
        removeEventListener( CStateEvent.TRANSITION_COMPLETE, onTransition );

        if ( event.type == CStateEvent.TRANSITION_COMPLETE ) {
            mCurrent = event.to;
            dispatchEvent( new CStateEvent( CStateEvent.ENTER, event.from, event.to, event.argList ) );
        }

        mTransition = false;

        dispatchEvent( new CStateEvent( CStateEvent.AFTER, event.from, event.to, event.argList ) );

        if ( event.type == CStateEvent.TRANSITION_COMPLETE ) {
            dispatchEvent( new CStateEvent( CStateEvent.CHANGE, event.from, event.to, event.argList ) );
        }
    }

    private function attachEventListeners() : void {
        addEventListener( CStateEvent.ENTER, onStateDispatchDelegate, false );
        addEventListener( CStateEvent.LEAVE, onStateDispatchDelegate, false );
        addEventListener( CStateEvent.BEFORE, onStateDispatchDelegate, false );
        addEventListener( CStateEvent.AFTER, onStateDispatchDelegate, false );
        addEventListener( CStateEvent.CHANGE, onStateDispatchDelegate, false );
    }

    private function detachEventListeners() : void {
        removeEventListener( CStateEvent.ENTER, onStateDispatchDelegate, false );
        removeEventListener( CStateEvent.LEAVE, onStateDispatchDelegate, false );
        removeEventListener( CStateEvent.BEFORE, onStateDispatchDelegate, false );
        removeEventListener( CStateEvent.AFTER, onStateDispatchDelegate, false );
        removeEventListener( CStateEvent.CHANGE, onStateDispatchDelegate, false );
    }

    private function onStateDispatchDelegate( event : CStateEvent ) : void {
        var pState : CState;
        if ( event.type == CStateEvent.BEFORE ) {
            pState = getState( event.to );
        } else if ( event.type == CStateEvent.AFTER ) {
            pState = getState( event.from );
        } else if ( currentState ) {
            pState = this.currentState;
        }

        if ( pState ) {
            var pStateEvent : CStateEvent = new CStateEvent( event.type, event.from, event.to, event.argList );
            if ( !pState.dispatchEvent( pStateEvent ) ) {
                if ( pStateEvent.isDefaultPrevented() )
                    event.preventDefault();
            }
        }
    }

}
}
