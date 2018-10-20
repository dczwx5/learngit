//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/18.
 * Time: 14:50
 */
package kof.game.character.ai {

import QFLib.AI.events.CAIEvent;
import QFLib.Foundation;

import flash.events.Event;
import flash.geom.Point;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.fsm.CFiniteStateMachine;
import kof.framework.fsm.CStateEvent;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CSkillList;
import kof.game.character.ai.CAIEvent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.actions.CSelectTargetAction;
import kof.game.character.ai.paramsTypeEnum.EFightStateType;
import kof.game.character.animation.IAnimation;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.movement.CNavigation;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.table.Hit;

public class CEventManager {
        private var m_aiComponent : CAIComponent = null;
        private var m_hitTable:CDataTable=null;
        private var m_delayFrames:int=0;
        private var m_delayFrameCount:int=0;
    //战斗状态重置脏标记
    private var _isDirtyInCatch:Boolean=false;
    private var _isDirtyBaTi:Boolean=false;
    private var _isDirtyGangTi:Boolean=false;
    private var _isDirtyWuDi:Boolean=false;

        public function CEventManager( aiComponent : CAIComponent ) {
            this.m_aiComponent = aiComponent;
        }
        //开启自动战斗
        private function _startAutoFight(e:kof.game.character.ai.CAIEvent):void{
            var handler:CAIHandler = e.target as CAIHandler;
            if(m_aiComponent&&!m_aiComponent.owner)return;
        }
        //取消自动战斗时，如果主控角色处于移动状态，则停止
        private function _stopAutoFight(e:kof.game.character.ai.CAIEvent):void{
            var handler:CAIHandler = e.target as CAIHandler;
            if(m_aiComponent&&!m_aiComponent.owner)return;
            var ishero:Boolean = handler.isHero(m_aiComponent.owner);
            if(ishero){
                m_aiComponent.resetAllState();
                var isMoving:Boolean = handler.getCharacterState( m_aiComponent.owner, CCharacterStateBoard.MOVING );
                if(isMoving){
                    var pStateBoard : CCharacterStateBoard = m_aiComponent.owner.getComponentByClass( CCharacterStateBoard ,true) as CCharacterStateBoard;
                    if ( pStateBoard ) {
                        if(!m_pAIHandler.keyDown){
                            return;
                        }
                        m_aiComponent.isMovingPassWay = false;
                        handler.clearMoveFinishCallBackFunction(m_aiComponent.owner);
                        var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                        var xx:int = dir.x>0?50:-50;
                        handler.moveTo(m_aiComponent.owner,0,0,new Point(m_aiComponent.owner.transform.x+xx,m_aiComponent.owner.transform.y),null,"");
                    }
                }
            }
        }

        public function initHitTable():void{
        var pDatabaseSystem : CDatabaseSystem = m_pAIHandler.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        m_hitTable = pDatabaseSystem.getTable( KOFTableConstants.HIT ) as CDataTable;

            var actionFsm : CFiniteStateMachine;
            if(_pStateMachine){
                actionFsm = _pStateMachine.actionFSM;
                if( actionFsm ){
                    actionFsm.addEventListener( CStateEvent.ENTER, _judgeAIChangeOrQEChange );
                }
            }

            m_pAIHandler.addEventListener(kof.game.character.ai.CAIEvent.STOP_AUTO_FIGHT,_stopAutoFight);
            m_pAIHandler.addEventListener(kof.game.character.ai.CAIEvent.STOP_AUTO_FIGHT,_startAutoFight);
    }

    private function _judgeAIChangeOrQEChange(e:CStateEvent):void{
        if( e.to != CCharacterActionStateConstants.IDLE ){
            return;
        }
        if(!m_aiComponent.isChangeEnable||!m_aiComponent.enabled){
            return;
        }
        m_aiComponent.isChangeEnable = false;
    }


        public final function addOwnEventListeners( e : CStateEvent = null ) : void {
            _pEventMediator.addEventListener( CCharacterEvent.DODGE_END, _dodgeComplete );//闪避结束
            _pEventMediator.addEventListener( CCharacterEvent.DODGE_BEGIN, _dogeBegin );//闪避开始
            _pEventMediator.addEventListener( CCharacterEvent.DODGE_FAILED, _dogeFail );//闪避失败
            _pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _stateEventChange );//状态改变

            _pCharacterMediator.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _skillComplete );//技能结束
            _pCharacterMediator.addEventListener( CFightTriggleEvent.SPELL_SKILL_FAILED, _skillFailed );//技能失败
            _pCharacterMediator.addEventListener( CFightTriggleEvent.BEING_HITTED, _begin_hitted );//被攻击
            _pCharacterMediator.addEventListener( CFightTriggleEvent.BEING_HURT, _begin_hitted );//被击伤
            _pCharacterMediator.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _skillBegin );//技能释放开始
            _pCharacterMediator.addEventListener( CFightTriggleEvent.SKILL_NOT_EXIST, _skillNotExist );//技能不存在
            _pCharacterMediator.addEventListener( CFightTriggleEvent.HIT_TARGET, _isHitTarget );//击中目标
            _pCharacterMediator.addEventListener( CFightTriggleEvent.HURT_TARGET, _isHurtTarget );//击伤目标
            _pCharacterMediator.addEventListener( CFightTriggleEvent.SKILL_CHAIN_PASS_EVALUATION, _onKeySkillCombo );//多段技能连击
            _pCharacterMediator.addEventListener( CFightTriggleEvent.CATCH_EFFECT_SUCCEED,_catchSuccess);//抓取成功
        }

        public final function addAttackableEventListener() : void {
            if ( !_pAttackableCharacter ) {
                var attackableObj : CGameObject = null;
                if ( m_aiComponent.currentAttackable ) {
                    attackableObj = m_aiComponent.currentAttackable;
                }
                if ( attackableObj ) {
                    _pAttackableCharacter = attackableObj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                    _pAttackableEventMediator = attackableObj.getComponentByClass( CEventMediator, true ) as CEventMediator;
                }
            }
            if ( _pAttackableCharacter ) {
                _pAttackableEventMediator.addEventListener( CCharacterEvent.REMOVED, removeAttackableEvent );
                _pAttackableCharacter.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _attackTargetSkillBegin );
                _pAttackableCharacter.addEventListener( CFightTriggleEvent.BEING_HITTED, _attackTarget_begin_hitted );
                _pAttackableCharacter.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _attackTargetSkillComplete );
                _pAttackableCharacter.addEventListener( CFightTriggleEvent.SPELL_SKILL_FAILED, _attackTargetSkillFailed );
                _pAttackableCharacter.addEventListener( CFightTriggleEvent.BEING_HURT, _attackTargetSkillFailed );
            }
        }

        public final function removeEventListeners() : void {
            if ( _pEventMediator ) {
                _pEventMediator.removeEventListener( CCharacterEvent.DODGE_END, _dodgeComplete );//闪避结束
                _pEventMediator.removeEventListener( CCharacterEvent.DODGE_BEGIN, _dogeBegin );//闪避开始
                _pEventMediator.removeEventListener( CCharacterEvent.DODGE_FAILED, _dogeFail );//闪避失败
                _pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _stateEventChange );//状态改变
            }

            if ( _pCharacterMediator ) {
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _skillComplete );//技能结束
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.SPELL_SKILL_FAILED, _skillFailed );//技能失败
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.BEING_HITTED, _begin_hitted );//被攻击
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.BEING_HURT, _begin_hitted );//被击伤
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _skillBegin );//技能释放开始
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.SKILL_NOT_EXIST, _skillNotExist );//技能不存在
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.HIT_TARGET, _isHitTarget );//击中目标
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.SKILL_CHAIN_PASS_EVALUATION, _onKeySkillCombo );//普攻类型的连击
                _pCharacterMediator.removeEventListener( CFightTriggleEvent.CATCH_EFFECT_SUCCEED,_catchSuccess);
            }

            if ( _pAttackableCharacter ) {
                _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _attackTargetSkillBegin );
                _pAttackableCharacter.removeEventListener( CFightTriggleEvent.BEING_HITTED, _attackTarget_begin_hitted );
                _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _attackTargetSkillComplete );
                _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_FAILED, _attackTargetSkillFailed );
                _pAttackableCharacter.removeEventListener( CFightTriggleEvent.BEING_HURT, _attackTargetSkillFailed );//攻击者被击伤
            }
            if ( _pAttackableEventMediator ) {
                _pAttackableEventMediator.removeEventListener( CCharacterEvent.REMOVED, removeAttackableEvent );
            }
        }

        private function _removeAttackableEvent() : void {
            if ( _pAttackableEventMediator ) {
                _pAttackableEventMediator.removeEventListener( CCharacterEvent.REMOVED, removeAttackableEvent );
                _pAttackableEventMediator = null;
                removeAttackableEventListeners();
            }
        }

        public function removeAttackableEventListeners() : void {
            _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _attackTargetSkillBegin );
            _pAttackableCharacter.removeEventListener( CFightTriggleEvent.BEING_HITTED, _attackTarget_begin_hitted );
            _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _attackTargetSkillComplete );
            _pAttackableCharacter.removeEventListener( CFightTriggleEvent.SPELL_SKILL_FAILED, _attackTargetSkillFailed );
            _pAttackableCharacter.removeEventListener( CFightTriggleEvent.BEING_HURT, _attackTargetSkillFailed );//攻击者被击伤
            _pAttackableCharacter = null;
        }

        //--------------------------------------------
        //----------------状态改变---------------------
        //--------------------------------------------
        private function _stateEventChange( e : Event ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            var pStateBoard : CCharacterStateBoard = m_aiComponent.owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if(pStateBoard.isDirty(CCharacterStateBoard.IN_CATCH)&&pStateBoard.getValue(CCharacterStateBoard.IN_CATCH)){
                 _being_catched();
//                if(m_aiComponent.bCanResetState_PATI){
//                    _isDirtyInCatch=true;
//                }
            }
            if ( pStateBoard.isDirty( CCharacterStateBoard.PA_BODY ) && !pStateBoard.getValue( CCharacterStateBoard.PA_BODY ) ) {
                if ( m_aiComponent.bSetStateAlways_PATI || m_aiComponent.bCanResetState_PATI ) {
                    _isDirtyBaTi=true;
                }
            }
            if ( pStateBoard.isDirty( CCharacterStateBoard.CAN_BE_CATCH ) && pStateBoard.getValue( CCharacterStateBoard.CAN_BE_CATCH ) ) {
                if ( m_aiComponent.bSetStateAlways_GANGTI || m_aiComponent.bCanResetState_GANGTI ) {
                    _isDirtyGangTi=true;
                }
            }
            if ( pStateBoard.isDirty( CCharacterStateBoard.CAN_BE_ATTACK ) && pStateBoard.getValue( CCharacterStateBoard.CAN_BE_ATTACK ) ) {
                if ( m_aiComponent.bSetStateAlways_WUDI || m_aiComponent.bCanResetState_WUDI ) {
                    _isDirtyWuDi=true;
                }
            }

            if( pStateBoard.isDirty( CCharacterStateBoard.IN_HURTING ) && !pStateBoard.getValue( CCharacterStateBoard.IN_HURTING)){
                _resetAttackedCalDurationTime();
            }

        }

        //------------------------------------------------------------
        //-------------------闪避-------------------------------------
        //------------------------------------------------------------
        private function _dogeFail( e : Event ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.useSkillEnd = false;
            m_aiComponent.excutingSkill = true;
            m_aiComponent.isBeAttacked = false;
//            m_aiComponent.resetAllState();
            CAILog.logExistUnSatisfyInfo("Dodge" ," 闪避失败", m_aiComponent.objId );
        }

        private function _dogeBegin( e : Event ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.useSkillEnd = false;
            m_aiComponent.excutingSkill = true;
            m_aiComponent.isBeAttacked = false;
            CAILog.logEnterSubNodeInfo("Dodge" , "闪避开始" , m_aiComponent.objId );
        }

        //闪避完成
        private function _dodgeComplete( e : Event ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.resetAllState();
            CAILog.logExistInfo("Dodge", "闪避完成", m_aiComponent.objId );
        }

        //--------------------------------------------------------------------------
        //----------------------自身技能执行状态相关-----------------------------------
        //--------------------------------------------------------------------------
        private function _skillComplete( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;

            var len : int = m_aiComponent.piSkillIndexVec.length;
            if(m_aiComponent.isOverrideAction || (m_aiComponent.iSkillCount ) > len ){
                m_aiComponent.useSkillEnd = true;
                m_aiComponent.excutingSkill = false;
                resetCastComboSkillCountTime();
            }
            m_aiComponent.bSkillCompleteBeforeSkillFailed = true;
            CAILog.logExistInfo("Skill" , e.parmList[0] + "结束", m_aiComponent.objId );
            //当前执行技能的索引，可能在还没有执行，尚在等待，将要执行
            var skillLen:int = m_aiComponent.piSkillIndexVec.length;
            if(skillLen>1){
                if(m_aiComponent.iSkillCount<skillLen||excutedSkillNu<skillLen){//已经执行的技能数，没有执行到最后一个
                    if(!m_aiComponent.bSkillFailed){//没有失败的技能
                        if(m_aiComponent.bSkillHit){//并且命中，那么后面的技能还会执行
//                        trace("continue");
                            return;
                        }
                    }
                }
            }
            return;

            if ( m_aiComponent.iSkillCount>0&&m_aiComponent.notHitButAttackVec.length>=m_aiComponent.iSkillCount&&!m_aiComponent.bSkillHit) { //没有命中也执行后续连招
                if(!m_aiComponent.notHitButAttackVec[m_aiComponent.iSkillCount-1]){ //
                    return;
                }
                var curSkillIndex:Number=m_aiComponent.iSkillIndex;
                    //var len : int = m_aiComponent.piSkillIndexVec.length;
                    m_aiComponent.iSkillCount++;
                    if ( m_aiComponent.iSkillCount > m_aiComponent.piSkillIndexVec.length ) {
                        m_aiComponent.iSkillCount = 0;
                        m_aiComponent.useSkillEnd = true;
                        m_aiComponent.excutingSkill = false;
                        m_aiComponent.bComboSkill = false;
                    }
                    if ( m_aiComponent.iSkillCount != 0 ) {
                        m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ m_aiComponent.iSkillCount - 1 ];
                        var skillId : int = (m_aiComponent.owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( m_aiComponent.iSkillIndex );
                        if(curSkillIndex==m_aiComponent.iSkillIndex){//如果将要执行的技能和上一个技能一样，则处于冷却中，所以要找一个不一样的
                            skillId = 0;
                        }
                        while ( skillId == 0 ) {
                            m_aiComponent.iSkillCount++;
                            if ( m_aiComponent.iSkillCount >= m_aiComponent.piSkillIndexVec.length ) {
                                m_aiComponent.iSkillCount = 0;
                                break;
                            }
                            m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ m_aiComponent.iSkillCount - 1 ];
                            skillId = (m_aiComponent.owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( m_aiComponent.iSkillIndex );
                            if(curSkillIndex==m_aiComponent.iSkillIndex){//如果将要执行的技能和上一个技能一样，则处于冷却中，所以要找一个不一样的
                                skillId = 0;
                            }
                        }
                        if ( skillId != 0 ) {
                            m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ m_aiComponent.iSkillCount - 1 ];
                            m_aiComponent.bSkillConsume = m_aiComponent.psSkillIndexConsumeVec[ m_aiComponent.iSkillCount - 1 ];
                            m_aiComponent.bCanComboSkill = true;
                            _castComboSkill();
                        }else{
                            m_aiComponent.iSkillCount = 0;
                            m_aiComponent.useSkillEnd = true;
                            m_aiComponent.excutingSkill = false;
                            m_aiComponent.bComboSkill = false;
                        }
                    }
            } else {
                m_aiComponent.useSkillEnd = true;
                m_aiComponent.excutingSkill = false;
//                trace("技能播放完毕!");
            }
        }

    private function _updateCalDurationAction( delta : Number ) : void{
        /**计算calculationDurationDamadge相关*/
            if ( m_aiComponent.calculationDuration != 0 ) {
                switch ( m_aiComponent.calculationType ) {
                    case "LifePercent":
                    {
                        m_aiComponent.calculationElapsedTime += delta;
                        var bool : Boolean = m_aiComponent.calculationElapsedTime - m_aiComponent.calculationDuration >= 0;
                        if ( bool ) {
                            if ( m_aiComponent.calculationValue != 0 ) {
                                var pFacadeProperty : ICharacterProperty = m_aiComponent.owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                                var curPercent : Number = (m_aiComponent.recordCurHP - pFacadeProperty.HP) / pFacadeProperty.MaxHP;
                                if ( curPercent > m_aiComponent.calculationValue ) {
                                   _doCalDurationRetSussed();
                                }
                                else {
                                   _doCalDruationRetFail();
                                }
                            }
                            else {
                                _doCalDurationRetSussed();
                            }
                        }
                        break;
                    }
                    case "BeAttackedTime":
                    {
                        m_aiComponent.calculationElapsedTime += delta;
                        if( m_aiComponent.calculationElapsedTime >= m_aiComponent.calculationDuration )
                        {
                            _doCalDurationRetSussed();
                        }
                        break;
                    }
                }
            }
    }

    private function _resetAttackedCalDurationTime() : void {
        if ( m_aiComponent.calculationDuration != 0 && m_aiComponent.calculationType == "BeAttackedTime" ) {
            _doCalDruationRetFail();
            m_aiComponent.calculationElapsedTime = 0;
        }
    }

    private function _doCalDurationRetSussed(): void {
       m_aiComponent.calculationResult = 2;
       m_aiComponent.calculationDuration = 0;
       m_aiComponent.calculationElapsedTime = 0;
       m_aiComponent.calculationType = "";
    }

    private function _doCalDruationRetFail() : void{
        m_aiComponent.calculationResult = 1;
        m_aiComponent.calculationDuration = 0;
        m_aiComponent.calculationElapsedTime = 0;
        m_aiComponent.calculationType = "";
    }

        private function _skillFailed( e : Event ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            CAILog.logExistUnSatisfyInfo(m_aiComponent.currentNodeIndex + "_Skill" ,"Index : " + m_aiComponent.iSkillIndex + " 释放失败", m_aiComponent.objId );
            excutedSkillNu++;
            if(m_aiComponent.iSkillCount>1){
                if(!m_aiComponent.bSkillCompleteBeforeSkillFailed){ //当执行第二个以上的技能发生失败，并且前一个技能没有结束，则说明前面的技能还在执行中
                    return;
                }
            }else{
                m_aiComponent.m_bNeedCoolDown = false;
                var currentNodeIndex : int =m_aiComponent.currentNodeIndex;
                m_aiComponent.coolTimeByNodeIndex( currentNodeIndex );
            }
            m_aiComponent.bSkillFailed=true;
            m_aiComponent.isExcutedNextSkill = true;
            skillBegined = true;
            m_aiComponent.useSkillEnd = true;
            m_aiComponent.excutingSkill = false;
            m_aiComponent.resetInFightingState();
            resetCastComboSkillCountTime();
        }

        private function _begin_hitted( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            if(m_aiComponent.bCanResetState_GANGTI||m_aiComponent.bCanResetState_WUDI || m_aiComponent.bCanResetState_PATI ){//这两种状态不用重置
                return;
            }
            m_aiComponent.aiObj.dispatchEvent(new QFLib.AI.events.CAIEvent(QFLib.AI.events.CAIEvent.OVERRIDE_ACTION,{tempIndex:0,prevIndex : m_aiComponent.currentNodeIndex}));
            m_aiComponent.resetAllState();
            m_aiComponent.isBeAttacked = true;
            m_aiComponent.isBackIngToMaster = false;

            if( m_aiComponent.selectTargetType == CSelectTargetAction.TYPE_BE_HURTED &&
                m_aiComponent.currentAttackable != null ){
                m_aiComponent.currentAttackable = null;
            }

            CAILog.logMsg( "接收到被攻击的事件，重置AI状态", m_aiComponent.objId , CAILog.enabledFailLog);
        }

        private function _being_catched() : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            if(m_aiComponent.bCanResetState_GANGTI||m_aiComponent.bCanResetState_WUDI ){//这两种状态不用重置
                return;
            }
            m_aiComponent.aiObj.dispatchEvent(new QFLib.AI.events.CAIEvent(QFLib.AI.events.CAIEvent.OVERRIDE_ACTION,{tempIndex:0 , prevIndex : m_aiComponent.currentNodeIndex}));
            m_aiComponent.resetAllState();
            m_aiComponent.isBeAttacked = true;
            m_aiComponent.isBackIngToMaster = false;

            if( m_aiComponent.selectTargetType == CSelectTargetAction.TYPE_BE_HURTED &&
                m_aiComponent.currentAttackable != null ){
                m_aiComponent.currentAttackable = null;
            }

            CAILog.logMsg( "接收到被攻击的事件，重置AI状态", m_aiComponent.objId , CAILog.enabledFailLog);
        }

        public var excutedSkillNu:int=0;//已经执行技能的个数（包括成功执行（技能开始事件）和释放失败（技能释放失败事件））
        public var skillBegined:Boolean=false;
        private function _skillBegin( e : CFightTriggleEvent = null ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            if(startSkillIndex==m_aiComponent.iSkillIndex&&!skillBegined)
            {
                skillBegined = true;
                m_aiComponent.iPreSkillIndex = m_aiComponent.iSkillIndex;
                _resetComboHitSignal();
                m_aiComponent.bSkillHit = false;
                m_delayFrames = 0;
                m_delayFrameCount = 0;
                _attackerStopTime = 0;
                m_aiComponent.bSkillCompleteBeforeSkillFailed=false;
                m_aiComponent.isExcutedNextSkill=true;
//                trace("执行个数（技能开始）:"+m_aiComponent.iSkillCount+",索引："+m_aiComponent.iSkillIndex);
                m_aiComponent.useSkillEnd = false;
                m_aiComponent.excutingSkill = true;
                m_aiComponent.isBeAttacked = false;
                m_aiComponent.bSkillExecuteSuccess = true;
                if ( m_aiComponent.resetMoveCallBakcFunc ) {
                    m_aiComponent.resetMoveCallBakcFunc.apply();
                    m_aiComponent.resetMoveCallBakcFunc = null;
                }
                excutedSkillNu++;

                if(m_aiComponent.bComboSkill)
                {
                    _elapsedSkillTime = 0.0;
                    _filterNextSkill(true);
                }
            }

            CAILog.logEnterSubNodeInfo("Skill" , e.parmList[0] + "开始" , m_aiComponent.objId );
        }

        private function _skillNotExist( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.resetAllState();
            CAILog.logExistUnSatisfyInfo("Skill" , e.parmList[0] + "不存在" , m_aiComponent.objId );
        }
        private var _skillIndexWhenRecordSkillHit:int=0;
        private var _isHitedOnece:Boolean;
        private var _attackerStopTime:Number=0;
        private function _isHitTarget( e : CFightTriggleEvent ) : void {

            var paramList : Array = e.parmList;
            var bDetectedHit : Boolean = (paramList && paramList.length >= 3) ? paramList[2] : false;
            if( bDetectedHit )
               return;
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            _skillIndexWhenRecordSkillHit = startSkillIndex;
            m_aiComponent.bSkillHit = true;
            var hitID:Number = e.parmList[1];
            var hit:Hit = m_hitTable.findByPrimaryKey(hitID);
            if(hit)
            {
                var delayFrames:Number = hit.AttackerStopTime;//每个击打命中的定帧数
                _attackerStopTime=delayFrames*_skillFrameTime;
            }
            if(_isHitedOnece){//一个技能会有多个击打命中，但是AI只处理每个技能的第一次命中
                return;
            }
            _isHitedOnece=true;
            CAILog.logEnterSubNodeInfo("HitTarget" , "击中目标", m_aiComponent.objId );
            if(m_aiComponent.isExcutedNextSkill&&m_aiComponent.bComboSkill)
            {
                if( _isOpenSkillCountTime )
                        return;

                m_aiComponent.isExcutedNextSkill = false;
//                trace("执行个数（命中成功）:"+m_aiComponent.iSkillCount+",索引："+m_aiComponent.iSkillIndex);
                _filterNextSkill();
            }
        }

    private function _resetComboHitSignal() : void{
        _isHitedOnece=false;
        _isCatchedOnece=false;
    }

    private var _isCatchedOnece:Boolean;
        //抓取成功判定
        private function _catchSuccess(e:CFightTriggleEvent):void{
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            if(_isCatchedOnece){//一个技能可能会有多个抓取命中，但是AI只处理每个技能的第一次命中
                return;
            }
            _isCatchedOnece=true;
            if(m_aiComponent.isExcutedNextSkill&&m_aiComponent.bComboSkill)
            {
                if( _isOpenSkillCountTime )
                        return;

                m_aiComponent.isExcutedNextSkill = false; //抓取和命中只响应最先触发那个
//                trace("执行个数（抓取成功）:"+m_aiComponent.iSkillCount+",索引："+m_aiComponent.iSkillIndex);
                _filterNextSkill();
            }
        }

        private function _filterNextSkill( bFromSkill: Boolean = false ):void{
            if(m_aiComponent.isOverrideAction){//如果发生行为覆盖则不继续连下去，而等待执行更高优先级的行为
                return;
            }


            var len : int = m_aiComponent.piSkillIndexVec.length;
            if ( m_aiComponent.bComboSkill) { //如果是连击技能
                var currentSkillCountIndex : int = m_aiComponent.iSkillCount ;
//                m_aiComponent.iSkillCount++;

                if ( m_aiComponent.iSkillCount >= len ) {
                    return;
                }

                if ( m_aiComponent.iSkillCount != 0 ) {
                    var bHitTimeCount : Boolean;
                    bHitTimeCount = m_aiComponent.notHitButAttackVec.length > currentSkillCountIndex ?
                                    !(m_aiComponent.notHitButAttackVec[currentSkillCountIndex]) : true;

                    m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ currentSkillCountIndex ];
                    var skillId : int = (m_aiComponent.owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( m_aiComponent.iSkillIndex );
                    while ( skillId == 0 ) {
                        m_aiComponent.iSkillCount++;
                        if ( m_aiComponent.iSkillCount >= m_aiComponent.piSkillIndexVec.length ) {
                            m_aiComponent.iSkillCount = 0;
                            break;
                        }
                        m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ currentSkillCountIndex ];
                        skillId = (m_aiComponent.owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( m_aiComponent.iSkillIndex );
                    }
                    if ( skillId != 0 ) {
//                        CAILog.logMsg( "本次技能为连击，释放第" + m_aiComponent.iSkillCount + "个技能，技能索引为" + m_aiComponent.piSkillIndexVec[ currentSkillCountIndex ], m_aiComponent.objId );
                        m_aiComponent.iSkillIndex = m_aiComponent.piSkillIndexVec[ currentSkillCountIndex ];
                        m_aiComponent.bSkillConsume = m_aiComponent.psSkillIndexConsumeVec[ currentSkillCountIndex ];
                        m_aiComponent.nWaitTime = m_aiComponent.pnSkillWaitTimeVec[currentSkillCountIndex];
                        var bMoveDistance : Boolean;
                        if( m_aiComponent.pnSkillMoveToDistance && m_aiComponent.pnSkillMoveToDistance.length > currentSkillCountIndex ){
                            bMoveDistance = m_aiComponent.pnSkillMoveToDistance[currentSkillCountIndex] == 1 ;
                        }

                        m_aiComponent.bMoveToDistance = bMoveDistance;

                        m_aiComponent.bCanComboSkill = true;
//                        trace("执行个数（下一个执行）:"+m_aiComponent.iSkillCount+",索引："+m_aiComponent.iSkillIndex);
                        var timeOut:Number= m_aiComponent.nWaitTime;

                        if( timeOut == 0 ) {
                           _castComboSkill();
                            m_aiComponent.iSkillCount++;
                        }
                        else if( bHitTimeCount && !bFromSkill ) {
                            _isOpenCountTime = true;
                            m_aiComponent.iSkillCount++;
                        }
                        else if( !bHitTimeCount ) {
                            _isOpenSkillCountTime = true;
                            m_aiComponent.iSkillCount++;
                        }
                    }
                }
            }
        }
        private var _isOpenCountTime:Boolean = false;
        private var _isOpenSkillCountTime : Boolean = false;
        private var _elapsedFrameTime:Number=0;
        private var _elapsedSkillTime : Number=0.0;
        private var _skillFrameTime:Number=1/30;
        public function resetCastComboSkillCountTime():void{
            CAILog.logMsg(m_aiComponent.currentEventNodeName + "重置技能连击参数 @" + m_aiComponent.nWaitTime +" 技能索引：" + m_aiComponent.iSkillCount, m_aiComponent.objId )
            _isOpenCountTime = false;
            _isOpenSkillCountTime = false;
            m_delayFrames = 0;
            m_delayFrameCount = 0;
            _elapsedFrameTime =0 ;
            _elapsedSkillTime = 0.0;
            m_aiComponent.bComboSkill = false;
            _resetComboHitSignal();
        }
        //用于技能开始的判断时间帧 ，需要在fighthandler处理
        public function externalUpdate( delta : Number ) : void{
            if(_isOpenCountTime){
                    _elapsedFrameTime+=delta;
                if(_elapsedFrameTime>=(m_aiComponent.nWaitTime)){
                    CAILog.logMsg(m_aiComponent.currentCastSkillNodeName + "达到技能连击时间 @" + m_aiComponent.nWaitTime +" 技能索引：" + m_aiComponent.iSkillCount, m_aiComponent.objId , CAILog.enabledFailLog )
                    _castComboSkill();
                    _elapsedFrameTime = 0.0;
                    _isOpenCountTime=false;
                }
            }


            _elapsedSkillTime += delta;
            if( _isOpenSkillCountTime )
            {
                   if ( _elapsedSkillTime >= (m_aiComponent.nWaitTime ) ) {
                        _isOpenSkillCountTime = false;
                        _castComboSkill();
                        _elapsedSkillTime = 0;
                    }
            }

            _updateCalDurationAction( delta );
        }

        public function update(delta:Number):void{
            /*if(_isOpenCountTime){
                var pAnimation : IAnimation = m_aiComponent.owner.getComponentByClass( IAnimation , true ) as IAnimation;
                if( !pAnimation.isFrameFrozen )
                    _elapsedFrameTime+=delta;
                if(_elapsedFrameTime>=(m_aiComponent.nWaitTime)){
                    _isOpenCountTime=false;
                    _castComboSkill();
                    _elapsedFrameTime = 0;
//                    trace(m_aiComponent.nWaitTime+"```");
                }
            }*/

//            if(_isDirtyInCatch){
//                _isDirtyInCatch=false;
//                _begin_hitted(null);
//            }
//            if(_isDirtyBaTi){
//                _isDirtyBaTi=false;
//                m_pAIHandler.setCharacterState( m_aiComponent.owner, EFightStateType.NOT_BE_BREAK, true );
//            }
            if(_isDirtyGangTi){
                _isDirtyGangTi=false;
                m_pAIHandler.setCharacterState( m_aiComponent.owner, EFightStateType.NOT_BE_BREAK_AND_CATCH, false );
            }
//            if(_isDirtyWuDi){
//                _isDirtyWuDi=false;
//                m_pAIHandler.setCharacterState( m_aiComponent.owner, EFightStateType.NOT_BE_ATTACK, false );
//            }
        }
        public var startSkillIndex:int=0;
    private var _zgap:Number=1;
        //如果是连技，释放后续连击技能
        private function _castComboSkill():void{
            if(!m_aiComponent.bComboSkill){
                return;
            }

            if ( m_pAIHandler.isDead( m_aiComponent.owner ) ) {
                CAILog.logMsg( "当前攻击目标已经死亡，返回失败，退出", m_aiComponent.objId );
                return;
            }
            startSkillIndex = m_aiComponent.iSkillIndex;
            m_aiComponent.eventManager.skillBegined=false;
            var isMove : Boolean = false;
            var skillDistanceObj : Object = null;

            var bCastKeyUp : Boolean;
            if( m_aiComponent.iPreSkillIndex == m_aiComponent.iSkillIndex )
                bCastKeyUp = true;

            m_pAIHandler.clearMoveFinishCallBackFunction(m_aiComponent.owner);//清除上一次移动的回调
            var needMoveToDistance : Boolean = m_aiComponent.bMoveToDistance;

            CAILog.logComboSkillInfo( "", m_aiComponent.objId , m_aiComponent.iSkillCount , m_aiComponent.iSkillIndex , m_aiComponent.currentCastSkillNodeName );
            if ( m_aiComponent.bSkillConsume == "0" )//无视消耗
            {
                if( needMoveToDistance ) {
                    skillDistanceObj = m_pAIHandler.getSkillDistance( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                    isMove = m_pAIHandler.moveTo( m_aiComponent.owner, skillDistanceObj.x, skillDistanceObj.z * _zgap, new Point( 0, 0 ), function () : void {
                        m_pAIHandler.attackIgnoreWithSkillIdx( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                        if( bCastKeyUp )
                            m_pAIHandler.castUpWithSkillIndex( m_aiComponent.owner , m_aiComponent.iSkillIndex );
                    }, "ToAttack" );
                }
                if ( isMove == false ) {
                    m_aiComponent.skillBegin();
                    m_pAIHandler.attackIgnoreWithSkillIdx( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                    if( bCastKeyUp )
                        m_pAIHandler.castUpWithSkillIndex( m_aiComponent.owner , m_aiComponent.iSkillIndex );
                }
                else {
                    m_aiComponent.skillBegin();
//                    Foundation.Log.logWarningMsg( "进入,AI当前位置，(" + owner.transform.x + "," + owner.transform.y + ")" );
                }
            }
            else {
                if( needMoveToDistance ) {
                    skillDistanceObj = m_pAIHandler.getSkillDistance( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                    isMove = m_pAIHandler.moveTo( m_aiComponent.owner, skillDistanceObj.x, skillDistanceObj.z * _zgap, new Point( 0, 0 ), function () : void {
                        m_pAIHandler.attackWithSkillID( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                        if( bCastKeyUp )
                           m_pAIHandler.castUpWithSkillIndex( m_aiComponent.owner , m_aiComponent.iSkillIndex );
                    }, "ToAttack" );
                }
                if ( isMove == false ) {
                    m_aiComponent.skillBegin();
                    m_pAIHandler.attackWithSkillID( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                     if( bCastKeyUp )
                           m_pAIHandler.castUpWithSkillIndex( m_aiComponent.owner , m_aiComponent.iSkillIndex );
                } else {
                    m_aiComponent.skillBegin();
                }
            }
        }

        //击伤目标
        private function _isHurtTarget( e : CFightTriggleEvent ) : void {

        }

        //普攻、蓄力类连击技能
        private function _onKeySkillCombo( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            //（2017.11.30）AI统一规则，所有的连招都要命中后开始计时，所以下一个技能的触发都从首次命中后去计算
            //不是连击技，现在只有普攻模板会用这个，后面看能否将普攻的配置也统一成连击配置`
            if(!m_aiComponent.bComboSkill){
                if(m_aiComponent.iSkillIndex==0&&!m_aiComponent.isOverrideAction){
                    CAILog.logMsg( "接收到普攻、蓄力类连击事件，技能类型:" + m_aiComponent.useSkillType + "，技能索引:" + m_aiComponent.iSkillIndex, m_aiComponent.objId );
                    m_pAIHandler.attackWithSkillID( m_aiComponent.owner, m_aiComponent.iSkillIndex );
                }
            }//这里只处理普攻了，因为模板中有个单独的普攻模板，配置方式是只配了一个0，每个人的普攻段数不一样
        }

        //-----------------------------------------------------------------------
        //-------------------------攻击目标侦听的相关事件--------------------------
        //----------------------------------------------------------------------
        public final function removeAttackableEvent( e : Event ) : void {
            _removeAttackableEvent();
        }

        //目标发动攻击，重置目标被攻击事件，但是从目标被打，到目标出招这个过程，都会是判断目标被打的状态（比如目标被打后逃离远处，跑动中明显不应是被打的状态），这里有问题，得调整
        private function _attackTargetSkillBegin( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.bTargetAttack = true;
            m_aiComponent.bTargetHited = false;
            CAILog.logMsg( "接收到目标开始调用技能事件，重置targetAttack=true，targetHited=false", m_aiComponent.objId , CAILog.enabledFailLog );
        }

        //目标被攻击
        private function _attackTarget_begin_hitted( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.bTargetHited = true;
            CAILog.logMsg( "接收到目标被攻击事件，重置targetHited=true", m_aiComponent.objId , CAILog.enabledFailLog );
        }

        private function _attackTargetSkillFailed( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.bTargetAttack = false;
            CAILog.logMsg( "接收到目标调用技能失败事件，重置targetAttck=false", m_aiComponent.objId , CAILog.enabledFailLog );
        }

        private function _attackTargetSkillComplete( e : CFightTriggleEvent ) : void {
            if ( m_pAIHandler.isHero( m_aiComponent.owner ) ) {
                if ( !m_pAIHandler.bAutoFight ) {
                    return;
                }
            }
            if ( !m_aiComponent.enabled )return;
            if ( !m_pAIHandler.enabled )return;
            m_aiComponent.bTargetAttack = false;
            CAILog.logMsg( "接收到目标调用技能完成事件，重置targetAttck=false", m_aiComponent.objId );
        }

        //重置_pAttackableEventMediator的事件侦听
        public function resetAttackableEventMediatorListener() : void {
            _pAttackableEventMediator.addEventListener( CCharacterEvent.REMOVED, removeAttackableEvent );
        }

        //---------------------------------------------------------------
        //-------------------------getter、setter相关---------------------
        //---------------------------------------------------------------
        private function set _pAttackableCharacter( value : CCharacterFightTriggle ) : void {
            this.m_aiComponent.attackableFightTriggle = value;
        }

        private function get _pAttackableCharacter() : CCharacterFightTriggle {
            return this.m_aiComponent.attackableFightTriggle;
        }

        private function get _pStateMachine() : CCharacterStateMachine {
            var pOwner : CGameObject = this.m_aiComponent.owner;
            var stateMachine : CCharacterStateMachine;
            if( pOwner !== null && pOwner.isRunning ){
                stateMachine = pOwner.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
            }

            return stateMachine;
        }


        private function get _pEventMediator() : CEventMediator {
            return this.m_aiComponent.eventMediator;
        }

        private function get _pCharacterMediator() : CCharacterFightTriggle {
            return this.m_aiComponent.characterFightTriggle;
        }

        private function set _pAttackableEventMediator( value : CEventMediator ) : void {
            this.m_aiComponent.attackableEventMediator = value;
        }

        private function get _pAttackableEventMediator() : CEventMediator {
            return this.m_aiComponent.attackableEventMediator;
        }

        private function get m_pAIHandler() : CAIHandler {
            return m_aiComponent.aiHandler;
        }

        public final function dispose() : void {
            removeEventListeners();
        }
    }
}
