//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/7.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Framework.CCharacter;
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.table.ActionSeq;
import kof.table.ActionSeq.EActionSeqType;
import kof.table.ActionSeq.EType;
import kof.table.Hit;
import kof.table.Skill;

public class CSkillActionsPlayer implements IUpdatable {

    public function CSkillActionsPlayer( skillCaster : CSkillCaster ) {
        m_pSkillComUty = skillCaster.pComUtility;
        m_animationendCB = skillCaster.skillAnimationEndCB;
        this.m_animation = m_pSkillComUty.cAnimation;
    }

    public function dispose() : void {
        if ( m_pSkillComUty.owner ) {
            var pEventMediator : CEventMediator = m_pSkillComUty.owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateValueUpdated );
            }
        }

        m_fTickTime = NaN;
        m_sCurrentAnimation = "";
        m_actionInfo = null;
        m_skillActionPlayer.dispose();
        m_skillID = 0;
    }

    public function init( skillInfo : Skill ) : void {
        m_skillID = skillInfo.ID;
        m_ActionFlag = skillInfo.ActionFlag;
        if ( !m_actionInfo ) {
            var pSkillInfoRes : ISkillInfoRes = m_pSkillComUty.owner.getComponentByClass( ISkillInfoRes, true ) as ISkillInfoRes;                //CSkillCaster.skillDB.getActionDataByInfo( skillInfo );
            m_actionInfo = pSkillInfoRes.getSkillActionsByActionFlag( skillInfo.ActionFlag );
        }
        m_skillActionPlayer = new CSkillAnimationController();

        m_skillActionPlayer.owner = m_pSkillComUty.owner;

        m_skillActionPlayer.pAnimation = m_animation;

        m_fTickTime = 0.0;
    }

    private function _onStateValueUpdated( event : Event ) : void {
        if ( m_actionInfo && m_actionInfo.Type == EActionSeqType.JUMP ) {
            if ( m_pSkillComUty.stateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) &&
                    m_pSkillComUty.stateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                m_bOnGroundEnd = true;
            }

            if ( m_pSkillComUty.stateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) && !m_pSkillComUty.stateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                m_boInAirFlag = true;
            }
        }
    }

    public function reset() : Boolean {
        if ( m_pSkillComUty.owner ) {
            var pEventMediator : CEventMediator = m_pSkillComUty.owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateValueUpdated );
            }
        }
        m_animation.animationOffsetEnabled = false;
        m_animation.boSkillPlaying = false;
        m_fTickTime = 0.0;
        m_sCurrentAnimation = "";
        m_currentAnimationIndex = 0.0;
        m_nextAnimationTime = 0.0;
        m_curAnimationDuarationTime = 0.0;
        m_boEnd = false;
        m_skillActionPlayer.reset();
        m_bOnGroundEnd = false;
        m_boInAirFlag = false;
        m_boUpdateInitial = false;
        return true;
    }

    private function onUpdateInitial() : void {
        if ( m_pSkillComUty.owner ) {
            var pEventMediator : CEventMediator = m_pSkillComUty.owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
            if ( pEventMediator ) {
                if ( m_actionInfo && m_actionInfo.Type == EActionSeqType.JUMP ) {
                    pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateValueUpdated, false, 0, true );
                }
            }
        }

        m_boUpdateInitial = true;
    }

    public function update( delta : Number ) : void {
        if ( isNaN( m_fTickTime ) )
            return;

        if ( !m_boUpdateInitial ) {
            onUpdateInitial();
        }

        m_fTickTime = m_fTickTime + delta;

        if ( m_boEnd )
            return;
        if ( m_skillActionPlayer )
            m_skillActionPlayer.update( delta );

        if ( null != m_actionInfo ) {
            m_sCurrentAnimation = getAnimationNameByIndex( m_currentAnimationIndex );
        } else Foundation.Log.logTraceMsg( "skill has no action seq , pls check the action seq config" );

        if ( m_sCurrentAnimation ) {
            var nextDurationTime : Number;
            var pAnimation : IAnimation = m_animation;
            if( pAnimation == null ){
                CSkillDebugLog.logErrorMsg("动作还没准备好或已经销毁，不能播放技能动作：" + m_sCurrentAnimation );
                return;
            }
            if ( m_fTickTime >= m_nextAnimationTime || 0 == m_currentAnimationIndex ) {
                nextDurationTime = getAnimationTimeByIndex( m_currentAnimationIndex );
                m_curAnimationDuarationTime = m_animation.getAnimationTime( m_sCurrentAnimation.toUpperCase() );

                //play animation
                if ( nextDurationTime == 0.0 )
                    nextDurationTime = m_curAnimationDuarationTime;

                m_nextAnimationTime = m_nextAnimationTime + nextDurationTime;
                m_currentAnimationMode = getAnimationModeByIndex( m_currentAnimationIndex );
                m_currentAnimationTime = nextDurationTime;

                // 打开位移(跳跃技能动作除外)
                m_animation.animationOffsetEnabled = m_actionInfo.Type != EActionSeqType.JUMP && Boolean( m_actionInfo.AnimationOffsetFlag[ m_currentAnimationIndex ] );
                //设置底层character的tag
                m_pSkillComUty.cAnimation.setCurrentAnimationTag( m_ActionFlag, String( m_currentAnimationIndex ) );
                Foundation.Log.logTraceMsg( "Skill Play animation at time :" + m_fTickTime + " Animation name : " + m_sCurrentAnimation );
                m_skillActionPlayer.castControllerEntity( m_sCurrentAnimation, m_currentAnimationMode, nextDurationTime );
                m_pSkillComUty.pEventMediator.dispatchEvent( new Event( CCharacterEvent.SKILL_ANIMATION_TAG_CHG ) );

                if ( m_currentAnimationIndex != 0 )
                    m_pSkillComUty.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.ANIMATION_ACTION_END, null, null ) );

                m_currentAnimationIndex++;
                if ( m_currentAnimationIndex == AnimationsLength ) {
                    m_animation.boSkillPlaying = false;
                } else {
                    m_animation.boSkillPlaying = true;
                }
            }
        } else {
            if ( m_actionInfo && m_actionInfo.Type == EActionSeqType.JUMP ) {
                m_boEnd = false;
                if ( m_bOnGroundEnd || m_boInAirFlag && m_pSkillComUty.stateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                    m_boEnd = true;
                }
            } else if ( !m_boEnd && m_nextAnimationTime <= m_fTickTime ) {
                m_boEnd = true;
            }

            if ( m_boEnd ) {
                var lastSkillID : int = m_pSkillComUty.skillCaster.skillID;
                m_skillActionPlayer.reset();
                CONFIG::debug {
                    if ( null != m_actionInfo )
                        Foundation.Log.logTraceMsg( "**@CSkillActionsPlayer 动作串联结束，action** ID ：" + m_actionInfo.skillName +
                                "  name : " + getAnimationNameByIndex( m_currentAnimationIndex - 1 ) + " at Time : " + m_fTickTime );
                }
                //在释放技能前记录数值状态
                m_pSkillComUty.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null,
                        CCharacterSyncBoard.SYNC_SKILL_PROPERTY ) );

                m_pSkillComUty.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.ANIMATION_ACTION_END, null, null ) );

                m_pSkillComUty.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_READY_END, null, null ) );

                m_pSkillComUty.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_END, null, [ lastSkillID ] ) );

                var pModelDisplay : CCharacter;
                pModelDisplay = m_animation.modelDisplay;
                if (pModelDisplay && pModelDisplay.currentAnimationClip.m_bLoop ) {
                    m_animation.playAnimation( CAnimationStateConstants.IDLE, true, true );
                }

                if ( m_animationendCB )
                    m_animationendCB.apply();
//
            }
        }
    }

    public function lastUpdate( delta : Number ) : void {
    }

    final public function getAnimationNameByIndex( index : int ) : String {
        return m_actionInfo.AnimationName != null ? m_actionInfo.AnimationName[ index ] : "";
    }

    final public function get AnimationsLength() : int {
        return m_actionInfo.AnimationName.length;
    }

    final public function getAnimationTimeByIndex( index : int ) : Number {
        return m_actionInfo.AnimationTime != null ? m_actionInfo.AnimationTime[ index ] * CSkillDataBase.TIME_IN_ONEFRAME : 0.0;
    }

    final public function getAnimationModeByIndex( index : int ) : int {
        return m_actionInfo.AnimationMode != null ? m_actionInfo.AnimationMode[ index ] : 0;
    }

    public function stopAnimationImmiately() : void {
        m_cancel = true;

        if ( m_animationendCB )
            m_animationendCB.apply();
    }

    final public function get tickTime() : Number {
        return m_fTickTime;
    }

    final public function get currentAnimation() : String {
        return m_sCurrentAnimation;
    }

    final public function set currentAnimation( value : String ) : void {
        this.m_sCurrentAnimation = value;
    }

    final public function get boEnd() : Boolean {
        return m_boEnd;
    }

    final public function get animationMode() : int {
        return m_currentAnimationMode;
    }

    public function get currentAnimationIndex() : int {
        return m_currentAnimationIndex;
    }

    public function set currentAnimationIndex( value : int ) : void {
        m_currentAnimationIndex = value;
    }

    public function get nextAnimationTime() : Number {
        return m_nextAnimationTime;
    }

    public function get currentAnimationMode() : int {
        return m_currentAnimationMode;
    }

    public function get curAnimationDuarationTime() : Number {
        return m_curAnimationDuarationTime;
    }

    public function get currentAnimationTime() : Number {
        return m_currentAnimationTime;
    }

    private var m_skillID : int;
    private var m_ActionFlag : String;
    private var m_actionInfo : ActionSeq = null;
    private var m_fTickTime : Number = 0.0;
    private var m_cancel : Boolean;
    private var m_boEnd : Boolean;
    private var m_animation : IAnimation = null;
    private var m_sCurrentAnimation : String;
    private var m_currentAnimationMode : int;
    private var m_currentAnimationIndex : int = 0;
    private var m_currentAnimationTime : Number = 0.0;
    private var m_curAnimationDuarationTime : Number = 0.0;
    private var m_nextAnimationTime : Number = 0.0;
    private var m_animationendCB : Function = null;
    private var m_boSpeedUp : Boolean;
    private var m_boInPause : Boolean;
    private var m_iCurrentHit : Hit;
    private var m_pSkillComUty : CComponentUtility;//CSkillCasterContext;
    private var m_bOnGroundEnd : Boolean;
    private var m_boUpdateInitial : Boolean;
    private var m_boInAirFlag : Boolean;

    private var m_skillActionPlayer : CSkillAnimationController;

}

}

