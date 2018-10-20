//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;
import QFLib.Utils.Debug.Debug;

import flash.utils.Dictionary;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CSubscribeBehaviour;
import kof.table.PlayerGlobal;

/**
 * @author Eddy, Jeremy
 */
public class CCharacterProperty extends CSubscribeBehaviour implements ICharacterProperty,IUpdatable {

    private var m_iUpdateIndex : int;
    private var m_pPropertyDic : Dictionary;
    protected var m_theFightProperty : Object;

    public function CCharacterProperty() {
        super( "property", true );
    }

    /**-----------------------------
     * Basic property
     ------------------------------*/
    /** 角色ID */
    public function get ID() : Number {
        return CCharacterDataDescriptor.getID( owner.data );
    }

    public function get nickName() : String {
        return CCharacterDataDescriptor.getNickName( owner.data );
    }

    public function set nickName( value : String ) : void {
        return CCharacterDataDescriptor.setNickName( owner.data, value );
    }

    public function get appellation() : String {
        return CCharacterDataDescriptor.getAppellation( owner.data );
    }

    public function set appellation( value : String ) : void {
        return CCharacterDataDescriptor.setAppellation( owner.data, value );
    }

    public function get prototypeID() : int {
        return CCharacterDataDescriptor.getPrototypeID( owner.data );
    }

    public function updateFightProperty( data : Object ) : void {

    }

    /** 角色职业类型 */
    public function get profession() : int {
        return CCharacterDataDescriptor.getProfession( owner.data );
    }

    public function set profession( value : int ) : void {
        if ( this.profession == value )
            return;
        CCharacterDataDescriptor.setProfession( owner.data, value );
        setPropertyChanged( ECharacterConst.profession, value );
    }

    /** 角色资源路径 */
    public function get skinName() : String {
        return CCharacterDataDescriptor.getSkinName( owner.data );
    }

    public function set skinName( value : String ) : void {
        if ( this.skinName == value )
            return;
        CCharacterDataDescriptor.setSkinName( owner.data, value );
        setPropertyChanged( ECharacterConst.skinName, value );
    }

    public function set outsideName( value : String ) : void {
        if ( this.outsideName == value )
            return;
        data.outsideName = value;
        setPropertyChanged( ECharacterConst.outsideName, value );
    }

    public function get outsideName() : String {
        return data.outsideName;
    }

    public function set weapon( value : String ) : void {
        if ( this.weapon == value )
            return;
        data.weapon = value;
        setPropertyChanged( ECharacterConst.weapon, value );
    }

    public function get weapon() : String {
        return data.weapon;
    }

    public function get campID() : int {
        return int( data.campID );
    }

    public function set campID( value : int ) : void {
        if ( int( data.campID ) == value )
            return;
        data.campID = value;
        setPropertyChanged( ECharacterConst.campID, value );
    }

    /** 移动速度*/
    public function get moveSpeed() : int {
        return CCharacterDataDescriptor.getMoveSpeed( owner.data );
    }

    public function set moveSpeed( value : int ) : void {
        if ( this.moveSpeed == value )
            return;
        CCharacterDataDescriptor.setMoveSpeed( owner.data, value );
        setPropertyChanged( ECharacterConst.moveSpeed, value );
    }

    /** 角色自动战斗AI包ID */
    public function get aiID() : int {
        return CCharacterDataDescriptor.getAIID( owner.data );
    }

    /**-----------------------------
     * fight property
     ------------------------------*/
    /** 生命 */
    /** 生命 */
    public function get HP() : int {
        if ( !fightProperty ) {
            return 0;
        }
        return fightProperty.HP;
    }


    public function set HP( value : int ) : void {
        if ( this.HP == value )
            return;
        if ( fightProperty ) {
            if( value > fightProperty.HP)
            {
                Foundation.Log.logMsg("Wiere");
            }
            fightProperty.HP = value;
            setPropertyChanged( ECharacterConst.hp, value );
        }
    }

    /** 最大血量*/
    public function get MaxHP() : int {
        return fightProperty.MaxHP;
    }

    public function set MaxHP( value : int ) : void {
        if ( this.MaxHP == value )
            return;
        fightProperty.MaxHP = value;
        setPropertyChanged( ECharacterConst.maxHp, value );
    }

    /** 攻击 */
    public function get Attack() : int {
        return fightProperty.Attack;
    }

    public function set Attack( value : int ) : void {
        if ( fightProperty.Attack == value )
            return;
        fightProperty.Attack = value;
        setPropertyChanged( ECharacterConst.attack, value );
    }

    /** 防御 */
    public function get Defense() : int {
        return fightProperty.Defense;
    }

    public function set Defense( value : int ) : void {
        if ( fightProperty.Defense == value )
            return;
        fightProperty.Defense = value;
        setPropertyChanged( ECharacterConst.defense, value );
    }


    /** 命中率万分比*/
    public function get HitChance() : int {
        return fightProperty.HitChance;
    }

    public function set HitChance( value : int ) : void {
        if ( fightProperty.HitChance == value )
            return;
        fightProperty.HitChance = value;
        setPropertyChanged( ECharacterConst.hitChance, value );
    }

    /** 闪避率万分比 */
    public function get DodgeChance() : int {
        return fightProperty.DodgeChance;
    }

    public function set DodgeChance( value : int ) : void {
        if ( fightProperty.DodgeChance == value )
            return;
        fightProperty.DodgeChance = value;
        setPropertyChanged( ECharacterConst.dodgeChance, value );
    }

    /** 暴击率万分比 */
    public function get CritChance() : int {
        return fightProperty.CritChance;
    }

    public function set CritChance( value : int ) : void {
        if ( fightProperty.CritChance == value )
            return;
        fightProperty.CritChance = value;
        setPropertyChanged( ECharacterConst.critChance, value );
    }

    /** 抗暴率万分比*/
    public function get DefendCritChance() : int {
        return fightProperty.DefendCritChance;
    }

    public function set DefendCritChance( value : int ) : void {
        if ( fightProperty.DefendCritChance == value )
            return;
        fightProperty.DefendCritChance = value;
        setPropertyChanged( ECharacterConst.defendCritChance, value );
    }

    /** 暴击伤害万分比 */
    public function get CritHurtChance() : int {
        return fightProperty.CritHurtChance;
    }

    public function set CritHurtChance( value : int ) : void {
        if ( fightProperty.CritHurtChance == value )
            return;
        fightProperty.CritHurtChance = value;
        setPropertyChanged( ECharacterConst.critHurtChance, value );
    }

    /** 暴伤抵抗万分比 */
    public function get CritDefendChance() : int {
        return fightProperty.CritDefendChance;
    }

    public function set CritDefendChance( value : int ) : void {
        if ( fightProperty.CritDefendChance == value )
            return;
        fightProperty.CritDefendChance = value;
        setPropertyChanged( ECharacterConst.critDefendChance, value );
    }

    /** 格挡减伤万分比 */
    public function get BlockHurtChance() : int {
        return fightProperty.BlockHurtChance;
    }

    public function set BlockHurtChance( value : int ) : void {
        if ( fightProperty.BlockHurtChance == value )
            return;
        fightProperty.BlockHurtChance = value;
        setPropertyChanged( ECharacterConst.blockHurtChance, value );
    }

    /** 碾压格挡万分比 */
    public function get RollerBlockChance() : int {
        return fightProperty.RollerBlockChance;
    }

    public function set RollerBlockChance( value : int ) : void {
        if ( fightProperty.RollerBlockChance == value )
            return;
        fightProperty.RollerBlockChance = value;
        setPropertyChanged( ECharacterConst.rollerBlockChance, value );
    }

    /** 伤害加成万分比 */
    public function get HurtAddChance() : int {
        return fightProperty.HurtAddChance;
    }

    public function set HurtAddChance( value : int ) : void {
        if ( fightProperty.HurtAddChance == value )
            return;
        fightProperty.HurtAddChance = value;
        setPropertyChanged( ECharacterConst.hurtAddChance, value );
    }

    /** 伤害减免万分比 */
    public function get HurtReduceChance() : int {
        return fightProperty.HurtReduceChance;
    }

    public function set HurtReduceChance( value : int ) : void {
        if ( fightProperty.HurtReduceChance == value )
            return;
        fightProperty.HurtReduceChance = value;
        setPropertyChanged( ECharacterConst.hurtReduceChance, value );
    }

    /**破招伤害万分比*/
    public function set CounterAttackChance( value : int ) : void {
        if ( int( fightProperty.CounterAttackChance ) == value )
            return;
        fightProperty.CounterAttackChance = value;
        setPropertyChanged( ECharacterConst.counterAttackChance, value );
    }

    public function get CounterAttackChance() : int {
        return int( fightProperty.CounterAttackChance );
    }

    public function get AttackPower() : uint {
        return fightProperty.AttackPower;
    }

    public function set AttackPower( value : uint ) : void {
        if ( fightProperty.AttackPower == value )
            return;
        fightProperty.AttackPower = value;
        setPropertyChanged( ECharacterConst.attackPower, value );
    }

    public function get MaxAttackPower() : uint {
        return fightProperty.MaxAttackPower;
    }

    public function set MaxAttackPower( value : uint ) : void {
        if ( fightProperty.MaxAttackPower == value )
            return;
        fightProperty.MaxAttackPower = value;
        setPropertyChanged( ECharacterConst.maxAttackPower, value );
    }

    public function get AttackPowerRecoverSpeed() : int {
        return isNaN( fightProperty.AttackPowerRecoverSpeed ) ? 0 : fightProperty.AttackPowerRecoverSpeed;
    }

    public function set AttackPowerRecoverSpeed( value : int ) : void {
        if ( fightProperty.AttackPowerRecoverSpeed == value )
            return;
        fightProperty.AttackPowerRecoverSpeed = value;
        setPropertyChanged( ECharacterConst.attackPowerRecoverSpeed, value );
    }

    public function get DefensePower() : uint {
        return fightProperty.DefensePower;
    }

    public function set DefensePower( value : uint ) : void {
        if ( fightProperty.DefensePower == value )
            return;
        fightProperty.DefensePower = value;
        setPropertyChanged( ECharacterConst.defensePower, value );
    }

    public function get MaxDefensePower() : uint {
        return fightProperty.MaxDefensePower;
    }

    public function set MaxDefensePower( value : uint ) : void {
        if ( fightProperty.MaxDefensePower == value )
            return;
        fightProperty.MaxDefensePower = value;
        setPropertyChanged( ECharacterConst.maxDefensePower, value );
    }

    public function get DefensePowerRecoverCD() : int {
        return isNaN( fightProperty.DefensePowerRecoverCD ) ? 0 : fightProperty.DefensePowerRecoverCD;
    }

    public function set DefensePowerRecoverCD( value : int ) : void {
        if ( fightProperty.DefensePowerRecoverCD == value )
            return;
        fightProperty.DefensePowerRecoverCD = value;
        setPropertyChanged( ECharacterConst.defensePowerRecoverCD, value );
    }

    /** 怒气值 */
    public function get RagePower() : int {
        return int( fightProperty.RagePower );
    }

    /** @private */
    public function set RagePower( value : int ) : void {
        if ( int( fightProperty.RagePower ) == value )
            return;
        fightProperty.RagePower = value;
        setPropertyChanged( ECharacterConst.ragePower, value );
    }

    /** 最大怒气值 */
    public function get MaxRagePower() : int {
        return int( fightProperty.MaxRagePower );
    }

    /** @private */
    public function set MaxRagePower( value : int ) : void {
        if ( int( fightProperty.MaxRagePower ) == value )
            return;
        fightProperty.MaxRagePower = value;
        setPropertyChanged( ECharacterConst.maxRagePower, value );
    }

    /** 输出时恢复怒气值 */
    public function get RageRestoreWhenDamageTarget() : int {
        return int( fightProperty.RageRestoreWhenDamageTarget );
    }

    /** @private */
    public function set RageRestoreWhenDamageTarget( value : int ) : void {
        if ( int( fightProperty.RageRestoreWhenDamageTarget ) == value )
            return;
        fightProperty.RageRestoreWhenDamageTarget = value;
        setPropertyChanged( ECharacterConst.ragePowerRecoverByAttack, value );
    }

    /** 攻击时恢复怒气值 */
    public function get RagePowerRecoverSpeed() : int {
        return int( fightProperty.RagePowerRecoverSpeed );
    }

    /** @private */
    public function set RagePowerRecoverSpeed( value : int ) : void {
        if ( int( fightProperty.RagePowerRecoverSpeed ) == value )
            return;
        fightProperty.RagePowerRecoverSpeed = value;
        setPropertyChanged( ECharacterConst.ragePowerRecoverSpeed, value );
    }

    /** 攻击时恢复怒气值 */
    public function get RageRestoreWhenKillTarget() : int {
        return int( fightProperty.RageRestoreWhenKillTarget );
    }

    /** @private */
    public function set RageRestoreWhenKillTarget( value : int ) : void {
        if ( int( fightProperty.RageRestoreWhenKillTarget ) == value )
            return;
        fightProperty.RageRestoreWhenKillTarget = value;
        setPropertyChanged( ECharacterConst.rageRestoreWhenKillTarget, value );
    }

    /**受伤回复怒气*/
    public function get RageRestoreWhenDamaged() : int {
        return fightProperty.RageRestoreWhenDamaged;
    }

    public function set RageRestoreWhenDamaged( value : int ) : void {
        if ( fightProperty.RageRestoreWhenDamaged == value )
            return;
        fightProperty.RageRestoreWhenDamaged = value;
        setPropertyChanged( ECharacterConst.rageRestoreWhenDamaged, value );
    }

    /**消耗攻击值回复怒气*/
    public function get RageRestoreAttackPowerConsume() : int {
        return fightProperty.RageRestoreAttackPowerConsume;
    }

    public function set RageRestoreAttackPowerConsume( value : int ) : void {
        if ( fightProperty.RageRestoreAttackPowerConsume == value )
            return;
        fightProperty.RageRestoreAttackPowerConsume = value;
        setPropertyChanged( ECharacterConst.RageRestoreAttackPowerConsume, value );
    }

    /**每次被击打回复怒气*/
    public function get RageRestoreWhenHitted() : int {
        return fightProperty.RageRestoreWhenHitted;
    }

    public function set RageRestoreWhenHitted( value : int ) : void {
        if ( fightProperty.RageRestoreWhenHitted == value )
            return;
        fightProperty.RageRestoreWhenHitted = value;
        setPropertyChanged( ECharacterConst.RageRestoreWhenHitted, value );
    }

    /**连击n次回复怒气*/
    public function get RageRestoreWhenCombo() : int {
        return fightProperty.RageRestoreWhenCombo;
    }

    public function set RageRestoreWhenCombo( value : int ) : void {
        if ( fightProperty.RageRestoreWhenCombo == value )
            return;
        fightProperty.RageRestoreWhenCombo = value;
        setPropertyChanged( ECharacterConst.RageRestoreWhenCombo, value );
    }

    /**友方死亡回复怒气*/
    public function get RageRestoreWhenMateKilled() : int {
        return fightProperty.RageRestoreWhenMateKilled;
    }

    public function set RageRestoreWhenMateKilled( value : int ) : void {
        if ( fightProperty.RageRestoreWhenMateKilled == value )
            return;
        fightProperty.RageRestoreWhenMateKilled = value;
        setPropertyChanged( ECharacterConst.RageRestoreWhenMateKilled, value );
    }

    /**职业克制相关属性**/
    //攻击
    public function get  AtkJobHurtAddChance() : int {
        return fightProperty.AtkJobHurtAddChance;
    }

    public function set  AtkJobHurtAddChance( value : int ) : void {
        if ( fightProperty.AtkJobHurtAddChance == value )
            return;
        fightProperty.AtkJobHurtAddChance = value;
    }

    public function get AtkJobHurtReduceChance() : int {
        return fightProperty.AtkJobHurtReduceChance;
    }

    public function set   AtkJobHurtReduceChance(value : int ) : void {
        if ( fightProperty.AtkJobHurtReduceChance== value )
            return;
        fightProperty.AtkJobHurtReduceChance = value;
    }

    //防御
     public function get  DefJobHurtAddChance() : int {
        return fightProperty.DefJobHurtAddChance;
    }

    public function set  DefJobHurtAddChance( value : int ) : void {
        if ( fightProperty.DefJobHurtAddChance == value )
            return;
        fightProperty.DefJobHurtAddChance = value;
    }

    public function get DefJobHurtReduceChance() : int {
        return fightProperty.DefJobHurtReduceChance;
    }

    public function set   DefJobHurtReduceChance(value : int ) : void {
        if ( fightProperty.DefJobHurtReduceChance== value )
            return;
        fightProperty.DefJobHurtReduceChance = value;
    }

    //技巧
     public function get  TechJobHurtAddChance() : int {
        return fightProperty.TechJobHurtAddChance;
    }

    public function set  TechJobHurtAddChance( value : int ) : void {
        if ( fightProperty.TechJobHurtAddChance == value )
            return;
        fightProperty.TechJobHurtAddChance = value;
    }

    public function get TechJobHurtReduceChance() : int {
        return fightProperty.TechJobHurtReduceChance;
    }

    public function set   TechJobHurtReduceChance(value : int ) : void {
        if ( fightProperty.TechJobHurtReduceChance== value )
            return;
        fightProperty.TechJobHurtReduceChance = value;
    }

    public function get TrueDamage() : int {
        return fightProperty.TrueDamage;
    }

    public function set TrueDamage( value : int ) : void{
        if( fightProperty.TrueDamage == value )
                return;
        fightProperty.TrueDamage = value;
    }

    public function get TrueResist() : int{
        return fightProperty.TrueResist;
    }

    public function set TrueResist( value : int ) : void{
        if( fightProperty.TrueResist == value )
                return;
        fightProperty.TrueResist = value;
    }

//    AtkJobHurtAddChance	AtkJobHurtReduceChance	DefJobHurtAddChance	DefJobHurtReduceChance	TechJobHurtAddChance	TechJobHurtReduceChance

    /******============================================================
     ***************^^^^^^^^^^^以上是fightproperty^^^^^^^^^^^**********
     * **************************************************************/

    /**百分比装备攻击*/
    public function get InitPercentATK() : Number {
        return data.InitPercentATK;
    }

    public function set InitPercentATK( value : Number ) : void {
        if ( data.InitPercentATK == value )
            return;
        data.InitPercentATK = value;
    }

    /**百分比装备防御*/
    public function get InitPercentDEF() : Number {
        return data.InitPercentDEF;
    }

    public function set InitPercentDEF( value : Number ) : void {
        if ( data.InitPercentDEF == value )
            return;
        data.InitPercentDEF = value;
    }

    /**百分比装备生命*/
    public function get InitPercentHP() : Number {
        return data.InitPercentHP;
    }

    public function set InitPercentHP( value : Number ) : void {
        if ( data.InitPercentHP == value )
            return;
        data.InitPercentHP = value;
    }

    public function get attackPowerRecoverCD() : int {
        return data.attackPowerRecoverCD;
    }

    public function set attackPowerRecoverCD( value : int ) : void {
        if ( data.attackPowerRecoverCD == value )
            return;
        data.attackPowerRecoverCD = value;
        setPropertyChanged( ECharacterConst.attackPowerRecoverCD, value );
    }

    public function set rageRestoreComboInterval( value : int ) : void {
        if ( data.rageRestoreComboInterval == value )
            return;
        data.rageRestoreComboInterval = value;
        setPropertyChanged( ECharacterConst.rageRestoreComboInterval, value );
    }

    public function get rageRestoreComboInterval() : int {
        return data.rageRestoreComboInterval;
    }

    /**怒气回复间隔*/
    public function get ragePowerRecoverCD() : int {
        return data.ragePowerRecoverCD;
    }

    public function set ragePowerRecoverCD( value : int ) : void {
        if ( ragePowerRecoverCD == value )
            return;
        data.ragePowerRecoverCD = value;
    }

    /**通用怪怒气回复比率*/
    public function get commonRageRestoreRate() : int {
        return data.commonRageRestoreRate;
    }

    public function set commonRageRestoreRate( value : int ) : void {
        if ( commonRageRestoreRate == value )
            return;
        data.commonRageRestoreRate = value;
    }

    /**精英怪回复比率*/
    public function get eliteRageRestoreRate() : int {
        return data.eliteRageRestoreRate;
    }

    public function set eliteRageRestoreRate( value : int ) : void {
        if ( eliteRageRestoreRate == value )
            return;
        data.eliteRageRestoreRate = value;
    }

    /** boss 回复怒气比率*/
    public function get bossRageRestoreRate() : int {
        return data.bossRageRestoreRate;
    }

    public function set bossRageRestoreRate( value : int ) : void {
        if ( bossRageRestoreRate == value )
            return;
        data.bossRageRestoreRate = value;
    }

    /**玩家回复怒气比率*/
    public function get playerRageRestoreRate() : int {
        return data.playerRageRestoreRate;
    }

    public function set playerRageRestoreRate( value : int ) : void {
        if ( playerRageRestoreRate == value )
            return;
        data.playerRageRestoreRate = value;
    }

    public function get size() : Number {
        return 1.0;
    }

    public function get attackPowerRecoverStopTime() : int {
        return data.attackPowerRecoverStopTime;
    }

    public function set defensePowerRecoverStopTime( value : int ) : void {
        if ( data.defensePowerRecoverStopTime == value )
            return;

        data.defensePowerRecoverStopTime = value;
        setPropertyChanged( ECharacterConst.defensePowerRecoverStopTime, value );
    }

    public function get defensePowerRecoverStopTime() : int {
        return data.defensePowerRecoverStopTime;
    }

    public function set attackPowerRecoverAcceleration( value : int ) : void {
        if ( data.attackPowerRecoverAcceleration == value )
            return;

        data.attackPowerRecoverAcceleration = value;
        setPropertyChanged( ECharacterConst.attackPowerRecoverAcceleration, value );
    }

    public function get defensePowerRecoverAcceleration() : int {
        return isNaN( data.defensePowerRecoverAcceleration ) ? 0 : data.defensePowerRecoverAcceleration;
    }

    public function set  defensePowerRecoverAcceleration( value : int ) : void {
        if ( data.defensePowerRecoverAcceleration == value )
            return;

        fightProperty.defensePowerRecoverAcceleration = value;
        setPropertyChanged( ECharacterConst.defensePowerRecoverAcceleration, value );
    }

    public function get attackPowerRecoverAcceleration() : int {
        return isNaN( data.attackPowerRecoverAcceleration ) ? 0 : data.attackPowerRecoverAcceleration;
    }

    public function get defensePowerRecoverSpeed() : int {
        return isNaN( data.defensePowerRecoverSpeed ) ? 0 : data.defensePowerRecoverSpeed;
    }

    public function set defensePowerRecoverSpeed( value : int ) : void {
        if ( data.defensePowerRecoverSpeed == value )
            return;
        data.defensePowerRecoverSpeed = value;
        setPropertyChanged( ECharacterConst.defensePowerRecoverSpeed, value );
    }

    public function set attackPowerRecoverStopTime( value : int ) : void {
        if ( data.attackPowerRecoverStopTime == value )
            return;

        data.attackPowerRecoverStopTime = value;
        setPropertyChanged( ECharacterConst.attackPowerRecoverStopTime, value );
    }

    //=====---------------------------------------------------------------------
    // Global properties.
    //=====---------------------------------------------------------------------

    public function get rollCost() : int {
        return data.rollCost;
    }

    public function set rollCost( value : int ) : void {
        if ( data.rollCost == value )
            return;
        data.rollCost = value;
        setPropertyChanged( ECharacterConst.rollCost, value );
    }

    public function get driveRollCost() : int {
        return data.driveRollCost;
    }

    public function set driveRollCost( value : int ) : void {
        if ( data.driveRollCost == value )
            return;
        data.driveRollCost = value;
        setPropertyChanged( ECharacterConst.driveRollCost, value );
    }

    public function get quickStandCost() : int {
        return data.quickStandCost;
    }

    public function set quickStandCost( value : int ) : void {
        if ( data.quickStandCost == value )
            return;
        data.quickStandCost = value;
        setPropertyChanged( ECharacterConst.quickStandCost, value );
    }

    public function get maxRageCount() : int {
        return int( data.maxRageCount );
    }

    public function set maxRageCount( value : int ) : void {
        if ( int( data.maxRageCount ) == value )
            return;
        data.maxRageCount = value;
        setPropertyChanged( ECharacterConst.maxRageCount, value );
    }

    public function get rollCD() : int {
        return int( data.rollCD );
    }

    public function set rollCD( value : int ) : void {
        if ( Number( data.rollCD ) == value )return;
        data.rollCD = value;
        setPropertyChanged( ECharacterConst.rollCD, value );
    }

    public function get quickStandCD() : int {
        return int( data.quickStandCD );
    }

    public function set quickStandCD( value : int ) : void {
        if ( Number( data.rollCD ) == value )return;
        data.quickStandCD = value;
        setPropertyChanged( ECharacterConst.quickStandCD, value );
    }

    public function get quickStandStopTime() : int {
        return int( data.quickStandStopTime );
    }

    public function set quickStandStopTime( value : int ) : void {
        if (int( data.quickStandStopTime ) == value )return;
        data.quickStandStopTime = value;
    }

    protected function setPropertyChanged( pName : String, value : * ) : void {
        if ( !m_pPropertyDic )
            m_pPropertyDic = new Dictionary();

        m_pPropertyDic[ pName ] = value;
        m_iUpdateIndex++;
    }

    /**最大暴击伤害万分比*/
    public function set maxStrikeAttackChance( value : int ) : void {
        if ( int( data.maxStrikeAttackChance ) == value )
            return;
        data.maxStrikeAttackChance = value;
        setPropertyChanged( ECharacterConst.maxStrikeAttackChance, value );
    }

    public function get maxStrikeAttackChance() : int {
        return int( data.maxStrikeAttackChance );
    }

    /**最小伤害值害值*/
    public function set minAttack( value : int ) : void {
        if ( int( data.minAttack ) == value )
            return;
        data.minAttack = value;
        setPropertyChanged( ECharacterConst.minAttack, value );
    }

    public function get minAttack() : int {
        return int( data.minAttack );
    }

    /**-----------------------------------------------------*/

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_iUpdateIndex <= 0 )
            return;

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new CPropertyUpdateEvent( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, owner, m_pPropertyDic ) );
        }
        m_iUpdateIndex = 0;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        m_theFightProperty = {};
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        // update the default data from the DB.

        this.campID = CCharacterDataDescriptor.getCampID( owner.data );

        {
            // Retrieves the global properties from the Database.

            var pDatabase : IDatabase = this.getComponent( IDatabase ) as IDatabase;
            if ( pDatabase ) {
                var pTable : IDataTable = pDatabase.getTable( KOFTableConstants.PLAYER_GLOBAL );
                if ( pTable ) {
                    var globalData : PlayerGlobal = pTable.first() as PlayerGlobal;
                    if ( globalData ) {
                        this.maxStrikeAttackChance = globalData.MaxStrikeAttackChance;
                        this.minAttack = globalData.MinAttack;
                        this.MaxRagePower = globalData.MaxRagePower;
                        this.maxRageCount = globalData.MaxRageCount;
                        this.getUpFx = globalData.GetUp_FX;
                        this.driveCancelFx = globalData.DriveCancel_FX;
                        this.superCancelFx = globalData.SuperCancel_FX;
                        this.paBodyFx = globalData.PaBody_FX;
                        this.guardCrashFx = globalData.GuardCrash_FX;
                        this.quickStandFx = globalData.QuickStand_FX;
                        this.ragePowerRecoverCD = globalData.RagePowerRecoverCD;
                        this.commonRageRestoreRate = globalData.CommonRageRestoreRate;
                        this.eliteRageRestoreRate = globalData.EliteRageRestoreRate;
                        this.bossRageRestoreRate = globalData.BossRageRestoreRate;
                        this.playerRageRestoreRate = globalData.PlayerRageRestoreRate;
                        this.quickStandGravity = globalData.QuickStandGravity;
                        this.defaultAPRC = globalData.DefaultAPRC;
                        this.defaultAPRS = globalData.DefaultAPRS;
                    }
                }
            }
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pPropertyDic = null;
        m_theFightProperty = null;
    }

    protected function get pPropertyDic() : Dictionary {
        return m_pPropertyDic;
    }

    protected function get iUpdateIndex() : int {
        return m_iUpdateIndex;
    }

    protected function set iUpdateIndex( value : int ) : void {
        m_iUpdateIndex = value;
    }

    public function get driveCancelFx() : String {
        return data.driveCancelFx;
    }

    public function set driveCancelFx( value : String ) : void {
        if ( value == driveCancelFx ) return;
        data.driveCancelFx = value;
    }

    public function get superCancelFx() : String {
        return data.superCancelFx;
    }

    public function set superCancelFx( value : String ) : void {
        if ( value == superCancelFx ) return;
        data.superCancelFx = value;
    }

    public function get guardCrashFx() : String {
        return data.guardCrashFx;
    }

    public function set guardCrashFx( value : String ) : void {
        if ( value == guardCrashFx ) return;
        data.guardCrashFx = value;
    }

    public function get getUpFx() : String {
        return data.getUpFx;
    }

    public function set getUpFx( value : String ) : void {
        if ( value == getUpFx ) return;
        data.getUpFx = value;
    }

    public function get paBodyFx() : String {
        return data.paBodyFx;
    }

    public function set paBodyFx( value : String ) : void {
        if ( value == paBodyFx ) return;
        data.paBodyFx = value;
    }

    public function get quickStandFx() : String {
        return data.quickStandFx;
    }

    public function set quickStandFx( value : String ) : void {
        if ( value == quickStandFx ) return;
        data.quickStandFx = value;
    }

    public function get quickStandGravity() : Number {
        return data.quickStandGravity;
    }

    public function set  quickStandGravity( value : Number ) : void {
        if ( value == quickStandGravity )
            return;
        data.quickStandGravity = value;
    }

    public function get defaultAPRC() : Number {
        return fightProperty.DefaultAPRC;
    }

    public function set defaultAPRC( value : Number ) : void {
        if ( value == defaultAPRC )
            return;
        fightProperty.DefaultAPRC = value;
    }

    public function get defaultAPRS() : Number {
        return fightProperty.DefaultAPRS;
    }

    public function set defaultAPRS( value : Number ) : void {
        if ( value == defaultAPRS )
            return;
        fightProperty.DefaultAPRS = value;
    }

    public function get fightProperty() : Object {
        return m_theFightProperty;
    }

    public function set fightProperty( value : Object ) : void {
        m_theFightProperty = value;
    }

    protected function _propertyInFightData( value : String, targetData : Object ) : int {
        if ( targetData.hasOwnProperty( value ) ) {
            return targetData[ value ];
        } else if ( fightProperty.hasOwnProperty( value ) ) {
            return fightProperty[ value ];
        }
        return 0;
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4

