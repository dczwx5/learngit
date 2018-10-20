//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Math.CVector3;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CSkillList;
import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.ESkillSkipType;
import kof.game.character.fight.skill.ISkillInfoRes;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillEvaluator;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skillcalc.CPropertyRecovery;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fx.CFXMediator;
import kof.game.character.movement.CMovement;
import kof.table.ActionSeq;
import kof.table.ActionSeq.EActionSeqType;
import kof.table.Skill;

/**
 * 角色攻击状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterAttackState extends CCharacterState {

    private var m_bAnimationOffsetEnabled : Boolean;

    /** Creates a new CCharacterAttackState */
    public function CCharacterAttackState() {
        super( CCharacterActionStateConstants.ATTACK );
    }

    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        var pSkillList : CSkillList = owner.getComponentByClass( CSkillList, true ) as CSkillList;
        if ( !pSkillList )
            return false;
        var skillId : int = event.argList[ 1 ];

        var theSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        var theSkillEvaluator : CSkillEvaluator = theSkillCaster.skillEvaluator;

        var canCancelSkill : Boolean;
        //主动技打断逻辑

        if ( theSkillCaster.skillID != 0 && CSkillUtil.isActiveSkill( skillId, CCharacterDataDescriptor.getSimpleDes( owner.data ) ) ) {
            canCancelSkill = theSkillEvaluator.evaluateSkillCancelByID( theSkillCaster.skillID );
        }
        else
            canCancelSkill = true;

        var ret : Boolean = canCancelSkill;

        CSkillDebugLog.logTraceMsg( "CCharacterAttackState : Tty To ATTACK With SkillID : " + skillId );
        if ( skillId != 0 ) {
            ret = ret && theSkillEvaluator.evaluateSkillStateByID( skillId );
            ret = ret && theSkillEvaluator.evaluateSkillFightCalcByID( skillId, true );
            ret = ret && theSkillEvaluator.evaluateSkillCDByID( skillId );

            if ( !ret ) {
                var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pFightTriggle ) {
                    pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_FAILED, owner ) );
                }

                CSkillDebugLog.logTraceMsg( "CCharacterAttackState : 不能进入ATTACK With SkillID : " + skillId );
//                var aiComponet : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
//                CAILog.warningMsg( "CCharacterAttackState : 不能进入ATTACK With SkillID : " + skillId, aiComponet.objId );
            }

            return ret;
        }

        return false;
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        // 进入攻击状态都应该是由技能释放输入，为主动状态
        // 攻击状态应当附带相关参数
        var nSkillID : int = event.argList[ 1 ];

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            m_bAnimationOffsetEnabled = pAnimation.animationOffsetEnabled;
        }

        var pFightCal : CFightCalc = this.fightCalc;
        if ( pFightCal )
            pFightCal.recovery.resetRecoveryByType( CPropertyRecovery.RECOVERY_TYPE_AP_IN_SKILL );

        if ( nSkillID != 0 ) {
            this.spellSkill( event, nSkillID );
        }
    }

    private function skillAnimationEnd( evt : CFightTriggleEvent ) : void {

        var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTriggle ) {
            pFightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, skillAnimationEnd );
        }

        _onCurrentAnimationEnd();

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.animationOffsetEnabled = m_bAnimationOffsetEnabled;
        }
        skillCaster.skillSpeed = 1.0;
    }

    protected function isJumpSkill( nSkillID : int ) : Boolean {
        var bJump : Boolean = false;
        var sActionFlag : String;
        var pDatabase : IDatabase = owner.getComponentByClass( IDatabase, true ) as IDatabase;
        if ( pDatabase ) {
            var pSkillTable : IDataTable = pDatabase.getTable( KOFTableConstants.SKILL );
            if ( pSkillTable ) {
                var pSkillData : Skill = pSkillTable.findByPrimaryKey( nSkillID );
                if ( pSkillData )
                    sActionFlag = pSkillData.ActionFlag;
            }

            if ( sActionFlag ) {
                var pSkillInfoRes : ISkillInfoRes = owner.getComponentByClass( ISkillInfoRes, true ) as ISkillInfoRes;
                if ( pSkillInfoRes ) {
                    var pActionSeq : ActionSeq = pSkillInfoRes.getSkillActionsByActionFlag( sActionFlag );
                    if ( pActionSeq && pActionSeq.Type == EActionSeqType.JUMP )
                        bJump = true;
                }
            }
        }

        return bJump;
    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        // 结束攻击状态
        // 如果动作没结束或是强切限制条件未达成，等待转换结束

        if ( isJumpSkill( skillCaster.skillID ) ) {
            this.makeStop();

            var pMovement : CMovement = this.movement;
            if ( pMovement ) {
                pMovement.speedFactor = 1.0;
            }
            dirSync = false;
        }

        var curSkillId : int = skillCaster.skillID;
        var toState : String = event.to;
        if ( toState == CCharacterActionStateConstants.BE_CATCH
                || toState == CCharacterActionStateConstants.HURT
                || toState == CCharacterActionStateConstants.KNOCK_UP ) {

            var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, false ) as CCharacterFightTriggle;
            if ( pFightTriggle )
                pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_BE_INTERRUPTED, null, [ curSkillId, toState ] ) );
        }

        skillCaster.cancelSkill();

        // clear all catching infos.
        (skillCaster.getComponent( CSkillCatcher ) as CSkillCatcher).removeAll();

        if ( this.animationEndCallCount > 0 ) { // need to wait animation end.
            this.subscribeAnimationEnd( _onCurrentAnimationEnd, event.argList[ 0 ], event.from, event.to );
            return false;
        }

        // Resets the variables.
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_ATTACK, false );
        }

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.animationOffsetEnabled = m_bAnimationOffsetEnabled;
        }

        //reset continue hit count when exit
        var fightCalc : CFightCalc = this.fightCalc;
        if ( fightCalc ) {
            fightCalc.otherFightCalc.boForceCancel = false;
        }
        ;

        if ( pAnimation )
            pAnimation.resetCharacterGravityAcc();

        var pSimulatorSkill : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
        if ( pSimulatorSkill )
            pSimulatorSkill.clearIngnoreConditions();

        return true;
    }

    override protected virtual function onAfterState( event : CStateEvent ) : void {
        if ( !isRunning )
            return;

        var nSkillID : int = event.argList[ 1 ];

        if ( nSkillID != 0 ) {
            this.spellSkill( event, nSkillID );
        }
    }

    protected function spellSkill( event : CStateEvent, nSkillID : int ) : void {
        var pFightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pFightTriggle.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, skillAnimationEnd );

        //在释放技能前记录数值状态
        pFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTriggle ) {
            pFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null,
                    CCharacterSyncBoard.SYNC_SKILL_PROPERTY ) );
        }

        skillCaster.spellSkill( nSkillID );

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        var pMovement : CMovement = this.movement;
        this.setDirectionPermit( false );

        if ( isJumpSkill( skillCaster.skillID ) ) {
            this.setMovable( true );
            if ( pNetworkMediator )
                pNetworkMediator.bForceBanMoveSchedule = true;

            dirSync = true;

            if ( pStateBoard )
                pStateBoard.setValue( CCharacterStateBoard.IN_ATTACK, true );
            var pInput : CCharacterInput = this.input;
            if ( pInput ) {
                pInput.makeWheelDirty();
            }

            if ( pMovement ) {
                pMovement.speedFactor = .8;
            }
        } else {
            this.setMovable( false );

            this.makeStop();

            if ( pMovement ) {
                pMovement.speedFactor = 1.0;
            }

            if ( pStateBoard ) {
                pStateBoard.setValue( CCharacterStateBoard.IN_ATTACK, true );
            }
        }
    }

    final private function _onCurrentAnimationEnd( sEventName : String = null, sFrom : String = null, sTo : String = null ) : void {
        if ( sEventName && sFrom && sTo ) {
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_COMPLETE, sFrom, sTo ) );
        } else {
            fsm.on( CCharacterActionStateConstants.EVENT_ATTACK_END );
        }
    }


}
}
