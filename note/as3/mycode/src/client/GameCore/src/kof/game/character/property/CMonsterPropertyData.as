//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/7.
 */
package kof.game.character.property {

import kof.game.character.property.interfaces.IAddTemplate;
import kof.table.MonsterProperty;

public class CMonsterPropertyData extends CBasePropertyData implements IAddTemplate {
    public function CMonsterPropertyData() {
    }

    public override function add( other : CBasePropertyData ) : void {
        super.add( other );

        if ( other is CMonsterPropertyData ) {
            var otherMonsterPropertyData : CMonsterPropertyData = other as CMonsterPropertyData;
            iCritRate += otherMonsterPropertyData.iCritRate;
            iCritDefendRate += otherMonsterPropertyData.iCritDefendRate;
            iCritDamageRate += otherMonsterPropertyData.iCritDamageRate;
            iCritDamageDefendRate += otherMonsterPropertyData.iCritDamageDefendRate;
            iDamageBlockRate += otherMonsterPropertyData.iDamageBlockRate;
            iRollerBlockRate += otherMonsterPropertyData.iRollerBlockRate;
            iDamageHardRate += otherMonsterPropertyData.iDamageHardRate;
            iDamageReduceRate += otherMonsterPropertyData.iDamageReduceRate;
            iAttackPower += otherMonsterPropertyData.iAttackPower;
            iDefendPower += otherMonsterPropertyData.iDefendPower;
            // base data
            attackPowerRecoverCD += otherMonsterPropertyData.attackPowerRecoverCD;
            attackPowerRecoverSpeed += otherMonsterPropertyData.attackPowerRecoverSpeed;
            attackPowerRecoverAcceleration += otherMonsterPropertyData.attackPowerRecoverAcceleration;
            attackPowerRecoverStopTime += otherMonsterPropertyData.attackPowerRecoverStopTime;
            defensePowerRecoverCD += otherMonsterPropertyData.defensePowerRecoverCD;
            defensePowerRecoverSpeed += otherMonsterPropertyData.defensePowerRecoverSpeed;
            defensePowerRecoverAcceleration += otherMonsterPropertyData.defensePowerRecoverAcceleration;
            defensePowerRecoverStopTime += otherMonsterPropertyData.defensePowerRecoverStopTime;

            rollCost += otherMonsterPropertyData.rollCost;
            driveRollCost += otherMonsterPropertyData.driveRollCost;
            quickStandCost += otherMonsterPropertyData.quickStandCost;


            ragePowerInit += otherMonsterPropertyData.ragePowerInit;
            rageRestoreWhenDamaged += otherMonsterPropertyData.rageRestoreWhenDamaged;
            rageRestoreAttackPowerConsume += otherMonsterPropertyData.rageRestoreAttackPowerConsume;
            rageRestoreWhenHitted += otherMonsterPropertyData.rageRestoreWhenHitted;
            rageRestoreWhenCombo += otherMonsterPropertyData.rageRestoreWhenCombo;
            rageRestoreWhenKillTarget += otherMonsterPropertyData.rageRestoreWhenKillTarget;
            rageRestoreWhenMateKilled += otherMonsterPropertyData.rageRestoreWhenMateKilled;
            rageRestoreSpeed += otherMonsterPropertyData.rageRestoreSpeed;
            rageRestoreWhenAttack += otherMonsterPropertyData.rageRestoreWhenAttack;
            atkJobHurtAddChance += otherMonsterPropertyData.AtkJobHurtAddChance;
            atkJobHurtReduceChance +=otherMonsterPropertyData.AtkJobHurtReduceChance;
            defJobHurtAddChance += otherMonsterPropertyData.DefJobHurtAddChance;
            defJobHurtReduceChance +=otherMonsterPropertyData.DefJobHurtReduceChance;
            techJobHurtAddChance +=otherMonsterPropertyData.TechJobHurtAddChance;
            techJobHurtReduceChance +=otherMonsterPropertyData.TechJobHurtReduceChance;
            defaultAPRC += otherMonsterPropertyData.defaultAPRC;
            defaultAPRS += otherMonsterPropertyData.defaultAPRS;
            counterAttackChance += otherMonsterPropertyData.counterAttackChance;

            trueDamage += otherMonsterPropertyData.trueDamage;
            trueResist += otherMonsterPropertyData.trueResist;
        }
    }

    public function addBaseTemplate( baseTemplate : MonsterProperty ) : void {
        Attack = baseTemplate.Attack;
        Defense = baseTemplate.Defense;
        HP = baseTemplate.HP;
        iCritRate = baseTemplate.CritChance;
        iCritDefendRate = baseTemplate.DefendCritChance;
        iCritDamageRate = baseTemplate.CritHurtChance;
        iCritDamageDefendRate = baseTemplate.CritDefendChance;
        iDamageBlockRate = baseTemplate.BlockHurtChance;
        iRollerBlockRate = baseTemplate.RollerBlockChance;
        iDamageHardRate = baseTemplate.HurtAddChance;
        iDamageReduceRate = baseTemplate.HurtReduceChance;
        iAttackPower = baseTemplate.AttackPower;
        iDefendPower = baseTemplate.DefensePower;


        // base data
        attackPowerRecoverCD = baseTemplate.AttackPowerRecoverCD;
        attackPowerRecoverSpeed = baseTemplate.AttackPowerRecoverSpeed;
        attackPowerRecoverAcceleration = baseTemplate.AttackPowerRecoverAcceleration;
        attackPowerRecoverStopTime = baseTemplate.AttackPowerRecoverStopTime;
        defensePowerRecoverCD = baseTemplate.DefensePowerRecoverCD;
        defensePowerRecoverSpeed = baseTemplate.DefensePowerRecoverSpeed;
        defensePowerRecoverAcceleration = baseTemplate.DefensePowerRecoverAcceleration;
        defensePowerRecoverStopTime = baseTemplate.DefensePowerRecoverStopTime;

        rollCost = baseTemplate.RollCost;
        driveRollCost = baseTemplate.DriveRollCost;
        quickStandCost = baseTemplate.QuickStandCost;

        ragePowerInit += baseTemplate.RagePowerInit;
        rageRestoreWhenDamaged += baseTemplate.RageRestoreWhenDamaged;
        rageRestoreAttackPowerConsume += baseTemplate.RageRestoreAttackPowerConsume;
        rageRestoreWhenHitted += baseTemplate.RageRestoreWhenHitted;
        rageRestoreWhenCombo += baseTemplate.RageRestoreWhenCombo;
        rageRestoreWhenKillTarget += baseTemplate.RageRestoreWhenKillTarget;
        rageRestoreWhenMateKilled += baseTemplate.RageRestoreWhenMateKilled;
        rageRestoreSpeed += baseTemplate.RageRestoreSpeed;
        rageRestoreWhenAttack += baseTemplate.RageRestoreWhenDamageTarget;
        defaultAPRC += baseTemplate.DefaultAPRC;
        defaultAPRS += baseTemplate.DefaultAPRS;
        atkJobHurtAddChance += baseTemplate.AtkJobHurtAddChance;
        atkJobHurtReduceChance += baseTemplate.AtkJobHurtReduceChance;
        defJobHurtAddChance += baseTemplate.DefJobHurtAddChance;
        defJobHurtReduceChance += baseTemplate.DefJobHurtReduceChance;
        techJobHurtAddChance += baseTemplate.TechJobHurtAddChance;
        techJobHurtReduceChance += baseTemplate.TechJobHurtReduceChance;
        counterAttackChance += baseTemplate.CounterAttackChance;

//        trueDamage += baseTemplate.TrueDamage;
//        trueResist += baseTemplate.TrueResist;
    }

    public function addGrowTemplate( growTemplate : MonsterProperty, difficulty : Number ) : void {
        Attack += growTemplate.Attack * difficulty;
        Defense += growTemplate.Defense * difficulty;
        HP += growTemplate.HP * difficulty;
        iCritRate += growTemplate.CritChance * difficulty;
        iCritDefendRate += growTemplate.DefendCritChance * difficulty;
        iCritDamageRate += growTemplate.CritHurtChance * difficulty;
        iCritDamageDefendRate += growTemplate.CritDefendChance * difficulty;
        iDamageBlockRate += growTemplate.BlockHurtChance * difficulty;
        iRollerBlockRate += growTemplate.RollerBlockChance * difficulty;
        iDamageHardRate += growTemplate.HurtAddChance * difficulty;
        iDamageReduceRate += growTemplate.HurtReduceChance * difficulty;
        iAttackPower += growTemplate.AttackPower * difficulty;
        iDefendPower += growTemplate.DefensePower * difficulty;
//        counterAttackChance += growTemplate.CounterAttackChance * difficulty;
    }

    public var iCritRate : int; // 暴击率万分值
    public var iCritDefendRate : int; // 抗暴率万分值
    public var iCritDamageRate : int; // 暴击伤害万分值
    public var iCritDamageDefendRate : int; // 暴伤抵抗万分值
    public var iDamageBlockRate : int; // 格挡减伤万分值
    public var iRollerBlockRate : int; // 碾压格挡万分值
    public var iDamageHardRate : int; // 伤害加成万分值
    public var iDamageReduceRate : int; // 伤害减免万分值

    public var iAttackPower : int; // 攻击值
    public var iDefendPower : int; // 防御值

    // 保持原值的
    public var attackPowerRecoverCD : int;
    public var attackPowerRecoverSpeed : int;
    public var attackPowerRecoverAcceleration : int;
    public var attackPowerRecoverStopTime : int;
    public var defensePowerRecoverCD : int;
    public var defensePowerRecoverSpeed : int;
    public var defensePowerRecoverAcceleration : int;
    public var defensePowerRecoverStopTime : int;

    public var rollCost : int;
    public var driveRollCost : int;
    public var quickStandCost : int;
    public var rageRestoreComboInterval : int;

    //怒气相关
    public var ragePowerInit : int;
    public var rageRestoreWhenDamaged : int;
    public var rageRestoreAttackPowerConsume : int;
    public var rageRestoreWhenHitted : int;
    public var rageRestoreWhenCombo : int;
    public var rageRestoreWhenKillTarget : int;
    public var rageRestoreWhenMateKilled : int;
    public var rageRestoreSpeed : int;
    public var rageRestoreWhenAttack : int;
    public var defaultAPRC : int;
    public var defaultAPRS : int;
    public var counterAttackChance : int;

    //职业克制相关
    public var atkJobHurtAddChance : int;
    public var atkJobHurtReduceChance : int;
    public var defJobHurtAddChance : int;
    public var defJobHurtReduceChance : int;
    public var techJobHurtAddChance : int;
    public var techJobHurtReduceChance : int;

    public var trueDamage : int;
    public var trueResist : int;

}
}
