//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/26.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.fight.chainbase.CBuffPropertyNode;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.ECalcStateRet;
import kof.game.character.fight.chainbase.CChainBaseNode;
import kof.game.character.fight.chainbase.CChainPropertyNode;
import kof.game.character.fight.chainbase.CChainStatsNode;
import kof.game.character.fight.chainbase.CStaticChain;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.ChainCondition;
import kof.table.ChainCondition.EPropertyConditionType;
import kof.table.Skill;
import kof.table.Skill.ECastType;
import kof.table.Skill.ESkillType;

/**
 * evaluator for checking if stat is satisfy for spell skill
 */
public class CSkillEvaluator {

    public function CSkillEvaluator( owner : CGameObject = null ) {
        m_pSkillOwner = owner;
    }

    public function set skillOwner( skillOwner : CGameObject ) : void {
        m_pSkillOwner = skillOwner;
    }

    public function get skillOwner() : CGameObject {
        return m_pSkillOwner;
    }

    public function dispose() : void {
        m_pSkillOwner = null;
    }

    final private function get pSkillSimulator() : CSimulateSkillCaster {
        return m_pSkillOwner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
    }

    /**
     *
     * @param skillID  to check if the state of character is fit to spell skill
     * @return  return true when skill can spell, otherwise return false
     */
    public function evaluateSkillStateByID( skillID : int ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreState )
            return true;

        var statID : int = CSkillCaster.skillDB.getSkillDataByID( skillID, CCharacterDataDescriptor.getSimpleDes( m_pSkillOwner.data ) ).CastPos;
        var chainCondition : ChainCondition;
        if ( statID != 0 )
            chainCondition = CSkillCaster.skillDB.getChainCondition( statID, CCharacterDataDescriptor.getSimpleDes( skillOwner.data ) );

        if ( null == chainCondition ) {
            CSkillDebugLog.logTraceMsg( "Evaluator : 没有状态条件限制，可以进入ATTACK " );
            return true;
        }
        else
            return evaluateSkillByState( chainCondition );
    }

    /**
     *
     * @param skillID  to check if the consumeAp is fit to spell skill
     * @return
     */
    public function evaluateSkillFightCalcByID( skillID : int, boNotify : Boolean = false ) : Boolean {
        if ( pSkillSimulator && ( pSkillSimulator.boIgnoreAP || pSkillSimulator.boIgnoreRP ) )
            return true;

        var fCalc : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );
        var bSuper : Boolean = skillData.SkillType == ESkillType.SKILL_SPOWER; //&& skillData.CastType == ECastType.NORMAL;
        var pSkillProComp : CSkillPropertyComponent = m_pSkillOwner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
        if ( bSuper ) {
            var ConsumePGP : int;
            if ( pSkillProComp )
                ConsumePGP = pSkillProComp.getSkillConsumePGP( skillID );

            return evaluateRagePower( -ConsumePGP )
        }
        var consumeAp : int;
        if ( pSkillProComp )
            consumeAp = pSkillProComp.getSkillConsumeAp( skillID );

        if ( consumeAp == 0 ) {
            CSkillDebugLog.logTraceMsg( "EVALUATOR : 技能攻击值消耗为0" );
            return true;
        }

        var ret : Boolean = fCalc.battleEntity.isEnoughAttackPower( consumeAp );

        if ( boNotify && !ret ) {
            var fightTrigger : CCharacterFightTriggle = m_pSkillOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_NOT_ENOUGHT_AP, null, [ skillID ] ) );
        }

        if ( ret )
            CSkillDebugLog.logTraceMsg( "EVALUATOR : 技能攻击值满足释放技能" );
        else {
            CSkillDebugLog.logTraceMsg( "EVALUATOR : 技能攻击值不够" );
            var aiComponet : CAIComponent = m_pSkillOwner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.warningMsg( "EVALUATOR : 技能攻击值不够", aiComponet.objId );
        }


        return ret;
    }

    /**
     *
     * @param skillID  to check if the AP is fit to cancel
     * @return
     */
    public function evaluateSkillCancelByID( skillID : int ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreAP )
            return true;

        var fCalc : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var customAp : int = CSkillCaster.skillDB.getSkillDataByID( skillID ).CancelConsumeAP;
        if ( customAp == 0 )
            return true;

        var ret : Boolean = fCalc.battleEntity.isEnoughAttackPower( customAp );
        if ( !ret )
            CSkillDebugLog.logTraceMsg( " 攻击值不够取消技能 ：" + skillID );
        else
            CSkillDebugLog.logTraceMsg( " 攻击值能够够取消技能 ：" + skillID );

        return ret;
    }

    /**
     * 外部一律用这个接口来检验防御值  提供一个事件来通知防御值改变
     * @param value  改变的值  加就正数  减就负数
     * @param isPercent  是否百分比形式来加
     * @isCal 是否要实时计算，如果否 请在外部自行计算
     * @return  返回的是enum值  ECalStateRet
     */
    public function evaluateDefensePower( value : int, isPercent : Boolean = false ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreDP )
            return true;

        var fCalc : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;

        var ret : int = fCalc.battleEntity.calcDefensePower( value, isPercent, false );

        if ( ret == ECalcStateRet.E_BAN ) {
            var fTrigger : CCharacterFightTriggle = m_pSkillOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            fTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_NOT_ENOUGHT_DP, null, null ) );
        }

        return ret == ECalcStateRet.E_PASS;
    }

    /**
     * 外部一律用这个接口来检验gongji值  提供一个事件来通知防御值改变
     * @param value
     * @param isPercent
     * @return
     */
    public function evaluateAttackPower( value : int, isPercent : Boolean = false ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreAP )
            return true;

        var fCalc : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var ret : int = fCalc.battleEntity.calcAttackPower( value, isPercent, false );
        if ( ret == ECalcStateRet.E_BAN ) {
            var fTrigger : CCharacterFightTriggle = m_pSkillOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            fTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_NOT_ENOUGHT_AP, null, null ) );
        }

        return ret == ECalcStateRet.E_PASS;
    }

    /**
     * 怒气
     * @param value
     * @param isPercent
     * @return
     */
    public function evaluateRagePower( value : int, isPercent : Boolean = false ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreRP )
            return true;
        var evaRet : Boolean;
        var fCalc : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var ret : int = fCalc.battleEntity.calcRagePower( value, isPercent, false );
        if ( ret == ECalcStateRet.E_BAN ) {
            var fTrigger : CCharacterFightTriggle = m_pSkillOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            fTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_NOT_ENOUGHT_RP, null, null ) );
        }

        evaRet = ret == ECalcStateRet.E_PASS;
        if ( !evaRet ) {
            CSkillDebugLog.logTraceMsg( "EVALUATOR 怒气值不够 " );
            var aiComponet : CAIComponent = m_pSkillOwner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.warningMsg( "EVALUATOR 怒气值不够 ", aiComponet.objId );
        }

        return evaRet;//ret == ECalcStateRet.E_PASS;
    }

    /**
     *
     * @param to check the skillCD is clear
     * @return return ture when is not in CD or need no cd
     */
    public function evaluateSkillCDByID( skillID : int ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreCD )
            return true;

        var fightCal : CFightCalc = m_pSkillOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        if ( fightCal ) {
            var boInCD : Boolean;
            boInCD = fightCal.fightCDCalc.isInCD( skillID );
            if ( boInCD ) {
                var fTrigger : CCharacterFightTriggle = m_pSkillOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                fTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_NOT_ENOUGHT_CD, null, [ skillID ] ) );
            }
            return !boInCD;
        }

        return true;
    }

    /**
     *
     * @param chainData
     * @return  return true if state is fitted to spell skill, or return false
     */
    private function evaluateSkillByState( chainData : ChainCondition ) : Boolean {
        if ( pSkillSimulator && pSkillSimulator.boIgnoreState )
            return true;

        var evaluatNodeData : Object;
        var evaluatNode : CChainBaseNode;
        var evaluatTree : CStaticChain = new CStaticChain();

        for ( var i : int = 0; i < chainData.PropertyConditionType.length; i++ ) {
            if ( chainData.PropertyConditionType[ i ] > 0 ) {
                evaluatNodeData = {};
                evaluatNodeData.PropertyConditionType = chainData.PropertyConditionType[ i ];
                evaluatNodeData.PropertyConditionValue = chainData.PropertyConditionValue[ i ];
                evaluatNodeData.PropertyCondition = chainData.PropertyCondition[ i ];

                evaluatNode = getChainNodeByType( chainData.PropertyConditionType[ i ], m_pSkillOwner );
                evaluatNode.evaluateValue = evaluatNodeData;
                //目前条件都为与关系
                if ( null != evaluatNode )
                    evaluatTree.addSequenceChainNode( evaluatNode );
                CSkillDebugLog.logTraceMsg( "@CAutoTriggleMechanism ,加入条件判断：类型为：" + evaluatNodeData.PropertyConditionType );
            }
        }

        return evaluatTree.traversingChain();
    }

    public static function getChainNodeByType( type : int, owner : CGameObject ) : CChainBaseNode {
        var node : CChainBaseNode;
        switch ( type ) {
            case  EPropertyConditionType.P_HP:
            case  EPropertyConditionType.P_ATTACK_POWER:
            case  EPropertyConditionType.P_DEFENCE_PWEER:
                node = new CChainPropertyNode( owner );
                break;
            case  EPropertyConditionType.P_STATUS_PARMS:
                node = new CChainStatsNode( owner );
                break;
            case EPropertyConditionType.P_BUFF_PARMS:
                node = new CBuffPropertyNode( owner );
                break;

        }

        return node;
    }

    //判断是否打断技能 true为可以打断  false为不能打断
    /**
     * 这里乱起把枣 ，重构！！！
     * @param sourceSkillID
     * @param targetSkillID
     * @return
     */
    public function evaluateInterruptLogic( sourceSkillID : int, targetSkillID : int ) : Boolean {

        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**进入了技能覆盖判断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
        }
        if ( pSkillSimulator && pSkillSimulator.boIgnoreInterrupt )
            return true;

        if ( sourceSkillID == 0 ) return true;

        var curSkillData : Skill = CSkillCaster.skillDB.getSkillDataByID( sourceSkillID );
        var nextSkillData : Skill = CSkillCaster.skillDB.getSkillDataByID( targetSkillID );
        //大招 技能 普攻
        var curSkillType : int = curSkillData.SkillType;
        var skillType : int = nextSkillData.SkillType;
        // 主动，被动，sourceSkillID
        var curSkillCastType : int = curSkillData.CastType;
        var skillCastType : int = nextSkillData.CastType;

        //主技能
        var curSkillSourceSkill : int = CSkillUtil.getMainSkill( sourceSkillID );//curSkillData.RootSkill;
        var nexSkillSourceSkill : int = CSkillUtil.getMainSkill(targetSkillID );//nextSkillData.RootSkill;

        var pComUtility : CComponentUtility;
        var skillCaster : CSkillCaster = skillOwner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        pComUtility = skillCaster.pComUtility;

        var aiComponet : CAIComponent = m_pSkillOwner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        //大招能够打断一切
        if ( skillType == ESkillType.SKILL_SPOWER ) {
            //同是大招不能打断
            if ( curSkillType == ESkillType.SKILL_SPOWER && skillCastType == ECastType.NORMAL ) {
                CSkillDebugLog.logTraceMsg( "**覆盖判断：不能打断大招* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                CAILog.warningMsg( "**覆盖判断：不能打断大招* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                return false;
            }

            if ( skillCastType == ECastType.NORMAL &&  _isOnCanNotDrive() ) {
                CSkillDebugLog.logTraceMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                CAILog.warningMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                return false;
            }

            if ( skillCastType != ECastType.CHAIN )
                pComUtility.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL, null , [sourceSkillID]) );
            CSkillDebugLog.logTraceMsg( "**覆盖判断：大招打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            return true;
        }

        //普通技能自己不能覆盖
        if ( sourceSkillID == targetSkillID ) {

            CSkillDebugLog.logTraceMsg( "**覆盖判断：普通技能不能自己打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            CAILog.warningMsg( "**覆盖判断：普通技能不能自己打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
            return false;
        }

        if ( curSkillType == ESkillType.SKILL_SPOWER && ( skillType != ESkillType.SKILL_SPOWER ) ) {
            CSkillDebugLog.logTraceMsg( "**覆盖判断：技能不能打断大招技能* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            CAILog.warningMsg( "**覆盖判断：技能不能打断大招技能* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
            return false;
        }
        //(当前主技能一样的前提下)技能链技能能打断其它普通技能或者其他技能链技能
        if ( ( curSkillCastType == ECastType.NORMAL || curSkillCastType == ECastType.CHAIN ) && skillCastType == ECastType.CHAIN ) {

//            if( curSkillSourceSkill != nexSkillSourceSkill ) {
//                CSkillDebugLog.logTraceMsg( "**覆盖判断：技能链非同属当前的主技能 链技能不能打断当前主技能* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
//                return false;
//            }

            CSkillDebugLog.logTraceMsg( "**覆盖判断：技能链技能能打断其它技能* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            return true;
        }

        //技能链——》主动技
        {
            if ( curSkillType == ESkillType.SKILL_NORMAL && skillType == ESkillType.SKILL_NORMAL && curSkillCastType == ECastType.CHAIN && skillCastType == ECastType.NORMAL ) {
                if ( targetSkillID == curSkillSourceSkill ) {
                    CSkillDebugLog.logTraceMsg( "**覆盖判断：当前技能链的主技能一样 不能释放* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                    CAILog.warningMsg( "**覆盖判断：当前技能链的主技能一样 不能释放* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                    return false;
                }

                //在不可打断状态下不能取消
                {
                    if ( _isOnCanNotDrive() ) {
                        CSkillDebugLog.logTraceMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                        CAILog.warningMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                        return false;
                    }
                }

                if ( pComUtility.boHitSomeBody ) {
                    pComUtility.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL, null, [ sourceSkillID ] ) );

                    CSkillDebugLog.logTraceMsg( "**覆盖判断：技能链技能击中对方后可以被其它主动技能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                    return true;
                }
                else {
                    CSkillDebugLog.logTraceMsg( "技能不能被打断，前个技能未击中不能执行打断逻辑 , preID " + sourceSkillID + ", nextID : " + targetSkillID );
                    CAILog.warningMsg( "技能不能被打断，前个技能未击中不能执行打断逻辑 , preID " + sourceSkillID + ", nextID : " + targetSkillID, aiComponet.objId );
                    return false;
                }
            }
        }

        //主动技能->主动技 ，之间能否打断，击中可以打断 否则不能
        {
            if ( curSkillType == ESkillType.SKILL_NORMAL && skillType == ESkillType.SKILL_NORMAL
                    && curSkillCastType == ECastType.NORMAL && skillCastType == ECastType.NORMAL ) {

                {
                    if ( _isOnCanNotDrive() ) {
                        CSkillDebugLog.logTraceMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                        CAILog.warningMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                        return false;
                    }
                }

                if ( pComUtility.boHitSomeBody && sourceSkillID != targetSkillID ) {
                    pComUtility.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL, null, [ sourceSkillID ] ) );
                    CSkillDebugLog.logTraceMsg( "**覆盖判断：普通技能击中对方后可以被其它技能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );

                    return true;
                }
                else {
                    CSkillDebugLog.logTraceMsg( "**覆盖判断：普通技能未击中对方不可以被其它技能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                    CAILog.warningMsg( "**覆盖判断：普通技能未击中对方不可以被其它技能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                    return false;
                }
                return true;
            }
        }

        //普攻可以被技能打断
        if ( curSkillType == ESkillType.SKILL_HIT && skillType == ESkillType.SKILL_NORMAL ) {
            if ( _isOnCanNotDrive() ) {
                CSkillDebugLog.logTraceMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
                CAILog.warningMsg( "**覆盖判断：当前处于stateboard处于不可打断状态 preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
                return false;
            }

            CONFIG::debug {
                Foundation.Log.logTraceMsg( "**覆盖判断：普攻被技能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            }
            if ( skillCastType != ECastType.CHAIN )
                pComUtility.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_PUCANCEL, null , [sourceSkillID]) );
            return true;
        }

        //普攻二段3段击中目标出去才能被打断
        if ( curSkillType == ESkillType.SKILL_HIT && ESkillType.SKILL_HIT == skillType && skillCastType == ECastType.CHAIN ) {// && skillContext.boHitEventDispacte){
            CONFIG::debug {
                Foundation.Log.logTraceMsg( "**覆盖判断：普攻技能之间可以打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
            }
            return true;
        }

        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**覆盖判断：不能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID );
        }
        CAILog.warningMsg( "**覆盖判断：不能打断* preID ：" + sourceSkillID + ",nextID : " + targetSkillID, aiComponet.objId );
        return false;

    }

    private function _isOnCanNotDrive() : Boolean {
        {
            var pStateBoard : CCharacterStateBoard = skillOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if ( pStateBoard && pStateBoard.getValue( CCharacterStateBoard.CANOT_DRIVE ) ) {
                return true;
            }
        }
        return false;
    }

    private var m_chainTree : CStaticChain;
    private var m_pSkillOwner : CGameObject;
}
}
