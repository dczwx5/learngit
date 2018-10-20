//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation;
import QFLib.Graphics.Character.CCharacterInfo;
import QFLib.Interface.IUpdatable;

import flash.ui.Keyboard;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CSkillList;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.chainbase.CChainBaseNode;
import kof.game.character.fight.chainbase.CStaticChain;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillEvaluator;
import kof.game.character.fight.skillchain.KeyConditionMgr;
import kof.game.character.fight.skilleffect.CSkillChainEffect;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterInput;

import kof.game.core.CGameObject;

import kof.table.Chain.ECastType;
import kof.table.Chain.EChainTransType;
import kof.table.ChainCondition;
import kof.table.ChainKeyCondition;
import kof.table.Skill;

/**
 * 被动触发模式 要去检查按键
 */
public class CManualTriggleMechanism implements ITriggleSkillMechanism {
    public function CManualTriggleMechanism( skillChain : CSkillChainEffect, owner : CGameObject ) {
        m_modeType = ECastType.BY_PRIMARY_KEY;
        m_skillChain = skillChain;
        m_pOwner = owner;

        var parentKey : int = _getCurrentParentSkillKey();
        var keyConditionID : int = m_skillChain.chainData.KeyBoardConditionID;
        if ( keyConditionID > 0 ) {
            var conditionKey : int;
            m_cKeyBoardCondition = CSkillCaster.skillDB.getChainKeyCondition( keyConditionID );
            conditionKey = m_cKeyBoardCondition.KeyCode[ 0 ];
            if ( KeyConditionMgr.isSameCurrentKey( conditionKey ) ) {
                m_keyCode = parentKey;
            }
            else if ( KeyConditionMgr.isDiffCurrentKey( conditionKey ) ) {
                m_keyCode = parentKey;
            } else {
                m_keyCode = conditionKey;
            }

        } else {
            //no condition key? then default parentKey;
            m_keyCode = parentKey;
        }

        m_staticChain = new CStaticChain();
        CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ,创建一个手动触发技能链,目标技能为" + m_skillChain.chainData.SkillID );
    }

    public function dispose() : void {
        //移除键盘事件
        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( m_trasferEvent )
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );

        if ( m_staticChain )
            m_staticChain.dispose();
        m_staticChain = null;
        var primarySkillID : int = getTargetSkillData( m_skillChain.chainData.SkillID ).RootSkill;
        pTE.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_CHAIN_OUTDATE, null, [ primarySkillID, primarySkillID ] ) );
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onKeyDown );

    }

    public function isEvaluate() : Boolean {
        //判断键盘事件是否在有效时间内到达
        var evaluateProperty : Boolean;
        var boWaitForKey : Boolean = false;

        //这个是属性判断条件
        var conditionID : int = m_skillChain.chainData.SkillChainConditionID;
        var keyBoardCondition : int = m_skillChain.chainData.KeyBoardConditionID;
        if ( conditionID == 0 && keyBoardCondition == 0 ) {
            CSkillDebugLog.logTraceMsg( "@CAutoTriggleMechanism ,技能链无条件判断立即通过" );
            return true;
        }

        if ( conditionID > 0 ) {
            m_cCondition = CSkillCaster.skillDB.getChainCondition( conditionID, CCharacterDataDescriptor.getSimpleDes( m_pOwner.data ) );
            if ( !m_hasInitChain )initChain();
            evaluateProperty = evaluteChain();
        }else{
            evaluateProperty = true;
        }
        return evaluateProperty;
    }

    private function evaluteChain() : Boolean {
        return m_staticChain.traversingChain();
    }

    public function exitMechanism() : void {
        if ( m_trasferEvent )
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onKeyDown );
    }

    public function onTransfer() : void {
        m_boHitEventCome = true;

        CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ,进入手动技能链状态转移，帧听键盘事件 keycode = " + m_keyCode );

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var primarySkillID : int = getTargetSkillData( m_skillChain.chainData.SkillID ).RootSkill;
        pTE.addEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onKeyDown );
        pTE.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_CHAIN_PASS_EVALUATION, null, [ primarySkillID, m_skillChain.chainData.SkillID ] ) );
    }

    private function _getCurrentParentSkillKey() : int {
        var parentKey : int = -1;
        var primarySkillID : int = getTargetSkillData( m_skillChain.chainData.SkillID ).RootSkill;
        var iCharacterP : ICharacterProperty = m_pOwner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if ( primarySkillID )
            parentKey = CSkillKeyMgr.instance.getSkillKeyCode( iCharacterP.profession, primarySkillID );
        return parentKey;
    }

    private function extraTransfer() : void {
        switch ( m_skillChain.TransType ) {
            case EChainTransType.TRANS_IMIDIATELY:
                casteSkill();
                break;
            case EChainTransType.TRANS_SKILL_END:
                m_trasferEvent = CFightTriggleEvent.SPELL_SKILL_END
                break;
            case EChainTransType.TRANS_ACTION_END:
                m_trasferEvent = CFightTriggleEvent.ANIMATION_ACTION_END;
                break;
            default:
                CSkillDebugLog.logTraceMsg( "@CManualTriggleMech 当前技能跳转方式遇到无效值 cHAIN->TransTypes ： " + m_skillChain.TransType );
        }

        if ( m_trasferEvent != null && m_trasferEvent != "" )
            m_skillChain.fightTriggle.addEventListener( m_trasferEvent, casteSkillByTransWay );
    }

    private function casteSkillByTransWay( e : CFightTriggleEvent ) : void {
        m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );
        m_trasferEvent = "";
        casteSkill();
    }

    private function onKeyDown( e : CFightTriggleEvent ) : void {
//        if ( e.parmList[ 0 ] != keyCode )
//            return;

        var pressedKey : int = e.parmList[ 0 ];
        if ( !_boKeyConditionPass( pressedKey ) ) return;

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onKeyDown );
        var theInput : CCharacterInput = m_pOwner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( theInput )
            theInput.truncateSkillRequests();

        if ( isEvaluate() ) {

            CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ，帧听到键盘事件 ：ｋｅｙｃｏｄｅ= " + keyCode );

            if ( e.parmList[ 0 ] == keyCode )
                m_bokeyBoardPress = true;

            if ( m_boHitEventCome )
                extraTransfer();
        }
    }

    private function _boKeyConditionPass( pressKey : int ) : Boolean {
        if ( m_cKeyBoardCondition == null ) {
            return pressKey == keyCode;
        }

        var condition : int = m_cKeyBoardCondition.KeyCode[ 0 ];
        if ( KeyConditionMgr.isSameCurrentKey( condition ) ) {
            return pressKey == keyCode;
        }
        if ( KeyConditionMgr.isDiffCurrentKey( condition ) ) {
            return pressKey != keyCode;
        }

        return pressKey == keyCode;
    }

    final private function get keyCode() : int {
        return m_keyCode;
    }

    private function casteSkill() : void {
        var skillID : int = m_skillChain.chainData.SkillID;
        if ( skillID > 0 ) {
            CONFIG::debug{
                Foundation.Log.logTraceMsg( "@CManualTriggleMechanism 技能链触发了手动模式的技能：" + skillID );
            }
            ;
            var pInput : CCharacterInput = m_pOwner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
            if ( pInput )
                pInput.addActionCall( m_skillChain.facadeMediator.attackWithSkillID, [ skillID ] );
//            m_skillChain.facadeMediator.attackWithSkillID( skillID );
        } else
            Foundation.Log.logWarningMsg( " try to trigger an invalid skill that no belong to character  in ManualMechanism" );

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var primarySkillID : int = getTargetSkillData( m_skillChain.chainData.SkillID ).RootSkill;
        pTE.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_CHAIN_OUTDATE, null, [ primarySkillID, primarySkillID ] ) );
    }

    public function reset() : void {
        CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ,重置手动技能链状态转移" );
        m_elapsedTime = 0.0;
        m_bokeyBoardPress = false;
        m_boHitEventCome = false;
        m_isValid = false;
    }

    public function get modeType() : int {
        return m_modeType;
    }

    final private function get skillList() : CSkillList {
        return m_skillChain.skillList;
    }

    [inline]
    final private function getTargetSkillData( skillID : int ) : Skill {
        return CSkillCaster.skillDB.getSkillDataByID( skillID );
    }

    private function initChain() : void {
        var evaluaNodeData : Object;
        var evaluaNode : CChainBaseNode;

        for ( var i : int = 0; i < m_cCondition.PropertyConditionType.length; i++ ) {
            if ( m_cCondition.PropertyConditionType[ i ] > 0 ) {
                evaluaNodeData = {};
                evaluaNodeData.PropertyConditionType = m_cCondition.PropertyConditionType[ i ];
                evaluaNodeData.PropertyConditionValue = m_cCondition.PropertyConditionValue[ i ];
                evaluaNodeData.PropertyCondition = m_cCondition.PropertyCondition[ i ];
                evaluaNode = CSkillEvaluator.getChainNodeByType( m_cCondition.PropertyConditionType[ i ], m_pOwner );//new CChainPropertyNode( m_pOwner);
                evaluaNode.evaluateValue = evaluaNodeData;
                //目前条件都为与关系
                m_staticChain.addSequenceChainNode( evaluaNode );
                CONFIG::debug{
                    Foundation.Log.logTraceMsg( "@CAutoTriggleMechanism ,加入条件判断：属性判断类型：" + evaluaNodeData.PropertyConditionType )
                }
                ;
            }
        }
        //TODO STATE NODE  ACTION NODE


        m_hasInitChain = true;
    }

    private var m_skillChain : CSkillChainEffect;
    private var m_modeType : int;
    private static var StartTime : Number = 0.0;
    private static var EndTime : Number = 2;
    private var m_elapsedTime : Number = 0.0;
    private var m_isValid : Boolean;
    //如果还没有击中事件 则标志键盘按下 等下次击中事件下来释放技能链
    private var m_bokeyBoardPress : Boolean;
    private var m_boHitEventCome : Boolean;
    private var m_trasferEvent : String;
    private var m_keyCode : int;
    private var m_cKeyBoardCondition : ChainKeyCondition;
    private var m_keyChainCode : int;

    private var m_pOwner : CGameObject;
    private var m_cCondition : ChainCondition;
    private var m_staticChain : CStaticChain;
    private var m_hasInitChain : Boolean;
    //如果击打事件下来了
}
}
