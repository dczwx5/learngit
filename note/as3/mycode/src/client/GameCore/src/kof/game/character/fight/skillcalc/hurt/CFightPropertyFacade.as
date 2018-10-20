//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/12.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Interface.IDisposable;

import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
import kof.game.character.fight.skill.property.CSkillItemProperty;
import kof.game.character.fight.skill.property.ISkillItemProperty;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;

import kof.game.core.CGameObject;
import kof.table.Damage;
import kof.table.Damage;

/**
 * 战前属性计算
 */
public class CFightPropertyFacade implements IDisposable {

    public function CFightPropertyFacade( owner : CGameObject ) {
        m_owner = owner;
    }

    public function dispose() : void {

    }

    /**
     * 获取战中生命
     * @param damageInfo   技能数据
     * @param target   目标
     * @return
     */
    public function calFightHP( damageInfo : Damage, target : CGameObject ) : int {
        /**fixme here will add with buff */
        var hpFactor : Number = 0;
        var skillFactor : Number = 0;

        hpFactor = _pBuffModifierProperty.HP;

        {
            pFightProperty.updateFightHP( hpFactor, skillFactor );
        }

        return pFightProperty.fightHP;
    }

    /**
     * 获取战中伤害
     * @param damageInfo 技能信息
     * @param target  目标
     * @return
     */
    public function calFightAttack( damageInfo : Damage, target : CGameObject ) : int {
        var increaseFactor : Number;
        var decreaseFactor : Number;
        var increConst : int;
        var decreConst : int;

        var buffAtkEnhence : int = pBuffModifierProperty.Attack;
        var buffAtkPercentEnhence : int = pBuffModifierProperty.getPercentProperty( "Attack" );


        increaseFactor = buffAtkPercentEnhence;
        increConst = buffAtkEnhence;

        decreaseFactor = 0;
        decreConst = 0;

        {
            pFightProperty.updateFightAttack( increaseFactor, decreaseFactor, increConst, decreConst );
        }

        return pFightProperty.fightDamage;
    }

    /**
     * 获取战中防御
     * @param target
     * @param damageInfo
     * @return
     */
    public function calFightDefense( target : CGameObject ) : int {
        var increaseFactor : int;
        var decreaseFactor : int;
        var increConst : int;
        var decreConst : int;

        /**fixme here will add with buff */
        var buffDefEnhence : int = pBuffModifierProperty.Defense;
        var buffDefPercentEnhence : int = pBuffModifierProperty.getPercentProperty( "Defense" );

        increaseFactor = buffDefPercentEnhence;
        increConst = buffDefEnhence;
        {
            pFightProperty.updateFightDefense( increaseFactor, decreaseFactor, increConst, decreConst );
        }

        return pFightProperty.fightDefense;
    }

    /**
     * 伤害加成
     * @param target
     * @param damageInfo
     * @return
     */
    public function calFightDamageEnhance( target : CGameObject, damageInfo : Damage ) : Number {
        var increaseFactor : int;
        var decreaseFactor : int;
        var skillDecreFactor : int;


        var pTargetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        decreaseFactor = pTargetProperty.HurtReduceChance;

        var pTargetBuff : CBuffAttModifiedProperty = target.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;

        /**fixme here will add with buff */
        skillDecreFactor = 0;
        increaseFactor = 0;

        var buffEnhanceFator : int = pBuffModifierProperty.HurtAddChance;//pBuffModifierProperty.getPercentProperty("HurtAddChance");
        increaseFactor = buffEnhanceFator;

        var targetBuffDecreaseFactor : int = pTargetBuff.HurtReduceChance;//getPercentProperty("HurtReduceChance");
        skillDecreFactor = targetBuffDecreaseFactor;


        {
            pFightProperty.updatefightDamageEnhance( decreaseFactor, increaseFactor, skillDecreFactor );
        }

        return pFightProperty.fightDamageEnhance;
    }

    //fixme 职业克制暂时没加
    public function calFightDamageJobEnhance( target : CGameObject ) : Number {
        var increaseFactor : int;
        var decreaseFactor : int;
        var buffIncreaseFactor : int;
        var buffDescreaseFactor : int;

        var pRelation : CProfessionRelation = pProfessionRelation;
        var targetRelation : CProfessionRelation = target.getComponentByClass( CProfessionRelation, true ) as CProfessionRelation;
        var pTargetBuff : CBuffAttModifiedProperty = target.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;

        if ( pRelation && targetRelation ) {
            increaseFactor = pRelation.getAdvantageEnhance( targetRelation.profession );
            decreaseFactor = targetRelation.getReduceAdvantageEnhance( pRelation.profession );
        }

        if( pBuffModifierProperty && pTargetBuff ) {
            var buffEnhanceFactor : int = pBuffModifierProperty.getAddJobEnhance( pRelation.profession, targetRelation.profession );
            buffIncreaseFactor = buffEnhanceFactor;

            var targetBuffDecreaseFactor : int = pTargetBuff.getReduceJobEnhance( pRelation.profession, targetRelation.profession );
            buffDescreaseFactor = targetBuffDecreaseFactor;
        }

        {
            pFightProperty.updatefightDamageJobEnhance( increaseFactor, decreaseFactor, buffIncreaseFactor, buffDescreaseFactor );
        }

        return pFightProperty.fightDamageJobEnhance;
    }

    internal function get pProfessionRelation() : CProfessionRelation {
        return m_owner.getComponentByClass( CProfessionRelation, true ) as CProfessionRelation;
    }

    /**
     * 格挡减伤万分比 小数
     * @param target
     * @return
     */
    public function calFightBlockHurtChance( target : CGameObject ) : Number {
        var decreaseFactor : int;
        var rollerIncreaseFactor : int;
        var pTargetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pTargetBuff : CBuffAttModifiedProperty = target.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;

        decreaseFactor = pTargetProperty.BlockHurtChance;
        decreaseFactor = decreaseFactor + pTargetBuff.getPercentProperty( "BlockHurtChance" );

        var buffEnhanceFator : int = pBuffModifierProperty.getPercentProperty( "RollerBlockChance" );

        rollerIncreaseFactor = buffEnhanceFator;

        {
            pFightProperty.updatefightBlockHurtChance( decreaseFactor, rollerIncreaseFactor );
        }

        return pFightProperty.fightBlockHurtChance;
    }

    /**
     * 暴击率
     * @param target
     * @return
     */
    public function getFightCritChance( damageInfo : Damage, target : CGameObject ) : Number {
        var pTargetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pTargetBuff : CBuffAttModifiedProperty = target.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;

        var strikeCritChance : int = pTargetProperty.DefendCritChance;
        strikeCritChance += pTargetBuff.getPercentProperty( "DefendCritChance" );

        //加上技能的暴击率
        var attackCritChance : int = pCharacterProperty.CritChance + damageInfo.ExCriticalRate;

        attackCritChance += pTargetBuff.getPercentProperty( "CritChance" );
        //fixme 后面受方的也有可能加上buff之类的
        {
            pFightProperty.updatefightCritChance( attackCritChance, strikeCritChance );
        }

        return pFightProperty.fightCritChance;
    }

    /**
     * 暴击伤害万分比
     */
    public function getFightCritHurtChance( damageInfo : Damage, target : CGameObject ) : Number {
        var decreCritDefendChance : int;
        var skillIncreCritChance : int;
        var skillDecCritDefenseChance : int;

        var pTargetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pTargetBuff : CBuffAttModifiedProperty = target.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;

        decreCritDefendChance = pTargetProperty.CritDefendChance;
        skillDecCritDefenseChance = pTargetBuff.getPercentProperty( "CritDefendChance" );

        /**fixme here will add with buff */
        skillIncreCritChance = damageInfo.ExCriticalAttack;
        skillIncreCritChance += pBuffModifierProperty.getPercentProperty( "ExCriticalAttack" );

        {
            pFightProperty.updatefightCritHurtChance( decreCritDefendChance, skillIncreCritChance, skillDecCritDefenseChance );
        }

        return pFightProperty.fightCritHurtChance;
    }

    /**
     * 破招加成
     * @param damageInfo
     * @param target
     * @return
     */
    public function getFightExCounterAttack( damageInfo : Damage, target : CGameObject, skillUpInf : ISkillItemProperty ) : Number {
        var skillExCounterAttack : int = damageInfo.ExCounterAttack;
        if ( skillUpInf )
            skillExCounterAttack = skillExCounterAttack + skillUpInf.ExCounterAttack;

        skillExCounterAttack += pBuffModifierProperty.getPercentProperty( "CounterAttackChance" );

        {
            pFightProperty.updatefightExCounterAttack( skillExCounterAttack );
        }

        return pFightProperty.fightExCounterAttack;
    }

    final private function get pFightProperty() : CFightProperty {
        return m_owner.getComponentByClass( CFightProperty, true ) as CFightProperty;
    }

    final private function get pCharacterProperty() : CCharacterProperty {
        return m_owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
    }

    final private function get _pBuffModifierProperty() : ICharacterProperty {
        return m_owner.getComponentByClass( CBuffAttModifiedProperty, true ) as ICharacterProperty;
    }

    internal function get pBuffModifierProperty() : CBuffAttModifiedProperty {
        return m_owner.getComponentByClass( CBuffAttModifiedProperty, true ) as CBuffAttModifiedProperty;
    }

    private var m_owner : CGameObject;
}
}
