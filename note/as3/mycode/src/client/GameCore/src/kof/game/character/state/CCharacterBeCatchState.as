//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation.CTimeDog;
import QFLib.Foundation.free;

import flash.events.Event;

import kof.framework.fsm.CFiniteStateMachine;

import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.animation.IAnimation;
import kof.game.character.movement.CMovement;
import kof.util.CAssertUtils;

/**
 * 角色被抓取状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterBeCatchState extends CCharacterState {

    private var m_pDeadWatchDog : CTimeDog;
    private var m_bDeadTransition : Boolean;

    /**
     * Creates a new CCharacterBeCatchState.
     */
    public function CCharacterBeCatchState() {
        super( CCharacterActionStateConstants.BE_CATCH );
        m_bDeadTransition = false;
    }

    override public function dispose() : void {
        super.dispose();

        free( m_pDeadWatchDog );
        {
            m_pDeadWatchDog = null;
        }
    }

    override protected function onEvaluate( event : CStateEvent ) : Boolean {
        var ret : Boolean = super.onEvaluate( event );
        if ( event.from == CCharacterActionStateConstants.GETUP || event.from == CCharacterActionStateConstants.DEAD )
            return false;

        return ret;
    }

    override protected function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );

        if ( this.isRunning ||
                ( !this.m_bDeadTransition && event.to ==
                CCharacterActionStateConstants.DEAD ) || event.from == event.to ) {
            // re-entered.
            this.onBeCatch( event, true );
        }
    }

    override protected function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );
        this.onBeCatch( event, false );
    }

    override protected function onExitState( event : CStateEvent ) : Boolean {
        if ( !m_bDeadTransition && event.to == CCharacterActionStateConstants.DEAD ) {
            m_pendingEvent = event;
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_CANCELLED,
                    event.from, event.to, event.argList ) );
            return false;
        }

        var ret : Boolean = super.onExitState( event );
        ret = ret && makeExit();
        return ret;
    }

    protected function onBeCatch( event : CStateEvent, bReEnter : Boolean ) : void {
        this.setMovable( false );
        this.setDirectionPermit( false );
        this.makeStop();

        // parse arguments.
        var sAnimationState : String = String( event.argList[ 1 ] );
        var iDirByOwner : int = int( event.argList[ 2 ] );
        var bFlip : Boolean = false;

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_CATCH, true );
            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL, false );
        }

        if ( iDirByOwner ) {
            if ( pStateBoard ) {
                var pDirRef : Object = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                if ( pDirRef ) {
                    if ( int( pDirRef.x ) == iDirByOwner )
                        bFlip = true;
                }

                if ( bFlip ) {
                    pDirRef.x = -pDirRef.x;
                    pStateBoard.setValue( CCharacterStateBoard.DIRECTION, pDirRef );
                }
            }
        }

        var vAnimation : IAnimation = this.animation;
        if ( vAnimation ) {
            vAnimation.lastFrameMode = true;
            vAnimation.playAnimation( sAnimationState.toUpperCase(), true );
        }

        // disabled movement component.
        var vMovement : CMovement = this.movement;
        if ( vMovement ) {
            vMovement.enabled = false;
        }
//        var boOnGround : Boolean = stateBoard.getValue( CCharacterStateBoard.ON_GROUND );
//            if( stateBoard.getValue( CCharacterStateBoard.DEAD_SIGNED ) ){
//            if( boOnGround ) {
//                fsm.on.apply( null, [ nextStateEvent ].concat( m_pendingEvent.argList ) )
//            }
//            if ( this.eventMediator && !boOnGround ) {
//                this.eventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onDeadGround, false, 0, true );
//            }
//        }
    }

    private function _onDeadGround( e : Event ) : void {

        if ( this.stateBoard && this.stateBoard.isDirty( CCharacterStateBoard.ON_GROUND )
                && this.stateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
            if ( this.eventMediator )
                 this.eventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onDeadGround );

            if ( m_pendingEvent ) {
                const pPendingEvent : CStateEvent = m_pendingEvent;
                m_pendingEvent = null;
                fsm.on.apply( null, [ nextStateEvent ].concat( pPendingEvent.argList ) )
            }
            m_bDeadTransition = true;
        }
    }

    protected function makeExit() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_CATCH, false );
            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL, true );
        }

        var vAnimation : IAnimation = this.animation;
        if ( vAnimation ) {
            vAnimation.lastFrameMode = false;
        }

        var vMovement : CMovement = this.movement;
        if ( vMovement ) {
            vMovement.clearAllMotionActions();
            vMovement.enabled = true;
        }
        return true;
    }

    public function set deadTransition( value : Boolean ) : void{
        this.m_bDeadTransition = value;
    }

    private var m_pendingEvent : CStateEvent;

}
}
