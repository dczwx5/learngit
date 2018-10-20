//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import flash.events.Event;
import flash.utils.Dictionary;

import kof.framework.fsm.CState;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.CNetworkMessageMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fx.CFXMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;

/**
 * 角色状态基类
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterState extends CState {

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

    public function CCharacterState( name : String ) {
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

    final public function set dirSync( value : Boolean ) : void {
        m_bDirSync = value;
    }

    final protected function get animationEndCallCount() : uint {
        return m_nAnimationEndCallCount;
    }

    protected function get nextStateEvent() : String {
        if ( isDead ) {
            return CCharacterActionStateConstants.EVENT_DEAD;
        } else {
            return CCharacterActionStateConstants.EVENT_POP;
        }
    }

    final protected function get isDead() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            if ( true == pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) {
                return true;
            }
        }
        return false;
    }

    final protected function get movement() : CMovement {
        return owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    final protected function get input() : CCharacterInput {
        return owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
    }

    final protected function get animation() : IAnimation {
        return owner.getComponentByClass( IAnimation, true ) as IAnimation;
    }

    final protected function get skin() : IDisplay {
        return owner.getComponentByClass( IDisplay, true ) as IDisplay;
    }

    final protected function get eventMediator() : CEventMediator {
        return owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
    }

    final protected function get facadeMediator() : CFacadeMediator {
        return owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
    }

    final protected function get skillCaster() : CSkillCaster {
        return owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    final protected function get stateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final protected function get audioMediator() : CAudioMediator {
        return owner.getComponentByClass( CAudioMediator, true ) as CAudioMediator;
    }

    final protected function get sceneMediator() : CSceneMediator {
        return owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
    }

    final protected function get fightCalc() : CFightCalc {
        return owner.getComponentByClass( CFightCalc, true ) as CFightCalc;
    }

    final protected function get pFxMediator() : CFXMediator {
        return owner.getComponentByClass( CFXMediator, true ) as CFXMediator;
    }

    final protected function get pNetworkMediator() : CNetworkMessageMediator {
        return owner.getComponentByClass( CNetworkMessageMediator, true ) as CNetworkMessageMediator;
    }

    final protected function makeStop() : void {
        var pMovement : CMovement = this.movement;
        if ( pMovement ) {
            pMovement.direction.setTo( 0, 0 );
        }
    }


    final protected function get isMovable() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.MOVABLE );
        }
        return false;
    }

    final protected function setMovable( bMovable : Boolean ) : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.MOVABLE, bMovable );
        }

        if( pNetworkMediator )
                pNetworkMediator.bForceBanMoveSchedule = !bMovable;

//        this.m_bMovementSync = bMovable;
    }

    final protected function get isDirectionPermit() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.DIRECTION_PERMIT );
        }
        return false;
    }

    final protected function setDirectionPermit( bPermit : Boolean ) : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION_PERMIT, bPermit );
        }
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
