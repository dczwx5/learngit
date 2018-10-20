//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Point;

import kof.framework.fsm.CFiniteStateMachine;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CKOFTransform;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillMotionAssembly;
import kof.game.character.fight.skill.ILastUpdatable;
import kof.game.character.fight.skilleffect.util.CSkillScreenIns;
import kof.table.Motion;
import kof.table.Motion.EMotionType;
import kof.table.Motion.ETransWay;
import kof.util.CAssertUtils;

/**
 * 击飞状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterKnockUpState extends CCharacterState implements IUpdatable, ILastUpdatable {

    static public const DEFAULT_LAND_DURATION : Number = 9.0 / 30;
    static public const DEFAULT_LYING_DURATION : Number = 0.5;

    private var m_motionData : Motion;
    private var m_motionFacade : CSkillMotionAssembly;
    private var m_pAliasPos : CVector3;
    private var m_pPendingEvent : CStateEvent;

    private var m_bDeadTransition : Boolean;
    private var m_bWaitLandEnded : Boolean;
    private var m_pWaitLandEndDog : CTimeDog;

    /** Creates a new CCharacterGuardState */
    public function CCharacterKnockUpState() {
        super( CCharacterActionStateConstants.KNOCK_UP );
    }

    override public function dispose() : void {
        if ( this.eventMediator )
            this.eventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );

        super.dispose();

        if ( m_motionFacade ) {
            m_motionFacade.dispose();
        }

        if ( m_pWaitLandEndDog )
            m_pWaitLandEndDog.dispose();

        m_pWaitLandEndDog = null;
        m_motionFacade = null;
        m_motionData = null;
    }

    protected function reset() : void {
        if ( m_motionFacade ) {
            m_motionFacade.exitMotion();
            m_motionFacade.dispose();
        }

        if ( m_pWaitLandEndDog ) {
            m_pWaitLandEndDog.stop();
        }

        if ( this.eventMediator ) {
            this.eventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );
        }

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation )
            pAnimation.popFrozenFrameCallback( _onFrozenAnimationEnd );

        m_motionFacade = null;
        m_motionData = null;
        m_pAliasPos = null;

        m_bDeadTransition = false;
        m_bWaitLandEnded = false;
    }

    override protected function onEvaluate( event : CStateEvent ) : Boolean {
        // return !isDead;
        return true;
    }

    override protected function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );

        this.onKnockUpBegan( event, false );
    }

    override protected function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );

        // Re-enter hurt.
        // set to idle first, then set to hurt in animation.
        this.clearSubscribeAnimationEnds();
        if ( this.isRunning || ( !this.m_bDeadTransition && event.to == CCharacterActionStateConstants.DEAD ) || event.from == event.to ) {
            this.onKnockUpBegan( event, true );
        }
    }

    private function makeExit() : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.IN_HURTING );
            pStateBoard.resetValue( CCharacterStateBoard.IN_CONTROL );
        }

        if ( m_motionFacade ) {
            m_motionFacade.unSubscribeDoMotion();
            m_motionData = null;
        }

        m_bWaitLandEnded = false;

        if ( eventMediator )
            eventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );

        var pAnimation : IAnimation = this.animation;

        if ( pAnimation )
            pAnimation.popFrozenFrameCallback( _onFrozenAnimationEnd );
    }

    override protected function onExitState( event : CStateEvent ) : Boolean {
        var ret : Boolean = super.onExitState( event );

        if ( !m_bDeadTransition && event.to == CCharacterActionStateConstants.DEAD ) {
            // 接入死亡，应该在落地完成后实行
            m_pPendingEvent = event;
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_CANCELLED, event.from, event.to, event.argList ) );
            return false;
        } else {
            makeExit();

//            var pStateBoard : CCharacterStateBoard = this.stateBoard;
//            if ( pStateBoard && event.to != CCharacterActionStateConstants.LYING )
//                pStateBoard.resetValue( CCharacterStateBoard.LYING );

            return ret;
        }
    }

    override protected function get nextStateEvent() : String {
        var ret : String = super.nextStateEvent;
        if ( ret != CCharacterActionStateConstants.EVENT_DEAD ) {
            return CCharacterActionStateConstants.EVENT_LYING_BEGAN;
        }
        return ret;
    }

    /** @private */
    protected function onKnockUpBegan( event : CStateEvent, bReEnter : Boolean ) : void {
        this.setMovable( false );
        this.setDirectionPermit( false );
        this.makeStop();

        this.reset();

        var iDirectionX : int = int( event.argList[ 1 ] );
        var fFrozenTime : Number = Number( event.argList[ 2 ] ) || 0.15;

        m_motionData = Motion( event.argList [ 3 ] || null );
        m_pAliasPos = CVector3( event.argList [ 4 ] || null );
        var hitSounds : Array = event.argList[ 5 ] || null;
        var pSceneShake : Array = ( event.argList[ 6 ] || null );
        var iCharacterShake : int = event.argList[ 7 ];
        var fDecreaseRadio : Number = event.argList[ 8 ] || 1.0;

        var pDir : Point = new Point( 1, 0 );
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard )
            pDir = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );

        if ( iDirectionX == 0 ) {
            iDirectionX = pDir.x;
            iDirectionX = -iDirectionX || 1;
        } else {
            // turn to target direction and being hurt.
            if ( pStateBoard ) {
                pDir.x = -iDirectionX;
            }
        }

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.playAnimation( CAnimationStateConstants.AERO_DEFAULT, true );
            pAnimation.frozenFrame( fFrozenTime, _onFrozenAnimationEnd, iDirectionX, fDecreaseRadio );
            if ( fFrozenTime > 0 )
                skillCaster.playCharacterShake( iCharacterShake, fFrozenTime );
        }

        if ( pSceneShake ) {
            var center2D : CVector3;
            var centerTransform : CKOFTransform;
            centerTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            center2D = new CVector3( centerTransform.x, centerTransform.y, centerTransform.z );

            if ( null != pSceneShake[ 0 ] ) {
                for each( var shakeID : int in pSceneShake[ 0 ] ) {
                    CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID, center2D );
//                    skillCaster.playSceneShakeEffect( shakeID, center2D);
                }
            }
        }

        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_HURTING, true );
            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL, false );
//            pStateBoard.resetValue( CCharacterStateBoard.LYING );
        }

    }

    private function _onFrozenAnimationEnd( iDirectionX : int, fDecreaseRadio : Number = 1.0 ) : void {
        var boCanDoMotion : Boolean = true;
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            boCanDoMotion = pStateBoard.getValue( CCharacterStateBoard.CAN_BE_DO_MOTION );
        }
        if ( !boCanDoMotion ) {
            _landDirectly();
            return;
        }

        if ( !m_motionData ) { // FIXME: testing code block.
            Foundation.Log.logTraceMsg( "Construct testing KnockUp MotionData." );

            m_motionData = new Motion( {
                ID : 0,
                Description : null,
                MoveType : EMotionType.KNOCKUP,
                TransWay : ETransWay.BACKWARD,
                xSpeed : 600,
                ySpeed : 1000,
                zSpeed : 0,
                xDamping : 0,
                yDamping : 9.8,
                Duration : 1
            } );
        }

        if ( m_motionData ) {
            var ySpeed : Number = m_motionData.ySpeed;
            if ( ySpeed == 0.0 )
                CSkillDebugLog.logErrorMsg( "Motion (ID :" + m_motionData.ID + ") Knocks up enemy, but the ySpeed in the Table is 0 , Unacceptable" )
            if ( !m_motionFacade ) {
                m_motionFacade = new CSkillMotionAssembly( owner );
            }

            m_motionFacade.iDirectionX = -iDirectionX;

            _resetToGroundWhenBuried();
            m_motionFacade.subscribeDoMotion( m_motionData, m_pAliasPos, null, true, fDecreaseRadio );
            update(0.0);

            if ( this.eventMediator ) {
                this.eventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround, false, 0, true );
            }
        }

    }

    private function _onGround( event : Event ) : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) &&
                pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
            event.currentTarget.removeEventListener( event.type, _onGround );

//            pStateBoard.setValue( CCharacterStateBoard.LYING, true );
            m_bDeadTransition = true;
            m_bWaitLandEnded = true;

            if ( !m_pWaitLandEndDog )
                m_pWaitLandEndDog = new CTimeDog( _onLandEnd );

            m_pWaitLandEndDog.start( DEFAULT_LAND_DURATION );
        }
    }

    private function _landDirectly() : void {
        m_bDeadTransition = true;
        m_bWaitLandEnded = true;

        if ( !m_pWaitLandEndDog )
            m_pWaitLandEndDog = new CTimeDog( _onLandEnd );

        m_pWaitLandEndDog.start( DEFAULT_LAND_DURATION );
    }

    private function _onLandEnd() : void {
        m_pWaitLandEndDog.stop();

        if ( m_pPendingEvent ) {
            const pPendingEvent : CStateEvent = m_pPendingEvent;
            m_pPendingEvent = null;
            fsm.on.apply( null, [ nextStateEvent ].concat( pPendingEvent.argList ) )
        } else {
            var ret : int = fsm.on( nextStateEvent, DEFAULT_LYING_DURATION, m_motionFacade );
            if ( ret == CFiniteStateMachine.Result.CANCELLED ) {
                CAssertUtils.assertTrue( false, "Can't enter '" + nextStateEvent + "' from KNOCKUP." );
            }
        }
    }

    public function update( delta : Number ) : void {
        if ( m_motionFacade ) {
            m_motionFacade.firstUpdate( delta );
        }
//        CONFIG::debug{
//            CSkillDebugLog.logTraceMsg("The Knock Up pos is " + _transform.position.toString() );
//        }

        if ( m_pWaitLandEndDog && m_pWaitLandEndDog.running ) {
            m_pWaitLandEndDog.update( delta );
        }
    }

    public function lastUpdate( delta : Number ) : void {
        if ( m_motionFacade ) {
            m_motionFacade.lastUpdate( delta );
        }
    }

    private function get _transform() : CKOFTransform {
        return owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    private function _resetToGroundWhenBuried() : void {
        if ( _transform && _transform.z < 0 )
            _transform.move( 0, 0, 0, false, true );
    }

}
}
