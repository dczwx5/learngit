//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/3.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.statemach {

import flash.events.Event;
import flash.utils.Dictionary;

import kof.framework.fsm.CState;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fight.emitter.CMissileDisplay;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

public class CTriBaseState extends CState {

    /** @internal useOnly. */
    internal var m_pOwner : CGameObject;
    /** @internal useOnly. */
    private var m_bRunning : Boolean;
    /** @internal useOnly. */
    private var m_listAnimationEndCalls : Dictionary;
    /** @internal useOnly. */
    private var m_nAnimationEndCallCount : uint;
    /** @internal useOnly. */
    private var m_bDirSync : Boolean;

    public function CTriBaseState( name : String ) {
        super( name );
    }

    override public function dispose() : void {
        super.dispose();

        this.m_pOwner = null;
        this.m_listAnimationEndCalls = null;
    }

    final protected function get owner() : CGameObject {
        return m_pOwner;
    }

    final public function get isRunning() : Boolean {
        return m_bRunning;
    }

    final public function get dirSync() : Boolean {
        return m_bDirSync;
    }

    final public function set dirSync( value : Boolean ) : void
    {
        m_bDirSync = value;
    }

    final protected function get animationEndCallCount() : uint {
        return m_nAnimationEndCallCount;
    }

    protected function get nextStateEvent() : String {
        if ( isFade ) {
            return CTriStateConst.FADE;
        } else {
            return CTriStateConst.EVT_POP;
        }
    }

    final protected function get isFade() : Boolean
    {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            if ( true == pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) {
                return true;
            }
        }
        return false;
    }

    final protected function get stateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final protected function get eventMediator() : CEventMediator {
        return owner.getComponentByClass( CEventMediator , true ) as CEventMediator;
    }

    final  protected function get pMissileDisplay() : CMissileDisplay
    {
        return owner.getComponentByClass( CMissileDisplay , true ) as CMissileDisplay;
    }

    //----------------------------------
    // CState改造
    //----------------------------------

    final override protected function onBefore( event : CStateEvent ) : void {
        var ret : Boolean = this.onEvaluate( event );
        if ( !ret )
            event.preventDefault();
    }

    //noinspection JSMethodCanBeStatic
    protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        return true;
    }

    final override protected function onAfter( event : CStateEvent ) : void {
        if ( event.from != event.to )
            this.m_bRunning = false;
        this.onAfterState( event );
    }

    //noinspection JSMethodCanBeStatic
    protected virtual function onAfterState( event : CStateEvent ) : void {
        // Ignore.
    }

    final override protected function onEnter( event : CStateEvent ) : void {
        this.m_bRunning = true;
        this.onEnterState( event );
    }

    protected function subscribeAnimationEnd( fnCallback : Function, ... args ) : void {
        if ( null == fnCallback )
            return;

        if ( !m_listAnimationEndCalls )
            m_listAnimationEndCalls = new Dictionary();

        if ( !(fnCallback in m_listAnimationEndCalls) )
            m_nAnimationEndCallCount++;

        m_listAnimationEndCalls[ fnCallback ] = args || [];

        var pEventMediator : CEventMediator = this.eventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.ANIMATION_TIME_END, _onCurrentAnimationTimeEnd, false, 0, true );
        }
    }

    protected function clearSubscribeAnimationEnds() : void {
        if ( m_listAnimationEndCalls ) {
            m_listAnimationEndCalls = new Dictionary();
            m_nAnimationEndCallCount = 0;
        }
    }

    private final function _onCurrentAnimationTimeEnd( event : Event ) : void {
        event.currentTarget.removeEventListener( event.type, _onCurrentAnimationTimeEnd );

        if ( m_listAnimationEndCalls ) {
            for ( var pfnCallback : Function in m_listAnimationEndCalls ) {
                if ( null != pfnCallback ) {
                    var args : Array = m_listAnimationEndCalls[ pfnCallback ];
                    delete m_listAnimationEndCalls[ pfnCallback ];
                    m_nAnimationEndCallCount--;
                    pfnCallback.apply( null, args );
                }
            }
        }
    }

    protected virtual function onEnterState( event : CStateEvent ) : void {
        pMissileDisplay.resetCurrentAnimationTime();
    }

    final override protected function onExit( event : CStateEvent ) : void {
        var bNoPending : Boolean = this.onExitState( event );

        if ( !bNoPending ) {
            event.preventDefault();
        }
    }

    protected virtual function onExitState( event : CStateEvent ) : Boolean {
        return true;
    }
}
}
