//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CSkillList;
import kof.game.character.ai.actions.CMoveAction;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.chainbase.CChainBaseNode;
import kof.game.character.fight.chainbase.CChainPropertyNode;
import kof.game.character.fight.chainbase.CStaticChain;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillEvaluator;
import kof.game.character.fight.skilleffect.CSkillChainEffect;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.movement.CMovement;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

import kof.table.Chain.ECastType;
import kof.table.Chain.EChainTransType;
import kof.table.ChainCondition;
import kof.table.ChainKeyCondition;
import kof.table.Skill;
import kof.table.Skill.EEffectType;
import kof.util.CAssertUtils;

/**
 * 自动触发模式  去检测属性条件
 */
public class CAutoTriggleMechanism implements ITriggleSkillMechanism {
    public function CAutoTriggleMechanism( skillChain : CSkillChainEffect , owner : CGameObject ) {
        super();
        m_skillChain = skillChain;
        m_pOwner = owner;
        m_modeType = ECastType.BY_AUTO;
        m_staticChain = new CStaticChain();
        CONFIG::debug{ Foundation.Log.logTraceMsg( "@CAutoTriggleMechanism ,创建一个自动触发技能链，目标技能为 ：" + m_skillChain.chainData.SkillID ) };
    }

    public function dispose() : void
    {
        if( m_keyChainCode > 0) {
            var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            pTE.removeEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onTriggleKeyChain );
        }

        if( m_trasferEvent != null && m_trasferEvent != "")
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent , casteSkillByTransWay);

        m_trasferEvent= null;
        m_staticChain.dispose();
        m_staticChain = null;
    }

    //内部判断条件 不在外部引用
    public function isEvaluate()  : Boolean
    {
        var evaluateProperty: Boolean;
        var boWaitForKey : Boolean = false;

        //这个是属性判断条件
        var conditionID : int = m_skillChain.chainData.SkillChainConditionID;
        var keyBoardCondition : int = m_skillChain.chainData.KeyBoardConditionID;
        if( conditionID == 0  && keyBoardCondition == 0) {
           CSkillDebugLog.logTraceMsg( "@CAutoTriggleMechanism ,技能链无条件判断立即通过") ;
            return true;
        }

        if( conditionID > 0) {
            m_cCondition = CSkillCaster.skillDB.getChainCondition( conditionID , CCharacterDataDescriptor.getSimpleDes( m_pOwner.data ));
            if( !m_hasInitChain )initChain();
            evaluateProperty = evaluteChain();
        }

        if( keyBoardCondition > 0) {
            if( !m_hasInitKeyCondition )
                    initKeyEvaluate();
            //here wait for key event comes
            boWaitForKey = true;
        }
        return evaluateProperty && !boWaitForKey;
    }

    //init key condition
    private function initKeyEvaluate() : void
    {
        //键盘
        var keyConditionID : int = m_skillChain.chainData.KeyBoardConditionID;
        if( keyConditionID > 0 ) {
            m_cKeyBoardCondition = CSkillCaster.skillDB.getChainKeyCondition( keyConditionID );
            m_keyChainCode = KeyConditionMgr.getKeyCodeByType( m_cKeyBoardCondition.KeyCode[0] );
            var pTE : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
            pTE.addEventListener( CFightTriggleEvent.CONTINUE_KEY_DOWN, onTriggleKeyChain );
            m_hasInitKeyCondition =  true;
            CSkillDebugLog.logTraceMsg("自动触发器帧听键盘条件 KEYCODE = " + m_keyChainCode  );
        }
    }

    private function onTriggleKeyChain( e : CFightTriggleEvent ) : void
    {
        if ( e.parmList[ 0 ] != m_keyChainCode )
            return ;
        var ret : Boolean
        if( m_skillChain )
             ret = evaluteChain();

        if( ret )
             extraTransfer();
    }

    public function exitMechanism() : void
    {
        if( m_trasferEvent != null && m_trasferEvent != "")
            m_skillChain.fightTriggle.removeEventListener( m_trasferEvent , casteSkillByTransWay);

        m_trasferEvent = "";
    }

    private function evaluteChain() : Boolean
    {
        return m_staticChain.traversingChain();
    }

    private function initChain() : void
    {
        var evaluaNodeData : Object;
        var evaluaNode : CChainBaseNode;

        for( var i :int = 0 ; i< m_cCondition.PropertyConditionType.length ; i++ )
        {
            if( m_cCondition.PropertyConditionType[i] > 0 ) {
                evaluaNodeData = {};
                evaluaNodeData.PropertyConditionType = m_cCondition.PropertyConditionType[i];
                evaluaNodeData.PropertyConditionValue = m_cCondition.PropertyConditionValue[i];
                evaluaNodeData.PropertyCondition = m_cCondition.PropertyCondition[i];
                evaluaNode =  CSkillEvaluator.getChainNodeByType( m_cCondition.PropertyConditionType[i] , m_pOwner );//new CChainPropertyNode( m_pOwner);
                evaluaNode.evaluateValue = evaluaNodeData;
                //目前条件都为与关系
                m_staticChain.addSequenceChainNode(evaluaNode);
                CONFIG::debug{ Foundation.Log.logTraceMsg( "@CAutoTriggleMechanism ,加入条件判断：属性判断类型：" +  evaluaNodeData.PropertyConditionType ) };
            }
        }
        //TODO STATE NODE  ACTION NODE


        m_hasInitChain = true;
    }

    public function onTransfer() : void
    {
        if(isEvaluate())
        {
            extraTransfer();
        }
    }

    private function extraTransfer() : void
    {
        if( m_skillChain == null )
                return;
        switch (m_skillChain.TransType)
        {
            case EChainTransType.TRANS_IMIDIATELY:
                doTrigger();
                break;
            case EChainTransType.TRANS_SKILL_END:
                m_trasferEvent = CFightTriggleEvent.SPELL_SKILL_END;
                break;
            case EChainTransType.TRANS_ACTION_END:
                m_trasferEvent = CFightTriggleEvent.ANIMATION_ACTION_END;
                break;
            default:
                Foundation.Log.logErrorMsg( "extra an undefine TransferType in CAutoTriggerMechanism" );
        }

        if( m_trasferEvent != null && m_trasferEvent != "")
            m_skillChain.fightTriggle.addEventListener( m_trasferEvent , casteSkillByTransWay );
    }

    private function casteSkillByTransWay(e : CFightTriggleEvent ) : void
    {
        if( m_trasferEvent != null && m_trasferEvent.length !=0 )
        m_skillChain.fightTriggle.removeEventListener( m_trasferEvent ,casteSkillByTransWay );
        m_trasferEvent = "";
        doTrigger();
    }

    protected function doTrigger() : void
    {
        var SkillID : int =  m_skillChain.chainData.SkillID ;
        if(SkillID > 0) {
            _casterSkillByID( SkillID );
        }
        else
            Foundation.Log.logTraceMsg(" try to trigger an invalid skill that no belong to character  in AutoMechanism" );
    }

    private function _casterSkillByID( skillID : int ) : void
    {
        CONFIG::debug{ Foundation.Log.logTraceMsg("技能链ID：" + m_skillChain.chainData.ID + "@CAutoTriggleMechanism 技能链触发了自动模式的技能：" + m_skillChain.chainData.SkillID); };

        //netCheck
        var pHostInput: CCharacterResponseQueue = m_pOwner.getComponentByClass( CCharacterResponseQueue , true ) as CCharacterResponseQueue;
        if( pHostInput) {
            var boVerifyNet : Boolean = pHostInput.getBoSpellSkillAheadHost();
            if ( !boVerifyNet )
                return ;
        }

//        m_skillChain.facadeMediator.attackWithSkillID( skillID );
        var pInput : CCharacterInput = m_pOwner.getComponentByClass( CCharacterInput , true ) as CCharacterInput;
        if( pInput )
                pInput.addActionCall( m_skillChain.facadeMediator.attackWithSkillID , [skillID] );
    }

    public function reset() : void
    {

    }

    public function get modeType()  : int
    {
        return m_modeType;
    }

    final private function get skillList() : CSkillList
    {
        return m_skillChain.skillList;
    }

    private var m_modeType : int;
    protected var m_skillChain : CSkillChainEffect;
    private var m_staticChain : CStaticChain;
    private var m_cCondition : ChainCondition;
    private var m_cKeyBoardCondition : ChainKeyCondition;
    private var m_hasInitChain : Boolean;
    private var m_trasferEvent : String;
    private var m_keyChainCode : int ;
    private var m_hasInitKeyCondition : Boolean;
    protected var m_pOwner : CGameObject;
}
}

