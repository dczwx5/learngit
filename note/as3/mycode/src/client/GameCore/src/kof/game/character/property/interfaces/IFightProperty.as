//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/14.
//----------------------------------------------------------------------
package kof.game.character.property.interfaces {

public interface IFightProperty {
    /** 生命 */
    function get HP() : int;

    /** 攻击 */
    function get Attack() : int;

    /** 防御值 */
    function get Defense() : int;

    /** 攻击值 */
    function get AttackPower() : uint;

    /** 防御值 */
    function get DefensePower() : uint;

    /** 怒气 */
    function get RagePower() : int;

    /** 最大血量*/
    function get MaxHP() : int;

    /** 最大攻击值 */
    function get MaxAttackPower() : uint;

    /** 最大防御值 */
    function get MaxDefensePower() : uint;

    /** 最大怒气值 */
    function get MaxRagePower() : int;

    /** 攻击值恢复速度 */
    function get AttackPowerRecoverSpeed() : int;

    /** 防御值恢复CD */
    function get DefensePowerRecoverCD() : int;

    /**怒气值回复速度*/
    function get RagePowerRecoverSpeed() : int;

    /** 暴击率万分比 */
    function get CritChance() : int;

    /** 抗暴率万分比*/
    function get DefendCritChance() : int;

    /** 暴击伤害万分比 */
    function get CritHurtChance() : int;

    /** 暴伤抵抗万分比 */
    function get CritDefendChance() : int;

    /** 格挡减伤万分比 */
    function get BlockHurtChance() : int;

    /** 碾压格挡万分比 */
    function get RollerBlockChance() : int;

    /** 伤害加成万分比 */
    function get HurtAddChance() : int;

    /** 伤害减免万分比 */
    function get HurtReduceChance() : int;

    /**破招伤害加成*/
    function get CounterAttackChance() : int;

    /**受伤回复怒气*/
    function get RageRestoreWhenDamaged() : int;

    /**输出回复怒气*/
    function get RageRestoreWhenDamageTarget() : int;

    /**击杀回复怒气*/
    function get RageRestoreWhenKillTarget() : int;

    /**消耗攻击值回复怒气*/
    function get RageRestoreAttackPowerConsume() : int;

    /**每次被击打回复怒气*/
    function get RageRestoreWhenHitted() : int;

    /**连击n次回复怒气*/
    function get RageRestoreWhenCombo() : int;

    /**友方死亡回复怒气*/
    function get RageRestoreWhenMateKilled() : int;

    /** 命中率万分比*/
    function get HitChance() : int;

    /** 闪避率万分比 */
    function get DodgeChance() : int;

    /** Set */
    /** 生命 */
    function set HP( value : int ) : void ;

    /** 攻击 */
    function set Attack( value : int ) : void ;

    /** 防御值 */
    function set Defense( value : int ) : void ;

    /** 攻击值 */
    function set AttackPower( value : uint ) : void;

    /** 防御值 */
    function set DefensePower( value : uint ) : void;

    /** 怒气 */
    function set RagePower( value : int ) : void ;

    /** 最大血量*/
    function set MaxHP( value : int ) : void ;

    /** 最大攻击值 */
    function set MaxAttackPower( value : uint ) : void;

    /** 最大防御值 */
    function set MaxDefensePower( value : uint ) : void;

    /** 最大怒气值 */
    function set MaxRagePower( value : int ) : void ;

    /** 攻击值恢复速度 */
    function set AttackPowerRecoverSpeed( value : int ) : void ;

    /** 防御值恢复CD */
    function set DefensePowerRecoverCD( value : int ) : void ;

    /**怒气值回复速度*/
    function set RagePowerRecoverSpeed( value : int ) : void ;

    /** 暴击率万分比 */
    function set CritChance( value : int ) : void ;

    /** 抗暴率万分比*/
    function set DefendCritChance( value : int ) : void ;

    /** 暴击伤害万分比 */
    function set CritHurtChance( value : int ) : void ;

    /** 暴伤抵抗万分比 */
    function set CritDefendChance( value : int ) : void ;

    /** 格挡减伤万分比 */
    function set BlockHurtChance( value : int ) : void ;

    /** 碾压格挡万分比 */
    function set RollerBlockChance( value : int ) : void ;

    /** 伤害加成万分比 */
    function set HurtAddChance( value : int ) : void ;

    /** 伤害减免万分比 */
    function set HurtReduceChance( value : int ) : void ;

    /**破招伤害加成*/
    function set CounterAttackChance( value : int ) : void ;

    /**受伤回复怒气*/
    function set RageRestoreWhenDamaged( value : int ) : void ;

    /**输出回复怒气*/
    function set RageRestoreWhenDamageTarget( value : int ) : void ;

    /**击杀回复怒气*/
    function set RageRestoreWhenKillTarget( value : int ) : void ;

    /**消耗攻击值回复怒气*/
    function set RageRestoreAttackPowerConsume( value : int ) : void;

    /**每次被击打回复怒气*/
    function set RageRestoreWhenHitted( value : int ) : void;

    /**连击n次回复怒气*/
    function set RageRestoreWhenCombo( value : int) : void;

    /**友方死亡回复怒气*/
    function set RageRestoreWhenMateKilled( value : int ) : void;


    /** 命中率万分比*/
    function set HitChance( value : int ) : void ;

    /** 闪避率万分比 */
    function set DodgeChance( value : int ) : void ;



}
}
