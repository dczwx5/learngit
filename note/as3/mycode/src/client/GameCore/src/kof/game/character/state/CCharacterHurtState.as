//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;
import QFLib.Foundation.free;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.framework.fsm.CStateEvent;
import kof.game.character.CKOFTransform;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillMotionAssembly;
import kof.game.character.fight.skilleffect.util.CSkillScreenIns;
import kof.game.character.fx.CFXMediator;
import kof.game.character.scene.CSceneMediator;
import kof.table.Hit.EHurtAnimationCategory;
import kof.table.Motion;
import kof.util.CAssertUtils;

/**
 * 受击打状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterHurtState extends CCharacterState implements IUpdatable {

    static public const DEFAULT_FROZEN_TIME : Number = 0.0;
//    static public const DEFAULT_FROZEN_TIME : Number = 0.5;
    static private const DEFAULT_MOVEMENT_TIME : Number = 0.1;

    /** @private */
    private var m_fTimeLeft : Number;
    /** @private */
    private var m_fElapsedTime : Number;
    /** @private */
    private var m_bAnimationEnd : Boolean;
    /** @private */
    private var m_bGuard : Boolean;
    /** @private */
    private var m_bLying : Boolean;
    private var m_motionData : Motion;
    private var m_motionFacade : CSkillMotionAssembly;
    private var m_aliasPos : CVector3;

    private var m_pDeadWatchDog : CTimeDog;
    private var m_bDeadTransition : Boolean;

    /** Creates a new CCharacterGuardState */
    public function CCharacterHurtState() {
        super( CCharacterActionStateConstants.HURT );
        m_bAnimationEnd = true;
        m_bDeadTransition = false;
    }

    override public function dispose() : void {
        super.dispose();

        if ( null != m_motionFacade )
            m_motionFacade.dispose();

        m_motionFacade = null;
        m_motionData = null;

    }

    final public function get guard() : Boolean {
        return m_bGuard;
    }

    final public function get lying() : Boolean {
        return m_bLying;
    }

    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        // 死亡后不可鞭尸
        if ( event.from != CCharacterActionStateConstants.HURT )
            m_bLying = false;

        var ret : Boolean = true;
        var toLying : Boolean = false;
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( event.from == CCharacterActionStateConstants.KNOCK_UP ) {
            if ( pStateBoard ) {
                if ( pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                    ret = true;
                    toLying = true;
                }
                else
                    ret = false;
            }
        }

        // var ret : Boolean = !isDead;
        if ( ret ) {
            if ( event.from == CCharacterActionStateConstants.LYING || toLying// ||event.from == CCharacterActionStateConstants.HURT
            ) {
                if ( pStateBoard ) {
                    m_bLying = pStateBoard.getValue( CCharacterStateBoard.LYING );
                }
            }
        }
        Foundation.Log.logTraceMsg(" Hurt From Lying : " + m_bLying  + "   ret :" + ret ) ;
        return ret;
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );
        this.onEnterHurt( event, false );
    }

    override protected virtual function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );

        // Re-enter hurt.
        // set to idle first, then set to hurt in animation.
        this.clearSubscribeAnimationEnds();
        if ( this.isRunning || ( !this.m_bDeadTransition && event.to == CCharacterActionStateConstants.DEAD ) || event.from == event.to ) {
            this.onEnterHurt( event, true );
        }

        if( lying && event.from != event.to && event.to != CCharacterActionStateConstants.LYING ) {
            var pStateboard : CCharacterStateBoard = this.stateBoard;
            if( pStateboard )
                pStateboard.resetValue( CCharacterStateBoard.LYING );
        }
    }

    private function makeExit() : Boolean {
        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.popFrozenFrameCallback( _onResumeAnimation );
            pAnimation.resumeFrame();
            pAnimation.speedUpAnimation( 1.0 );
        }
        var collisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
        if ( collisionComp )
            collisionComp.resumeCollisionSpeed();

        if ( null != m_motionFacade ) {
            m_motionFacade.unSubscribeDoMotion();
            m_aliasPos = null;
            m_motionData = null;
        }

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_GUARD, false );
            pStateBoard.setValue( CCharacterStateBoard.COUNTER, false );
            pStateBoard.setValue( CCharacterStateBoard.CRITICAL_HIT, false );
            pStateBoard.setValue( CCharacterStateBoard.CRITICAL_HIT_COUNTER, false );
            pStateBoard.setValue( CCharacterStateBoard.IN_HURTING, false );
            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL, true );
        }

        m_fTimeLeft = NaN;
        m_fElapsedTime = NaN;
        m_bGuard = false;
        m_bLying = false;

        return true;
    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        if ( !m_bDeadTransition && event.to == CCharacterActionStateConstants.DEAD ) {
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_CANCELLED, event.from, event.to, event.argList ) );
            return false;
        }

        var ret : Boolean = super.onExitState( event );
        ret = ret && makeExit();
        return ret;
    }

    /** @private */
    protected function onEnterHurt( event : CStateEvent, bReEnter : Boolean ) : void {
        this.setMovable( false );
        this.setDirectionPermit( false );
        this.makeStop();

//        if ( m_motionFacade ) {
//            m_motionFacade.exitMotion();
//        }

        var iTypeOfHurt : int = int( event.argList[ 1 ] ); // 1: hurt, 2: guard
        var iTypeOfPart : int = int( event.argList[ 2 ] ); // 0: none, 1: upper, 2: lower
        var iDirectionX : int = int( event.argList[ 3 ] );
        var fFrozenTime : Number = Number( event.argList[ 4 ] ) || DEFAULT_FROZEN_TIME;

        m_motionData = Motion( event.argList [ 5 ] || null );
//        CAssertUtils.assertNotNull( m_motionData );
        m_aliasPos = CVector3( event.argList [ 6 ] || null );
        var fAnimationDuration : int = int( event.argList[ 7 ] );
        var pSounds : Array = (event.argList[ 8 ] || null);
        var pSceneShake : Array = ( event.argList[ 9 ] || null);
        var modelShake : int = ( event.argList[ 10 ] );
        var fDistanceRadio : Number = ( event.argList[ 11 ] || 0.0 );
        var sElementEffect : String = ( event.argList[ 12 ] || null);

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        var pDir : Point = new Point( 1, 0 );

        if ( pStateBoard )
            pDir = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );

        if ( iDirectionX == 0 ) {
            iDirectionX = pDir.x;
            iDirectionX = -iDirectionX || 1;
        } else {
            // turn to target direction and being hurt.
            if ( pStateBoard )
                pDir.x = -iDirectionX;
        }

        hurtBegan( iTypeOfHurt, iTypeOfPart, iDirectionX, fFrozenTime, fAnimationDuration, bReEnter, modelShake, fDistanceRadio, sElementEffect );
        sceneShake( iTypeOfHurt, pSceneShake );
    }

    /**
     *
     * @param iTypeOfHurt
     */
    private function sceneShake( iTypeOfHurt : int, pSceneShake : Array ) : void {
        var sceneMediator : CSceneMediator = this.sceneMediator;
        if ( !sceneMediator || !pSceneShake || !pSceneShake.length )
            return;

        var center2D : CVector3;
        var centerTransform : CKOFTransform;
        centerTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        center2D = new CVector3( centerTransform.x, centerTransform.y, centerTransform.z );

        if ( iTypeOfHurt == 2 ) {
            if ( pSceneShake[ 1 ] ) {
                for each ( var shakeID : int in pSceneShake[ 1 ] )
                    CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID, center2D );
            }

        } else {
            if ( pSceneShake[ 0 ] ) {
                for each ( var shakeID1 : int in pSceneShake[ 0 ] )
                    CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID1, center2D );
            }
        }

    }

    private function hurtBegan( iTypeOfHurt : int, iTypeOfPart : int, iDirX : int, fFrozenTime : Number, fAnimationDuration : int,
                                bForceReply : Boolean = false, modelShake : int = 0, fDistanceRadio : Number = 0.0, sElementEffect : String = "" ) : void {
        var fAnimationSpeed : Number = NaN;
        var bSpeedUp : Boolean = false;
        this.m_fElapsedTime = 0.0;

        var pAnimation : IAnimation = this.animation;
        var sAnimationState : String = CAnimationStateConstants.HURT_MILD;

        m_bGuard = iTypeOfHurt == 2;
        m_bDeadTransition = false;

        if ( isDead ) {
            sAnimationState = CAnimationStateConstants.DEAD;
        } else if ( m_bLying ) { // lying.
            sAnimationState = CAnimationStateConstants.HURT_LYING;
        } else if ( m_bGuard ) { // guard.
            if ( iTypeOfPart == EHurtAnimationCategory.E_UPPER )
                sAnimationState = CAnimationStateConstants.GUARD_BY_STAND;
            else if ( iTypeOfPart == EHurtAnimationCategory.E_LOWER )
                sAnimationState = CAnimationStateConstants.GUARD_BY_UPDOWN;
        } else {
            if ( iTypeOfPart == EHurtAnimationCategory.E_UPPER )
                sAnimationState = CAnimationStateConstants.HURT_SEVERE;
            else if ( iTypeOfPart == EHurtAnimationCategory.E_LOWER )
                sAnimationState = CAnimationStateConstants.HURT_MILD;

            if ( fAnimationDuration )
                bSpeedUp = true;
        }

        if ( pAnimation ) {
            pAnimation.playAnimation( sAnimationState, bForceReply );

            if ( bSpeedUp ) {
                fAnimationSpeed = pAnimation.getAnimationTime( sAnimationState ) / (fAnimationDuration * CSkillDataBase.TIME_IN_ONEFRAME);
            }

            if ( sAnimationState == CAnimationStateConstants.DEAD ) {
                var fDeadAnimDuration : Number = pAnimation.getAnimationTime( sAnimationState );
                if ( !m_pDeadWatchDog ) {
                    m_pDeadWatchDog = new CTimeDog( _onCurrentAnimationEnd );
                }

                m_pDeadWatchDog.start( (isNaN( fAnimationSpeed ) ? 1.0 : fAnimationDuration ) * fDeadAnimDuration + fFrozenTime );
            }

            this.m_bAnimationEnd = false;
            this.subscribeAnimationEnd( _onCurrentAnimationEnd );

            pAnimation.frozenFrame( fFrozenTime, _onResumeAnimation, iDirX, fAnimationSpeed, fDistanceRadio );
            if ( fFrozenTime > 0.0 ) {
                skillCaster.playCharacterShake( modelShake, fFrozenTime );
                var pCollisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
                if ( pCollisionComp ) {
                    pCollisionComp.collisionSpeed = 0.0;
                }

            }
        }

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            if ( m_bGuard )
                pStateBoard.setValue( CCharacterStateBoard.IN_GUARD, true );
            else {
                pStateBoard.setValue( CCharacterStateBoard.IN_HURTING, true );
                pStateBoard.setValue( CCharacterStateBoard.IN_GUARD, false );
            }

            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL, false );
        }
    }

    private function _onResumeAnimation( iDirX : int, fAnimationSpeed : Number = 1.0 , fDistanceRadio : Number = 0.0 ) : void {

//         CAssertUtils.assertNotNull( m_motionData );

        if ( m_motionData != null ) {
            var boCanDoMotion : Boolean = true;
            var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if ( pStateBoard ) {
                boCanDoMotion = pStateBoard.getValue( CCharacterStateBoard.CAN_BE_DO_MOTION );
            }

            if ( m_motionFacade == null ) {
                m_motionFacade = new CSkillMotionAssembly( owner );
            }

            CSkillDebugLog.logTraceMsg( "=========HURT MOTION=========>" + m_motionData.ID );
            m_motionFacade.iDirectionX = -iDirX;
            if ( boCanDoMotion )
                m_motionFacade.subscribeDoMotion( m_motionData, m_aliasPos, null, false, fDistanceRadio );
        }

        var pCollisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
        if ( pCollisionComp ) {
            pCollisionComp.collisionSpeed = fAnimationSpeed;
        }

        if ( fAnimationSpeed ) {
            var pAnimation : IAnimation = this.animation;
            if ( pAnimation ) {
                pAnimation.speedUpAnimation( fAnimationSpeed );
            }
        }
    }

    /** @private internal useOnly */
    private function _onCurrentAnimationEnd( sEventName : String = null, sFrom : String = null, sTo : String = null ) : void {
        this.m_bAnimationEnd = true;
        m_motionData = null;
        free( m_pDeadWatchDog );
        m_pDeadWatchDog = null;
    }

    override protected function get nextStateEvent() : String {
        var ret : String = super.nextStateEvent;
        if ( ret != CCharacterActionStateConstants.EVENT_DEAD ) {
            // overrides.
            if ( lying ) { // return to lying.
                ret = CCharacterActionStateConstants.EVENT_LYING_BEGAN;
            }
        }
        return ret;
    }

    public function update( delta : Number ) : void {
        if ( null != m_motionFacade ) {
            m_motionFacade.update( delta );
        }

        if ( m_pDeadWatchDog ) {
            m_pDeadWatchDog.update( delta );
        }

        if ( (!m_motionFacade || !m_motionFacade.isRunning ) && m_bAnimationEnd ) {
            m_bDeadTransition = true;
            fsm.on( nextStateEvent );
        }
    }

}
}

// vim:ft=as3 tw=120
