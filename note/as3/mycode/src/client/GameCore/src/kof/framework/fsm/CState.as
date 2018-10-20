//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.fsm {

import QFLib.Interface.IDisposable;

import flash.events.Event;
import flash.events.EventDispatcher;

[Event(name="enterState", type="kof.framework.fsm.CStateEvent")]
[Event(name="leaveState", type="kof.framework.fsm.CStateEvent")]
/**
 * Represent a CState of Finite CState-Machine.
 *
 * @author Jeremy
 */
public class CState extends EventDispatcher implements IDisposable {

    private var m_strName : String;
    private var m_pFSM : CFiniteStateMachine;

    /**
     * Constructor
     *
     * @param name The name of the state.
     */
    public function CState( name : String = null ) {
        this.m_strName = name;

        init();
    }

    public function dispose() : void {
        detachEventListeners();
        m_pFSM = null;
        m_strName = null;
    }

    final public function get name() : String {
        return m_strName;
    }

    final public function set name( value : String ) : void {
        m_strName = value;
    }

    final public function get fsm() : CFiniteStateMachine {
        return m_pFSM;
    }

    final public function set fsm( value : CFiniteStateMachine ) : void {
        m_pFSM = value;
    }

    private function init() : void {
        addEventListener( Event.ADDED, onAddedRemoved, false, 0, true );
    }

    private function onAddedRemoved( event : Event ) : void {
        switch ( event.type ) {
            case Event.ADDED:
                attachEventListeners();
                break;
            case Event.REMOVED:
                detachEventListeners();
                break;
            default:
                break;
        }
    }

    private function attachEventListeners() : void {
        addEventListener( Event.REMOVED, onAddedRemoved, false );
        addEventListener( CStateEvent.ENTER, onEnter, false );
        addEventListener( CStateEvent.LEAVE, onExit, false );
        addEventListener( CStateEvent.BEFORE, onBefore, false );
        addEventListener( CStateEvent.AFTER, onAfter, false );
        addEventListener( CStateEvent.CHANGE, onStateChange, false );
    }

    private function detachEventListeners() : void {
        removeEventListener( Event.REMOVED, onAddedRemoved, false );
        removeEventListener( CStateEvent.ENTER, onEnter, false );
        removeEventListener( CStateEvent.LEAVE, onExit, false );
        removeEventListener( CStateEvent.BEFORE, onBefore, false );
        removeEventListener( CStateEvent.AFTER, onAfter, false );
        removeEventListener( CStateEvent.CHANGE, onStateChange, false );
    }

    protected virtual function onBefore( event : CStateEvent ) : void {

    }

    protected virtual function onAfter( event : CStateEvent ) : void {

    }

    protected virtual function onStateChange( event : CStateEvent ) : void {

    }

    protected virtual function onEnter( event : CStateEvent ) : void {

    }

    protected virtual function onExit( event : CStateEvent ) : void {

    }

}
}
