//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/11.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CMath;

import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;

import kof.game.core.CGameComponent;
import kof.table.Damage;

/**
 * 占中属性计算
 */
public class CFightProperty extends CGameComponent implements IUpdatable{
    public function CFightProperty() {
        super( "fightProperty" );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onExit() : void {
        super.onExit();
        m_fightHP = 0.0;
        m_fightDamage = 0.0;
    }

    public function update( delta : Number ) : void {

    }

    public function updateFightHP( increaseSkillFactor : int ,  increaseSkillConst : int ) : void
    {
        var originalHp : int = characterProperty.HP;
        m_fightHP = originalHp * ( 1 + increaseSkillFactor / TENTHOU ) + increaseSkillConst;
    }

    /**
     * 实际攻击值 =（攻方战前攻击 +攻方技能加成固定值 - 受方技能减少固定值）*（1 + (攻方技能加成攻击 - 受方技能减少攻击)/10000）
     * @param increaseFactor  攻方技能加成攻击
     * @param decreaseFactor 受方技能减少攻击
     * @param increaseConst  攻方技能加成固定值
     * @param decreaseConst 受方技能减少固定值
     */
    public function updateFightAttack( increaseFactor : int , decreaseFactor : int , increaseConst : int , decreaseConst : int ): void
    {
        var originalAttack : int = characterProperty.Attack;
        m_fightDamage = ( originalAttack + increaseConst - decreaseConst ) * ( 1 +  ( increaseFactor - decreaseFactor ) / TENTHOU);
    }

    public function updateFightDefense( increaseFactor : int , decreaseFactor : int , increaseConst : int , decreaseConst : int ) : void
    {
        var originaDefense : int = characterProperty.Defense;
        m_fightDefense = ( originaDefense + increaseConst - decreaseConst ) * ( 1 +  ( increaseFactor - decreaseFactor ) / TENTHOU);
    }

    /**
     * 实际伤害加成万分比 = (攻方战前伤害加成 - 受方战前伤害减免+ 攻方技能伤害加成 - 受方技能伤害减少)/10000
     * @param decreaseFactor  受方战前伤害减免
     * @param skillIncreaseFactor 攻方技能伤害加成
     * @param skillDecreaseFactor 受方技能伤害减少
     */
    public function updatefightDamageEnhance(  decreaseFactor : int , skillIncreaseFactor : int , skillDecreaseFactor : int ) : void
    {
        var originalDamageEnhance : int = characterProperty.HurtAddChance;//已经是万分比
        m_fightDamageEnhance  = ( originalDamageEnhance - decreaseFactor + skillIncreaseFactor - skillDecreaseFactor) / TENTHOU;
    }

    //fixme 职业克制常亮 咱无考虑先
    public function updatefightDamageJobEnhance( increaseFactor : int , decreaseFactor : int , skillIncreaseFactor : int , skillDecreaseFactor : int ) : void
    {
        //职业克制伤害加成万分比 =(攻方战前职业克制伤害加成 - 受方职业克制伤害减免 + 攻方技能职业克制伤害加成 - 受方技能职业克制伤害减免）/10000
        m_fightDamageJobEnhance = (increaseFactor - decreaseFactor + skillIncreaseFactor - skillDecreaseFactor) / TENTHOU;
    }

    /**
     * 实际格挡减伤万分比 = max[(受方格挡减伤 - 攻方碾压格挡)/10000, 0]
     * @param decreaseFactor  受方格挡减伤
     */
    public function updatefightBlockHurtChance( decreaseFactor : int , rollerIncreFactor : int ) : void
    {
        var attakerRollerBlockChance : int = characterProperty.RollerBlockChance;
        attakerRollerBlockChance += rollerIncreFactor;
        m_fightBlockHurtChance = CMath.max(decreaseFactor  - attakerRollerBlockChance, 0) / TENTHOU;
    }

    /**
     * 计算实际暴击率万分比 = max[(攻方暴击 - 受方抗暴)/10000 ，0]
     * @param increaseFactor  攻方暴击（可能有buff加成）
     * @param decreaseFactor  受方暴击抵抗
     */
    public function updatefightCritChance( increaseFactor : int , decreaseFactor : int )  : void
    {
        m_fightCritChance =  CMath.max( increaseFactor  - decreaseFactor  , 0) / TENTHOU;
    }

    /**
     * 实际暴击伤害万分比 = max【最小暴击伤害，min[攻方暴击伤害 - 受方暴伤抵抗 + 攻方技能暴击伤害加成 - 受方技能暴伤抵抗加成, 最大暴击伤害]】/10000
     * @param decreaseFactor  受方暴伤抵抗
     * @param skillIncreaseFactor    攻方技能暴击伤害加成
     * @param skillDecreaseFactor 受方技能暴伤抵抗加成
     */
    public function updatefightCritHurtChance( decreaseFactor : int , skillIncreaseFactor : int , skillDecreaseFactor: int ) : void
    {
        var oriCritHurt : int = characterProperty.CritHurtChance;
        var maxCritChance : int = characterProperty.maxStrikeAttackChance;

        m_fightCritHurtChance = CMath.max( 0 ,  CMath.min( oriCritHurt - decreaseFactor + skillIncreaseFactor - skillDecreaseFactor , maxCritChance ) ) / TENTHOU;
    }

    /**
     * 实际破招伤害万分比=（破招伤害+技能破招伤害）/10000
     * @param increaseSkillFactor 攻方技能破招伤害
     */
    public function updatefightExCounterAttack( increaseSkillFactor : int )  : void
    {
        var globalCounterAttack : int = characterProperty.CounterAttackChance;
        m_fightExCounterAttack = ( globalCounterAttack + increaseSkillFactor ) / TENTHOU;
    }

    //get
    [inline]
    internal function get fightHP() : int {
        return m_fightHP;
    }

    [inline]
    internal function get fightDamage() : int {
        return m_fightDamage;
    }

    [inline]
    internal function get fightDefense() : int {
        return m_fightDefense;
    }

    [inline]
    internal function get fightDamageEnhance() : Number {
        return m_fightDamageEnhance;
    }

    [inline]
    internal function get fightDamageJobEnhance() : Number
    {
        return m_fightDamageJobEnhance;
    }

    [inline]
    internal function get fightBlockHurtChance() : Number
    {
        return m_fightBlockHurtChance;
    }

    [inline]
    internal function get fightCritChance() : Number
    {
        return m_fightCritChance;
    }

    [inline]
    internal function get fightCritHurtChance() : Number
    {
        return m_fightCritHurtChance;
    }

    [inline]
    internal function get fightExCounterAttack() : Number
    {
        return m_fightExCounterAttack;
    }

    internal function get fightTrueDamage() : int {
        return characterProperty.TrueDamage;
    }

    internal  function get fightTrueResist() : int {
        return characterProperty.TrueResist;
    }

    [inline]
    internal function get characterProperty() : CCharacterProperty
    {
        return owner.getComponentByClass( CCharacterProperty , true )  as CCharacterProperty;
    }

    internal function get pBuffModifierProperty() : CBuffAttModifiedProperty
    {
        return owner.getComponentByClass( CBuffAttModifiedProperty , true ) as CBuffAttModifiedProperty;
    }


    private var m_fightHP : int ;
    private var m_fightDamage :int ;
    private var m_fightDefense : int ;
    private var m_fightDamageEnhance : Number ; //伤害加成
    private var m_fightDamageJobEnhance : Number;//职业加成
    private var m_fightBlockHurtChance : Number ;//格挡减伤
    private var m_fightCritChance : Number ; //暴击率
    private var m_fightCritHurtChance : Number ;//暴击伤害
    private var m_fightExCounterAttack :Number ;//破招伤害

    public static const TENTHOU : int = 10000.0;
}
}
