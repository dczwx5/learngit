//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation.CTimeDog;
import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.geom.Point;

import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.ai.CAILog;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.CBaseAnimationDisplay;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillEvaluator;
import kof.game.character.fight.skill.ESkillSkipType;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.CPropertyRecovery;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CCharacterProperty;
import kof.table.Motion;

import org.msgpack.NullWorker;

/**
 * 角色闪避状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterDodgeState extends CCharacterState implements IUpdatable {

//    static public const VELOCITY_FACTOR : Number = 1.1;
    static public const VELOCITY_FACTOR : Number = 0.8;

    private var m_bLying : Boolean;
    private var m_bERoll : Boolean;
    private var m_bQuickStand : Boolean;

    public function CCharacterDodgeState() {
        super( CCharacterActionStateConstants.E_ROLL );
    }

    override public function dispose() : void{
        if( m_delayDog ) {
            m_delayDog.stop();
            m_delayDog.dispose();
            m_delayDog = null;
        }
    }
    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
//       if(  pLevelMediator && pLevelMediator.isPVP ){
//           return false;
//       }

        var bRet : Boolean = false;
        var bOnGround : Boolean = true;
        var bLying : Boolean = false;
        var bCostRP : Boolean = false;
        var bInSuperSkill : Boolean = false;
        var bBanNormalDodge : Boolean = true;
        var banDodge : Boolean;

        var condition : Array = event.argList ? event.argList[ 1 ] : null;
        var boIgnoreRP : Boolean = condition && condition[ 0 ] == ESkillSkipType.SKIP_RP_EVALUATE;
        var boNetSync : Boolean = event.argList ? event.argList[ 2 ] : false;
        if ( boNetSync ) {
            m_bQuickStand = true;
            return true;
        }

        m_bQuickStand = false;

        var pSkillCat : CSkillCaster = this.skillCaster;
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;

        if ( pSkillCat ) {
            bInSuperSkill = pSkillCat.isInSuperSkill();
            if ( bInSuperSkill ) return false;
        }

        if ( pStateBoard ) {
            if ( !pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) )
                bOnGround = false;

            if ( pStateBoard.getValue( CCharacterStateBoard.LYING ) )
                bLying = true;

            if( pStateBoard.getValue( CCharacterStateBoard.BAN_DODGE ))
                    banDodge = true;
        }

        if( banDodge ) {
            CAILog.logExistUnSatisfyInfo("Dodge" , "处于被大招控制中，不能受身" , CCharacterDataDescriptor.getID(owner.data));
            CSkillDebugLog.logTraceMsg( "处于不可受身的状态，可能你已经被大招封锁了" )
            return false;
        }

        var fCost : Number = 0.0;
        var pProperty : CCharacterProperty = this.owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( pProperty ) {
            if ( (!bOnGround && fsm.currentState is CCharacterHurtState) ||         //空中受伤瘦身
                    ( !bOnGround && fsm.currentState is CCharacterKnockUpState) ||   //被击飞瘦身
                    ( bOnGround && bLying ) ||                                       // 躺尸受身
                    (bOnGround && fsm.currentState is CCharacterKnockUpState) ) { // 被击飞落地受身
                fCost = pProperty.quickStandCost;
                if ( boIgnoreRP )
                    bRet = true;
                else
                    bRet = this.skillCaster.skillEvaluator.evaluateRagePower( -fCost, false );
                bCostRP = true;
                m_bQuickStand = true;

                if ( pFightTriggle ) {
                    pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null,
                            [ CCharacterSyncBoard.BO_QUICKSTANDCOST, true ] ) );
                }
            } else { // 进入防御翻滚消耗判定
                fCost = pProperty.rollCost;
                bRet = this.skillCaster.skillEvaluator.evaluateRagePower( -fCost, false );

                if ( fsm.currentState is CCharacterHurtState ) {
                    var pHurtState : CCharacterHurtState = (fsm.currentState as CCharacterHurtState);
                    if ( pHurtState ) { // 强制翻滚  && pHurtState.guard
                        fCost = pProperty.driveRollCost;

                        if ( boIgnoreRP )
                            bRet = true;
                        else
                            bRet = this.skillCaster.skillEvaluator.evaluateRagePower( -fCost, false );
                        bCostRP = true;
                        m_bQuickStand = true;
                        if ( pFightTriggle ) {
                            pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null,
                                    [ CCharacterSyncBoard.BO_DRIVEROLLCOST, true ] ) );
                        }
                    }
                } else if ( !bOnGround ) {
                    bRet = false;
                }

            }
        }

        if ( !bRet ) {
            m_bQuickStand = false;
            var pEventMediator : CEventMediator = this.eventMediator;
            if ( pEventMediator ) {
                pEventMediator.dispatchEvent( new Event( CCharacterEvent.DODGE_FAILED ) );
            }
        } else {
            // 重置防御值恢复计数
            var theSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
            var theSkillEvaluator : CSkillEvaluator = theSkillCaster.skillEvaluator;

            var boInCD : Boolean;
            var pFightCalc : CFightCalc = owner.getComponentByClass( CFightCalc, true ) as CFightCalc;

            if ( theSkillEvaluator ) {
                if ( bCostRP ) {

                    boInCD = theSkillEvaluator.evaluateSkillCDByID( CSkillDataBase.SKILL_ID_QUICKSTAND_SIM );
                } else {
                    boInCD = theSkillEvaluator.evaluateSkillCDByID( CSkillDataBase.SKILL_ID_DODGE_SIM );
                }

                bRet = bRet && boInCD;
            }
        }

        if ( bLying && bRet ) {
            m_bLying = true; // 记录是否是在地面趟着要飞起来
        }

        if ( bRet ) {
            if ( !bCostRP && !bBanNormalDodge ) {
                pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null,
                        [ CCharacterSyncBoard.ATTACK_POWER_DELTA, fCost ] ) );
                pFightCalc.battleEntity.calcAttackPower( -fCost );
                if ( pFightCalc ) {
                    pFightCalc.recovery.resetAttackPowerRecovery();//resetRecoveryByType( CPropertyRecovery.RECOVERY_TYPE_AP );
                }
            } else if ( bCostRP ) {
                if ( !boIgnoreRP ) {

                    var theSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
                    if ( theSyncBoard )
                        theSyncBoard.setValue( CCharacterSyncBoard.CONSUME_RAGE_POWER, fCost );
                    pFightCalc.battleEntity.calcRagePower( -fCost );

//                    pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE , null ,
//                        [CCharacterSyncBoard.DEFENSE_POWER_DELTA, fCost] ));
//                    pFightCalc.battleEntity.calcDefensePower( -fCost );

                    CSkillDebugLog.logTraceMsg( "受身消耗怒气 ：" + fCost )
                }
            }
        }

        return bRet && m_bQuickStand || bRet && !bBanNormalDodge;
    }

    private var m_delayDog : CTimeDog;

    public function update( delta : Number ) : void {
        if ( m_delayDog && m_delayDog.running ) {
            m_delayDog.update( delta );
        }
    }

    public function get quickStand() : Boolean {
        return m_bQuickStand;
    }

    private function get pLevelMediator() : CLevelMediator {
        return owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        // 闪避状态不可以主动移动
        this.setMovable( false );
        // 闪避状态不可转身
        this.setDirectionPermit( false );

        // 判定是翻滚还是受身
        // 空中受身强切至跳跃下落动作
        // 地面受身和翻滚都是翻滚动作

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        var bOnGround : Boolean = true;

        if ( pStateBoard ) {
            bOnGround = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
            pStateBoard.resetValue( CCharacterStateBoard.LYING );
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
        }

        var theFightCalc : CFightCalc = this.fightCalc;
        if ( theFightCalc ) {
            var fDodgCD : Number = 0.0;
            var pProperty : CCharacterProperty = this.owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
            if ( quickStand ) {
                if ( pProperty ) fDodgCD = pProperty.quickStandCD / 1000 + 1.5;
                theFightCalc.fightCDCalc.addCommoneCD( CSkillDataBase.SKILL_ID_QUICKSTAND_SIM, fDodgCD );
                _playQuickSFx();
            } else {
                if ( pProperty )
                    fDodgCD = pProperty.rollCD / 1000 + 1.5;
                theFightCalc.fightCDCalc.addCommoneCD( CSkillDataBase.SKILL_ID_DODGE_SIM, fDodgCD );
            }

            var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if ( pFightTriggle )
                pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, [ CCharacterSyncBoard.SKILL_CD_LIST ] ) );
        }

        if ( bOnGround ) {
            this.evalERoll( event );
        } else {
            this.evalQuickStand( event );
        }
    }

    protected function evalERoll( event : CStateEvent = null ) : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        var pAnimation : IAnimation = this.animation;
        var pMovement : CMovement = this.movement;
        var pEventMediator : CEventMediator = this.eventMediator;
        var pInput : CCharacterInput = this.input;


        if ( pAnimation ) {
            pAnimation.playAnimation( CAnimationStateConstants.E_ROLL, true ); // 强切
            this.subscribeAnimationEnd( _onERollAnimationEnd );
        }


        // FIXME: 这里根据输入方向产生位移，当前没有具体的移动参数，所以只是测试用例
        if ( pMovement && pStateBoard ) {
            var pDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );

            if ( pInput && pInput.normalizeWheel.x != 0 ) {
//                pDir.x = pInput.normalizeWheel.x;
                pDir.x = pInput.normalizeWheel.x < 0 ? -1 : 1;
            } else {
                if ( m_bLying ) { // 受身往身后
                    pDir.x *= -1;
                } else { // 翻滚往前
                    // NOOP.
                }
            }

            pMovement.direction = new Point( pDir.x, 0 );

            this._handleMovement();
            m_bERoll = true;
        }

        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.DODGE_BEGIN ) );
        }
    }

    protected function evalQuickStand( event : CStateEvent ) : void {
//        var pMovement : CMovement = this.movement;
        var pEventMediator : CEventMediator = this.eventMediator;
        var pAnimation : IAnimation = this.animation;

        if ( pAnimation ) {
            pAnimation.playAnimation( CAnimationStateConstants.JUMP_INAIR, true );
            pAnimation.lastFrameMode = true;

            /*if ( !m_delayDog )
                m_delayDog = new CTimeDog( _delayLandEnd );

            var pCharProp : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
            var stopTime : Number = pCharProp.quickStandStopTime / 1000;
            if ( stopTime != 0.0 ) {
                _stopMove();
                m_delayDog.start( stopTime );
            } else {
                _delayLandEnd();
            }*/

            var pCharProp : CCharacterProperty = owner.getComponentByClass( CCharacterProperty  , true ) as CCharacterProperty;
            var baseAnimation : CBaseAnimationDisplay = pAnimation as CBaseAnimationDisplay;
            pAnimation.setCharacterGravityAcc(  baseAnimation.getConvertedBaseGravity(pCharProp.quickStandGravity) );
//             end by on ground.
            if ( pEventMediator ) {
                pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround, false, 0, true );
            }
        }
    }

    private function _stopMove() : void {
        var pMovement : CMovement = m_pOwner.getComponentByClass( CMovement, true ) as CMovement;
        if ( pMovement ) {
            pMovement.clearAllMotionActions();
            pMovement.direction.setTo( 0, 0 );
        }


        var pAnimation : IAnimation = m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation ) {
            pAnimation.setCharacterGravityAcc( 0 );
            pAnimation.modelDisplay.velocity.x = 0;
            pAnimation.modelDisplay.velocity.y = 0;
            pAnimation.modelDisplay.velocity.z = 0;
        }
    }

    private function _delayLandEnd() : void {
        if( m_delayDog )
                m_delayDog.stop();
        var pAnimation : IAnimation = this.animation;
        var pEventMediator : CEventMediator = this.eventMediator;

        if ( pAnimation ) {
            var pCharProp : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
            var baseAnimation : CBaseAnimationDisplay = pAnimation as CBaseAnimationDisplay;
            pAnimation.setCharacterGravityAcc( baseAnimation.getConvertedBaseGravity( pCharProp.quickStandGravity ) );
            // end by on ground.
            if ( pEventMediator ) {
                pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround, false, 0, true );
            }
        }
    }

    private function _playQuickSFx() : void {
        var pCharacterProp : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        pFxMediator.playComhitEffects( pCharacterProp.quickStandFx );
    }

    private function _onGround( event : Event ) : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard && pStateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) &&
                pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
            var pEventMediator : CEventMediator = this.eventMediator;
            if ( pEventMediator ) {
                pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );
            }

            var pAnimation : IAnimation = this.animation;
            if ( pAnimation ) {
                pAnimation.lastFrameMode = false;
                evalERoll( null );
            }
//            _onERollAnimationEnd();
        }
    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        // 等待动作结束
        var bForceExit : Boolean;
        if( event.argList.length > 2 )
                bForceExit = event.argList[ 2 ];

        var pEventMediator : CEventMediator = this.eventMediator;
        if( bForceExit ){
            if ( pEventMediator ) {
                pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );
            }
            _onERollAnimationEnd();
        }
        else if ( this.animationEndCallCount > 0 ) {
            this.subscribeAnimationEnd( _onERollAnimationEnd, event.argList[ 0 ], event.from, event.to );
            return false;
        }

        this.m_bLying = false;
        this.m_bERoll = false;

        this.makeStop();

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.lastFrameMode = false;
            pAnimation.resetCharacterGravityAcc();
        }

        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.DODGE_END ) );
//            pEventMediator.dispatchEvent( new Event( CCharacterEvent.STOP_MOVE, false, false ) );
        }

        var pSimulatorSkill : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
        if ( pSimulatorSkill )
            pSimulatorSkill.clearIngnoreConditions();

        var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard , true ) as CCharacterSyncBoard;
        if( pSyncBoard ) {
            pSyncBoard.resetValue( CCharacterSyncBoard.SYNC_STATE );
            pSyncBoard.resetValue( CCharacterSyncBoard.SYNC_SUB_STATES );
        }
        return true;
    }

    private function _handleMovement() : void {
        var pMovement : CMovement = this.movement;
        if ( pMovement )
            pMovement.speedFactor *= VELOCITY_FACTOR;
    }

    private function _resumeMovement() : void {
        var pMovement : CMovement = this.movement;
        if ( pMovement )
            pMovement.speedFactor /= VELOCITY_FACTOR;
    }

    final private function _onERollAnimationEnd( sEventName : String = null, sFrom : String = null, sTo : String = null ) : void {
        this.makeStop();
        if ( m_bERoll )
            this._resumeMovement();

//        var pStateBoard : CCharacterStateBoard = this.stateBoard;
//
//        if ( pStateBoard ) {
//            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_ATTACK );
//            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_CATCH );
//        }

        if ( sEventName && sFrom && sTo ) {
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_COMPLETE, sFrom, sTo, [ this.quickStand ] ) );
        } else {
            fsm.on( CCharacterActionStateConstants.EVENT_POP, quickStand );
        }
    }

}
}
