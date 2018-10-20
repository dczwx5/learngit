//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/4/26.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation;

import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skilleffect.CSkillChainEffect;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterInput;
import kof.game.core.CGameObject;
import kof.table.Chain.ECastType;
import kof.table.Chain.EChainTransType;

public class CManualKeyUpTriggleMechanism implements ITriggleSkillMechanism {
    public function CManualKeyUpTriggleMechanism( skillChain : CSkillChainEffect, owner : CGameObject ) {
        m_modeType = ECastType.BY_PRIMARY_KEY_UP;
        m_skillChain = skillChain;
        m_pOwner = owner;

        var parentKey : int = _getCurrentParentSkillKey();
        m_keyCode = parentKey;

        CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ,创建一个蓄力触发技能链,目标技能为" + m_skillChain.chainData.SkillID );
    }

    public function dispose() : void {
        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_UP, onKeyUp );
        //移除键盘事件
        //var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( m_trasferEvent )
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );
    }

    public function isEvaluate() : Boolean {
        return true;
    }

    public function onTransfer() : void {
        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.addEventListener( CFightTriggleEvent.CONTINUE_KEY_UP, onKeyUp );
    }

    private function onKeyUp( e : CFightTriggleEvent ) : void {
        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_UP, onKeyUp );
        var theInput : CCharacterInput = m_pOwner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( theInput )
            theInput.truncateSkillUpRequests();

        if ( isEvaluate() ) {

            CSkillDebugLog.logTraceMsg( "@CManualTriggleMechanism ，帧听到键盘起跳事件 ：ｋｅｙｃｏｄｅ= " + keyCode );

            if ( e.parmList[ 0 ] == keyCode )
                extraTransfer();
        }
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
            case EChainTransType.TRANS_EFFECT_END:
                m_bEndTrigger = true;
                break;
            default:
                CSkillDebugLog.logTraceMsg( "@CManualTriggleMech 当前技能跳转方式遇到无效值 cHAIN->TransTypes ： " + m_skillChain.TransType );
        }

        if ( m_trasferEvent != null && m_trasferEvent != "" )
            m_skillChain.fightTriggle.addEventListener( m_trasferEvent, casteSkillByTransWay );
    }

    private function get bEndTrigger() : Boolean{
        return m_bEndTrigger;
    }

    private function casteSkillByTransWay( e : CFightTriggleEvent ) : void {
        m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );
        m_trasferEvent = "";
        casteSkill();
    }

    private function get keyCode() : int{
        return m_keyCode;
    }

    public function reset() : void{

    }

    public function exitMechanism() : void{
        if( bEndTrigger )
                casteSkill();
        m_bEndTrigger = false;

        if ( m_trasferEvent )
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent, casteSkillByTransWay );

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onKeyUp );
    }

    public function get modeType() : int{
        return m_modeType;
    }

    private function _getCurrentParentSkillKey() : int {
        var parentKey : int = -1;
        var primarySkillID : int = CSkillCaster.skillDB.getSkillDataByID( m_skillChain.chainData.SkillID ).RootSkill;
        var iCharacterP : ICharacterProperty = m_pOwner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if ( primarySkillID )
            parentKey = CSkillKeyMgr.instance.getSkillKeyCode( iCharacterP.profession, primarySkillID );
        return parentKey;
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
        } else
            Foundation.Log.logWarningMsg( " try to trigger an invalid skill that no belong to character  in ManualMechanism" );

        var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var primarySkillID : int = CSkillCaster.skillDB.getSkillDataByID( m_skillChain.chainData.SkillID ).RootSkill;
        pTE.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_CHAIN_OUTDATE, null, [ primarySkillID, primarySkillID ] ) );
    }

    private var m_modeType : int;
    private var m_skillChain : CSkillChainEffect;
    private var m_pOwner : CGameObject;
    private var m_keyCode : int;
    private var m_trasferEvent : String;
    private var m_bEndTrigger : Boolean;
}
}
