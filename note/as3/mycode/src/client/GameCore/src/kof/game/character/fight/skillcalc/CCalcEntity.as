//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/30.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.*;

import QFLib.Interface.IUpdatable;

import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;

import kof.game.character.fight.skill.CSimulateSkillCaster;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.core.CGameObject;
import kof.table.Damage;
import kof.table.Monster.EMonsterType;

/**
 * to calc  all kind of properties.
 */
public class CCalcEntity implements IUpdatable {

    public function CCalcEntity( owner : CGameObject ) {
        m_pOwner = owner;
    }

    public function update( delta : Number ) : void {

    }

    /**
     *
     * @param value :the DefensePower  going to calc
     * @return kof.game.character.fight.skillcalc.ECalcStateRet enum
     * @boCal 是否计算
     */
    public function calcDefensePower( value : int, isPercent : Boolean = false, boCal : Boolean = true ) : int {
        if ( m_pSimulatorSkillCastor && m_pSimulatorSkillCastor.boIgnoreDP )
            return ECalcStateRet.E_BAN;

        if ( isPercent )
            value = pCharacterProperty.MaxDefensePower * value / 100;

        var ret : int = ECalcStateRet.E_BAN;
        var tem : int = pCharacterProperty.DefensePower;
        tem += value;

        if ( tem >= 0 ) {
            if ( pCharacterProperty.DefensePower == 0 )
                ret = ECalcStateRet.E_BAN;
            else
                ret = ECalcStateRet.E_PASS;

            if ( boCal )
                pCharacterProperty.DefensePower = tem > pCharacterProperty.MaxDefensePower ? pCharacterProperty.MaxDefensePower : tem;

        }
        else if ( tem < 0 ) {

            if ( pCharacterProperty.DefensePower == 0 ) {
                ret = ECalcStateRet.E_BAN;
            }
            else if ( pCharacterProperty.DefensePower >= 0 ) {
                ret = ECalcStateRet.E_TRANSFER;
            }
            else {
                ret = ECalcStateRet.E_BAN;
            }

            if ( boCal )
                pCharacterProperty.DefensePower = 0;
        }
        return ret;
    }

    /**
     * check if it reach the max DP.
     */
    final public function get boIsMaxDefensePower() : Boolean {
        return pCharacterProperty.DefensePower == pCharacterProperty.MaxDefensePower;
    }

    final public function get boIsMaxRagePower() : Boolean {
        return pCharacterProperty.RagePower == pCharacterProperty.MaxRagePower;
    }

    final public function get boIsZeroDefensePower() : Boolean {
        return pCharacterProperty.DefensePower == 0;
    }

    /**
     *
     * @param value the attackPower going to calc
     * @return the ECalcStateRet Enum
     */
    public function calcAttackPower( value : Number, isPercent : Boolean = false, boCal : Boolean = true ) : int {
        if ( m_pSimulatorSkillCastor && m_pSimulatorSkillCastor.boIgnoreAP )
            return ECalcStateRet.E_PASS;

        if ( isPercent )
            value = pCharacterProperty.MaxAttackPower * value / 100;

        var ret : int = ECalcStateRet.E_BAN;
        var temp : int = pCharacterProperty.AttackPower;
        temp += value;

        if ( temp >= 0 ) {
            if ( boCal )
                pCharacterProperty.AttackPower = temp > pCharacterProperty.MaxAttackPower ? pCharacterProperty.MaxAttackPower : temp;
            ret = ECalcStateRet.E_PASS;
        }

        if ( temp < 0 ) {
            ret = ECalcStateRet.E_BAN;
        }

        return ret;
    }

    /**
     * 怒气
     * @param value
     * @param isPercent
     * @param boCal
     * @return
     */
    public function calcRagePower( value : Number, isPercent : Boolean = false, boCal : Boolean = true ) : int {
        if ( m_pSimulatorSkillCastor && m_pSimulatorSkillCastor.boIgnoreRP )
            return ECalcStateRet.E_PASS;

        if ( isPercent )
            value = pCharacterProperty.MaxRagePower * value / 100;

        var ret : int = ECalcStateRet.E_BAN;
        var temp : int = pCharacterProperty.RagePower;
        temp += value;

        if ( temp >= 0 ) {
            if ( boCal )
                pCharacterProperty.RagePower = temp > pCharacterProperty.MaxRagePower ? pCharacterProperty.MaxRagePower : temp;
            ret = ECalcStateRet.E_PASS;
        }

        if ( temp < 0 ) {
            ret = ECalcStateRet.E_BAN;
        }

        return ret;
    }

    /**
     *  if attackPower enough to cast skill
     * @param value
     */
    public function isEnoughAttackPower( value : int ) : Boolean {
        CSkillDebugLog.logTraceMsg( "技能攻击值消耗为 :  " + value + "当前攻击值 ： " + pCharacterProperty.AttackPower );
        if ( m_pSimulatorSkillCastor && m_pSimulatorSkillCastor.boIgnoreAP )
            return true;

        return pCharacterProperty.AttackPower >= value;
    }

    public function checkRagePower() : Boolean {

        if ( m_pSimulatorSkillCastor && m_pSimulatorSkillCastor.boIgnoreRP ) return true;
        var ret : Boolean = pCharacterProperty.RagePower >= (pCharacterProperty.MaxRagePower / pCharacterProperty.maxRageCount);
        if ( ret )
            CSkillDebugLog.logTraceMsg( "EVALUATOR : 大招怒气值消耗足够" );
        else
            CSkillDebugLog.logTraceMsg( "EVALUATOR : 大招怒气值消耗不够！！" );
        return ret;
    }

    public function increaseRagePowerByType( type : int, ... arg ) : void {
        if( !bEnableRestoreRagePower )
            return;
        var param0 : *;
        var finalAddRagePower : int = 0;
        if ( arg ) {
            param0 = arg[ 0 ];
        }
        var cnt : int;
        switch ( type ) {
            case ERPRecoveryType.TYPE_BEINGHITTED:
                finalAddRagePower = increaseRagePowerWhenBeingHitted();
                break;
            case ERPRecoveryType.TYPE_COMBO:
                finalAddRagePower = increaseRagePowerWhenCombo();
                break;
            case ERPRecoveryType.TYPE_COMSUME_AP:
                var comsumeAp : int = int( param0 );
                finalAddRagePower = increaseRagePowerWhenComsueAP( comsumeAp );
                break;
            case ERPRecoveryType.TYPE_DAMAGE_TARGET:
                var damageToTarget : int = int( param0 )
                finalAddRagePower = increaseRagePowerWhenDamageTarget( damageToTarget );
                break;
            case ERPRecoveryType.TYPE_DAMAGED:
                var damaged : int = int( param0 );
                finalAddRagePower = increaseRagePowerByDamaged( damaged );
                break;
            case ERPRecoveryType.TYPE_KILL_TARGET:
                var target : CGameObject = param0 as CGameObject;
                var enhence : int;
                enhence = increaseRagePowerWhenKillTarget( target );
                var baseRestore : int = pCharacterProperty.RageRestoreWhenKillTarget;
                finalAddRagePower = baseRestore * ( enhence  / 10000 );
                break;
            case ERPRecoveryType.TYPE_MATE_DEAD:
                finalAddRagePower = increaseRagePowerWhenMateDead();
                break;
            case ERPRecoveryType.TYPE_SKILL_HIT_TARGET:
                cnt = int( param0 );
                finalAddRagePower = increaseRagePowerWhenSkillHit( cnt );
                break;
            case ERPRecoveryType.TYPE_SPELL_SKILL:
                cnt = int( param0 );
                finalAddRagePower = increaseRagePowerWhenSpellSkill( cnt );
                break;
            default:
                CSkillDebugLog.logTraceMsg( "has not define rage Power recovery type =" + type );
        }

        var finalRagePower : int = finalAddRagePower + pCharacterProperty.RagePower;
        pCharacterProperty.RagePower = Math.min( finalRagePower, pCharacterProperty.MaxRagePower );
    }

    /**受伤量回复怒气*/
    protected function increaseRagePowerByDamaged( damage : int ) : int {
        var buffEnhance : int = 0;
        if ( buffAddModifer )
            buffEnhance = buffAddModifer.RageRestoreWhenDamaged;

        var iVal : int = (pCharacterProperty.RageRestoreWhenDamaged + buffEnhance) * ( damage / pCharacterProperty.MaxHP );
        return iVal;
    }

    /**输出量回复怒气*/
    protected function increaseRagePowerWhenDamageTarget( damageOutput : int ) : int {
        var buffEnhance : int = 0;
        if ( buffAddModifer )
            buffEnhance = buffAddModifer.RageRestoreWhenDamageTarget;

        var iVal : int = (pCharacterProperty.RageRestoreWhenDamageTarget + buffEnhance ) * ( damageOutput / pCharacterProperty.MaxHP );
        return iVal;
    }

    /**消耗攻击值回复怒气*/
    protected function increaseRagePowerWhenComsueAP( value : int ) : int {
        var iVal : int = pCharacterProperty.RageRestoreAttackPowerConsume * value;
        return iVal;
    }

    /**连击一定数量回复怒气*/
    protected function increaseRagePowerWhenCombo() : int {
        var iVal : int = pCharacterProperty.RageRestoreWhenCombo;
        return iVal;
    }

    /**释放技能回复*/
    protected function increaseRagePowerWhenSpellSkill( value : int ) : int {
        var iVal : int = value;
        return iVal;
    }

//    /**技能击中*
    protected function increaseRagePowerWhenSkillHit( value : int ) : int {
        return value;
    }

    protected function increaseRagePowerWhenMateDead() : int {
        var iVal : int = pCharacterProperty.RageRestoreWhenMateKilled;
        return iVal;
    }

    protected function increaseRagePowerWhenKillTarget( target : CGameObject ) : int {
        var buffEnhance : int;
        if ( buffAddModifer )
            buffEnhance = buffAddModifer.RageRestoreWhenKillTarget;

        if ( CCharacterDataDescriptor.isMonster( target.data ) ) {
            var monsterProperty : CMonsterProperty = target.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
            if ( monsterProperty.monsterType == EMonsterType.EXTRAME_BOSS ) {
                return pCharacterProperty.bossRageRestoreRate + buffEnhance;
            } else if ( monsterProperty.monsterType == EMonsterType.NORMAL ) {
                return pCharacterProperty.commonRageRestoreRate + buffEnhance;
            } else if ( monsterProperty.monsterType == EMonsterType.BOSS || monsterProperty.monsterType == EMonsterType.WORLD_BOSS ) {
                return pCharacterProperty.eliteRageRestoreRate + buffEnhance;
            }
        } else if ( CCharacterDataDescriptor.isPlayer( target.data ) ) {
            return pCharacterProperty.playerRageRestoreRate + buffEnhance;
        }
        return 0;
    }

    final private function get buffAddModifer() : CBuffAttModifiedProperty {
        if ( m_pOwner )
            return m_pOwner.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;
        return null;
    }

    /**受击回复怒气*/
    protected function increaseRagePowerWhenBeingHitted() : int {
        return pCharacterProperty.RageRestoreWhenHitted;
    }

    final public function get boIsMaxAttackPower() : Boolean {
        return pCharacterProperty.AttackPower == pCharacterProperty.MaxAttackPower;
    }

    final public function get boIsZeroAttackPower() : Boolean {
        return pCharacterProperty.AttackPower == 0;
    }

    final public function get pCharacterProperty() : CCharacterProperty {
        if ( m_pOwner )
            return m_pOwner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        return null;
//        return m_pICharacterProperty;
    }

    final public function set pSimulatorSkillCastor( value : CSimulateSkillCaster ) : void {
        m_pSimulatorSkillCastor = value;
    }

    public function set bEnableRestoreRagePower( value : Boolean ) : void {
        m_bEnableRestoreRagePower = value;
    }

    public function get bEnableRestoreRagePower() : Boolean{
        return m_bEnableRestoreRagePower;
    }

    private var m_pSimulatorSkillCastor : CSimulateSkillCaster;
    private var m_pOwner : CGameObject;
    private var m_bEnableRestoreRagePower : Boolean;

}
}
