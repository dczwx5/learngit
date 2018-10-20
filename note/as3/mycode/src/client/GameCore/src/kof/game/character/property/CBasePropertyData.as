//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/3.
 */
package kof.game.character.property {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.table.PassiveSkillPro;
import kof.table.PlayerBasic;
import kof.table.PlayerGlobal;

public class CBasePropertyData extends CObjectData {
    public function CBasePropertyData() {
    }

    public static function copyFromPlayerBasic(playerBasic:PlayerBasic) : CBasePropertyData {
        var propertyData:CBasePropertyData = new CBasePropertyData();
        for each (var key:String in _calcBattleValueKeyList) {
            propertyData[key] = playerBasic[key];
        }

        return propertyData;
    }

    // 需要计算战斗力的属性列表
    public static var _calcBattleValueKeyList:Array = [
        _Attack, _Defense, _HP,
        _CritChance, _DefendCritChance, _CritHurtChance, _CritDefendChance,
        _BlockHurtChance, _RollerBlockChance,
        _HurtAddChance, _HurtReduceChance, _ExtraAttribute, _AtkJobHurtAddChance, _AtkJobHurtReduceChance,
        _DefJobHurtAddChance, _DefJobHurtReduceChance, _TechJobHurtAddChance, _TechJobHurtReduceChance]

    public virtual function add(other:CBasePropertyData) : void {
        if (!other || other.data == null) return ;
        var otherData:Object = other.data;
        var temp:int = 0;
        for (var key:String in otherData) {
            temp = _data[key];
            _data[key] = temp + otherData[key];
        }
    }
    public virtual function sub(other:CBasePropertyData) : void {
        if (!other || other.data == null) return ;
        var otherData:Object = other.data;
        var temp:int = 0;
        for (var key:String in otherData) {
            temp = _data[key];
            _data[key] = temp - otherData[key];
        }
    }
    public virtual function Set(other:CBasePropertyData) : void {
        if (!other || other.data == null) return ;
        this.clearData();
        var otherData:Object = other.data;
        for (var key:String in otherData) {
            _data[key] = otherData[key];
        }
    }
    public override function updateDataByData(data:Object) : void {
//        var list:Object = _getList();
//        for (var key:String in data) {
//            if (key in list) {
//                _data[key] = data[key];
//            }
//        }
        super.updateDataByData(data);
    }

    /**
     * 得属性中文名
     * @param attrName 属性英文名
     * @return
     */
    public function getAttrNameCN(attrName:String):String
    {
        if(_databaseSystem)
        {
            var arr:Array = _databaseSystem.getTable(KOFTableConstants.PASSIVE_SKILL_PRO ).findByProperty("word",attrName);
            if(arr && arr.length)
            {
                return (arr[0] as PassiveSkillPro).name;
            }
        }

        return "";
    }

    /**
     * 通过id获得属性英文名
     * @param id 属性id
     * @return
     */
    public function getAttrNameEN(id:int):String
    {
        if(_databaseSystem)
        {
            var passiveSkillTable:IDataTable = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO );
            var cfg: PassiveSkillPro = passiveSkillTable.findByPrimaryKey(id);
            if (cfg != null)
            {
                return cfg.word;
            }
        }
        return "";
    }

    /**
     * 加百分比
     * @param other
     */
    public virtual function addPercent(other:CBasePropertyData) : void {
        if (!other || other.data == null) return ;
        var otherData:Object = other.data;
        var temp:int = 0;
        for (var key:String in otherData) {
            temp = _data[key];
            _data[key] = Math.ceil(temp * (1+otherData[key]*0.0001));
        }
    }

    /**
     * 计算战力
     */
    public virtual function getBattleValue() : int
    {
        var battleValue:Number = 0;
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.PLAYER_GLOBAL);
        var playerGlobal:PlayerGlobal = table.findByPrimaryKey(1) as PlayerGlobal;
        if(playerGlobal)
        {
            battleValue += Attack * (playerGlobal.AttackPower*0.0001) + Defense * (playerGlobal.DefensePower*0.0001)
            + HP * (playerGlobal.HPPower*0.0001) + CritChance * (playerGlobal.CritChancePower*0.0001)
            + DefendCritChance * (playerGlobal.DefendCritChancePower*0.0001) + CritHurtChance * (playerGlobal.CritHurtChancePower*0.0001)
            + CritDefendChance * (playerGlobal.CritDefendChancePower*0.0001) + BlockHurtChance * (playerGlobal.BlockHurtChancePower*0.0001)
            + RollerBlockChance * (playerGlobal.RollerBlockChancePower*0.0001) + HurtAddChance * (playerGlobal.HurtAddChancePower*0.0001)
            + HurtReduceChance * (playerGlobal.HurtReduceChancePower*0.0001) + ExtraAttribute * playerGlobal.ExtraAttributePower
            + AtkJobHurtAddChance * (playerGlobal.AtkJobHurtAddChancePower*0.0001) + AtkJobHurtReduceChance * (playerGlobal.AtkJobHurtReduceChancePower*0.0001)
            + DefJobHurtAddChance * (playerGlobal.DefJobHurtAddChancePower*0.0001) + DefJobHurtReduceChance * (playerGlobal.DefJobHurtReduceChancePower*0.0001)
            + TechJobHurtAddChance * (playerGlobal.TechJobHurtAddChancePower*0.0001) + TechJobHurtReduceChance * (playerGlobal.TechJobHurtReduceChancePower*0.0001)
            + TrueDamage * (playerGlobal.TrueDamagePower*0.0001) + TrueResist * (playerGlobal.TrueResistPower*0.0001)
            + RagePower * (playerGlobal.RagePowerPower*0.0001);
        }

        return int(battleValue);
    }

//    // 不包括单个格斗的培养属性
//    // 格斗家基础属性+斗魂属性*（1+格斗家资质加成）*（1+好感度加成）
//    public function getBattleValueExceptSingle() : int {
//        var battleValue:Number = 0;
//        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.PLAYER_GLOBAL);
//        var playerGlobal:PlayerGlobal = table.findByPrimaryKey(1) as PlayerGlobal;
//        if(playerGlobal)
//        {
//            battleValue += Attack * (playerGlobal.AttackPower*0.0001) + Defense * (playerGlobal.DefensePower*0.0001)
//                    + HP * (playerGlobal.HPPower*0.0001) + CritChance * (playerGlobal.CritChancePower*0.0001)
//                    + DefendCritChance * (playerGlobal.DefendCritChancePower*0.0001) + CritHurtChance * (playerGlobal.CritHurtChancePower*0.0001)
//                    + CritDefendChance * (playerGlobal.CritDefendChancePower*0.0001) + BlockHurtChance * (playerGlobal.BlockHurtChancePower*0.0001)
//                    + RollerBlockChance * (playerGlobal.RollerBlockChancePower*0.0001) + HurtAddChance * (playerGlobal.HurtAddChancePower*0.0001)
//                    + HurtReduceChance * (playerGlobal.HurtReduceChancePower*0.0001) + ExtraAttribute * playerGlobal.ExtraAttributePower
//                    + AtkJobHurtAddChance * (playerGlobal.AtkJobHurtAddChancePower*0.0001) + AtkJobHurtReduceChance * (playerGlobal.AtkJobHurtReduceChancePower*0.0001)
//                    + DefJobHurtAddChance * (playerGlobal.DefJobHurtAddChancePower*0.0001) + DefJobHurtReduceChance * (playerGlobal.DefJobHurtReduceChancePower*0.0001)
//                    + TechJobHurtAddChance * (playerGlobal.TechJobHurtAddChancePower*0.0001) + TechJobHurtReduceChance * (playerGlobal.TechJobHurtReduceChancePower*0.0001);
//        }
//        return int(battleValue);
//    }

    public function set HP(v:int) : void { _data[_HP] = v; }
    public function set Attack(v:int) : void { _data[_Attack] = v; }
    public function set Defense(v:int) : void { _data[_Defense] = v; }
    public function set AttackPower(v:int) : void { _data[_AttackPower] = v; } //攻击值
    public function set DefensePower(v:int) : void { _data[_DefensePower] = v; } //防御值
    public function set RagePower(v:int) : void { _data[_RagePower] = v; } //怒气值
    public function set MaxHP(v:int) : void { _data[_MaxHP] = v; } //生命值上限
    public function set MaxAttackPower(v:int) : void { _data[_MaxAttackPower] = v; } //攻击值上限
    public function set MaxDefensePower(v:int) : void { _data[_MaxDefensePower] = v; } //防御值上限
    public function set MaxRagePower(v:int) : void { _data[_MaxRagePower] = v; } //怒气值上限
    public function set AttackPowerRecoverSpeed(v:int) : void { _data[_AttackPowerRecoverSpeed] = v; } //攻击值回复速度
    public function set DefensePowerRecoverCD(v:int) : void { _data[_DefensePowerRecoverCD] = v; } //防御值回复间隔
    public function set RagePowerRecoverSpeed(v:int) : void { _data[_RagePowerRecoverSpeed] = v; } //怒气值回复速度
    public function set CritChance(v:int) : void { _data[_CritChance] = v; } //暴击率万分值
    public function set DefendCritChance(v:int) : void { _data[_DefendCritChance] = v; } //抗暴率万分值
    public function set CritHurtChance(v:int) : void { _data[_CritHurtChance] = v; } //暴击伤害万分值
    public function set CritDefendChance(v:int) : void { _data[_CritDefendChance] = v; } //暴伤抵抗万分值
    public function set BlockHurtChance(v:int) : void { _data[_BlockHurtChance] = v; } //格挡减伤万分值
    public function set RollerBlockChance(v:int) : void { _data[_RollerBlockChance] = v; } //碾压格挡万分值
    public function set HurtAddChance(v:int) : void { _data[_HurtAddChance] = v; } //伤害加成万分值
    public function set HurtReduceChance(v:int) : void { _data[_HurtReduceChance] = v; } //伤害减免万分值
    public function set CounterAttackChance(v:int) : void { _data[_CounterAttackChance] = v; } //破招伤害万分值
    public function set RageRestoreWhenDamaged(v:int) : void { _data[_RageRestoreWhenDamaged] = v; } //受伤回复怒气
    public function set RageRestoreWhenDamageTarget( v:int) : void { _data[_RageRestoreWhenDamageTarget] = v; } //输出回复怒气
    public function set RageRestoreWhenKillTarget(v:int) : void { _data[_RageRestoreWhenKillTarget] = v; }
    public function set MoveSpeed(v:int) : void { _data[_MoveSpeed] = v; }
    public function set HitChance(v:int) : void { _data[_HitChance] = v; }
    public function set DodgeChance(v:int) : void { _data[_DodgeChance] = v; }
    public function set PercentEquipATK(v:int) : void { _data[_PercentEquipATK] = v; }
    public function set PercentEquipDEF(v:int) : void { _data[_PercentEquipDEF] = v; }
    public function set PercentEquipHP(v:int) : void { _data[_PercentEquipHP] = v; }
    public function set BaseDamage(v:int) : void { _data[_BaseDamage] = v; }
    public function set BaseHealing(v:int) : void { _data[_BaseHealing] = v; }
    public function set CD(v:int) : void { _data[_CD] = v; }
    public function set ConsumeAP(v:int) : void { _data[_ConsumeAP] = v; }
    public function set ConsumePGP(v:int) : void { _data[_ConsumePGP] = v; }
    public function set ConsumeGP(v:int) : void { _data[_ConsumeGP] = v; }
    public function set ExCounterAttack(v:int) : void { _data[_ExCounterAttack] = v; }
    public function set SkillReleaseAngerRecover(v:int) : void { _data[_SkillReleaseAngerRecover] = v; }
    public function set SkillHitAngerRecover(v:int) : void { _data[_SkillHitAngerRecover] = v; }
    public function set ExtraAttribute( v:int) : void { _data[_ExtraAttribute] = v; } //附件属性
    public function set AtkJobHurtAddChance( v:int) : void { _data[_AtkJobHurtAddChance] = v; } //攻击职业伤害加成
    public function set AtkJobHurtReduceChance( v:int) : void { _data[_AtkJobHurtReduceChance] = v; } //攻击职业伤害减免
    public function set DefJobHurtAddChance( v:int) : void { _data[_DefJobHurtAddChance] = v; } //防御职业伤害加成
    public function set DefJobHurtReduceChance( v:int) : void { _data[_DefJobHurtReduceChance] = v; } //防御职业伤害减免
    public function set TechJobHurtAddChance( v:int) : void { _data[_TechJobHurtAddChance] = v; } //技巧职业伤害加成
    public function set TechJobHurtReduceChance( v:int) : void { _data[_TechJobHurtReduceChance] = v; } //技巧职业伤害减免
    public function set DefaultAPRC( v:int) : void { _data[_DefaultAPRC] = v; } //默认攻击值恢复间隔
    public function set DefaultAPRS( v:int) : void { _data[_DefaultAPRS] = v; } //默认攻击值恢复值
    public function set TrueDamage( v:int) : void { _data[_TrueDamage] = v; }
    public function set TrueResist( v:int) : void { _data[_TrueResist] = v; }

    public function get HP() : int { return _data[_HP]; }
    public function get Attack() : int { return _data[_Attack]; }
    public function get Defense() : int { return _data[_Defense]; }
    public function get AttackPower() : int { return _data[_AttackPower]; } //攻击值
    public function get DefensePower() : int { return _data[_DefensePower]; } //防御值
    public function get RagePower() : int { return _data[_RagePower]; } //怒气值
    public function get MaxHP() : int { return _data[_MaxHP]; } //生命值上限
    public function get MaxAttackPower() : int { return _data[_MaxAttackPower]; } //攻击值上限
    public function get MaxDefensePower() : int { return _data[_MaxDefensePower]; } //防御值上限
    public function get MaxRagePower() : int { return _data[_MaxRagePower]; } //怒气值上限
    public function get AttackPowerRecoverSpeed() : int { return _data[_AttackPowerRecoverSpeed]; } //攻击值回复速度
    public function get DefensePowerRecoverCD() : int { return _data[_DefensePowerRecoverCD]; } //防御值回复间隔
    public function get RagePowerRecoverSpeed() : int { return _data[_RagePowerRecoverSpeed]; } //怒气值回复速度
    public function get CritChance() : int { return _data[_CritChance]; } //暴击率万分值
    public function get DefendCritChance() : int { return _data[_DefendCritChance]; } //抗暴率万分值
    public function get CritHurtChance() : int { return _data[_CritHurtChance]; } //暴击伤害万分值
    public function get CritDefendChance() : int { return _data[_CritDefendChance]; } //暴伤抵抗万分值
    public function get BlockHurtChance() : int { return _data[_BlockHurtChance]; } //格挡减伤万分值
    public function get RollerBlockChance() : int { return _data[_RollerBlockChance]; } //碾压格挡万分值
    public function get HurtAddChance() : int { return _data[_HurtAddChance]; } //伤害加成万分值
    public function get HurtReduceChance() : int { return _data[_HurtReduceChance]; } //伤害减免万分值
    public function get CounterAttackChance() : int { return _data[_CounterAttackChance]; } //破招伤害万分值
    public function get RageRestoreWhenDamaged() : int { return _data[_RageRestoreWhenDamaged]; } //受伤回复怒气
    public function get RageRestoreWhenDamageTarget() : int { return _data[_RageRestoreWhenDamageTarget]; } //输出回复怒气
    public function get RageRestoreWhenKillTarget() : int { return _data[_RageRestoreWhenKillTarget]; }
    public function get MoveSpeed() : int { return _data[_MoveSpeed]; }
    public function get HitChance() : int { return _data[_HitChance]; }
    public function get DodgeChance() : int { return _data[_DodgeChance]; }
    public function get PercentEquipATK() : int { return _data[_PercentEquipATK]; }
    public function get PercentEquipDEF() : int { return _data[_PercentEquipDEF]; }
    public function get PercentEquipHP() : int { return _data[_PercentEquipHP]; }
    public function get BaseDamage() : int { return _data[_BaseDamage]; }
    public function get BaseHealing() : int { return _data[_BaseHealing]; }
    public function get CD() : int { return _data[_CD]; }
    public function get ConsumeAP() : int { return _data[_ConsumeAP]; }
    public function get ConsumePGP() : int { return _data[_ConsumePGP]; }
    public function get ConsumeGP() : int { return _data[_ConsumeGP]; }
    public function get ExCounterAttack() : int { return _data[_ExCounterAttack]; }
    public function get SkillReleaseAngerRecover() : int { return _data[_SkillReleaseAngerRecover]; }
    public function get SkillHitAngerRecover() : int { return _data[_SkillHitAngerRecover]; }
    public function get ExtraAttribute() : int { return _data[_ExtraAttribute]; } //附加属性
    public function get AtkJobHurtAddChance() : int {return _data[_AtkJobHurtAddChance]} //攻击职业伤害加成
    public function get AtkJobHurtReduceChance() : int {return _data[_AtkJobHurtReduceChance]} //攻击职业伤害减免
    public function get DefJobHurtAddChance() : int {return _data[_DefJobHurtAddChance]} //防御职业伤害加成
    public function get DefJobHurtReduceChance() : int {return _data[_DefJobHurtReduceChance]} //防御职业伤害减免
    public function get TechJobHurtAddChance() : int {return _data[_TechJobHurtAddChance]} //技巧职业伤害加成
    public function get TechJobHurtReduceChance() : int {return _data[_TechJobHurtReduceChance]} //技巧职业伤害减免
    public function get DefaultAPRC() : int {return _data[_DefaultAPRC]} //默认攻击值恢复间隔
    public function get DefaultAPRS() : int {return _data[_DefaultAPRS]} //默认攻击值恢复值
    public function get TrueDamage() : int {return _data[_TrueDamage]}
    public function get TrueResist() : int {return _data[_TrueResist]}

    public static var _HP:String = "HP";
    public static var _Attack:String = "Attack";
    public static var _Defense:String = "Defense";
    public static var _AttackPower:String = "AttackPower";
    public static var _DefensePower:String = "DefensePower";
    public static var _RagePower:String = "RagePower";
    public static var _MaxHP:String = "MaxHP";
    public static var _MaxAttackPower:String = "MaxAttackPower";
    public static var _MaxDefensePower:String = "MaxDefensePower";
    public static var _MaxRagePower:String = "MaxRagePower";
    public static var _AttackPowerRecoverSpeed:String = "AttackPowerRecoverSpeed";
    public static var _DefensePowerRecoverCD:String = "DefensePowerRecoverCD";
    public static var _RagePowerRecoverSpeed:String = "RagePowerRecoverSpeed";
    public static var _CritChance:String = "CritChance";
    public static var _DefendCritChance:String = "DefendCritChance";
    public static var _CritHurtChance:String = "CritHurtChance";
    public static var _CritDefendChance:String = "CritDefendChance";
    public static var _BlockHurtChance:String = "BlockHurtChance";
    public static var _RollerBlockChance:String = "RollerBlockChance";
    public static var _HurtAddChance:String = "HurtAddChance";
    public static var _HurtReduceChance:String = "HurtReduceChance";
    public static var _CounterAttackChance:String = "CounterAttackChance";
    public static var _RageRestoreWhenDamaged:String = "RageRestoreWhenDamaged";
    public static var _RageRestoreWhenDamageTarget:String = "RageRestoreWhenAttack";
    public static var _RageRestoreWhenKillTarget:String = "RageRestoreWhenKillTarget";
    public static var _MoveSpeed:String = "MoveSpeed";
    public static var _HitChance:String = "HitChance";
    public static var _DodgeChance:String = "DodgeChance";
    public static var _PercentEquipATK:String = "PercentEquipATK";
    public static var _PercentEquipDEF:String = "PercentEquipDEF";
    public static var _PercentEquipHP:String = "PercentEquipHP";
    public static var _BaseDamage:String = "BaseDamage";
    public static var _BaseHealing:String = "BaseHealing";
    public static var _CD:String = "CD";
    public static var _ConsumeAP:String = "ConsumeAP";
    public static var _ConsumePGP:String = "ConsumePGP";
    public static var _ConsumeGP:String = "ConsumeGP";
    public static var _ExCounterAttack:String = "ExCounterAttack";
    public static var _SkillReleaseAngerRecover:String = "SkillReleaseAngerRecover";
    public static var _SkillHitAngerRecover:String = "SkillHitAngerRecover";
    public static var _ExtraAttribute:String = "ExtraAttribute";
    public static var _AtkJobHurtAddChance:String = "AtkJobHurtAddChance";
    public static var _AtkJobHurtReduceChance:String = "AtkJobHurtReduceChance";
    public static var _DefJobHurtAddChance:String = "DefJobHurtAddChance";
    public static var _DefJobHurtReduceChance:String = "DefJobHurtReduceChance";
    public static var _TechJobHurtAddChance:String = "TechJobHurtAddChance";
    public static var _TechJobHurtReduceChance:String = "TechJobHurtReduceChance";
    public static var _DefaultAPRC:String = "DefaultAPRC";
    public static var _DefaultAPRS:String = "DefaultAPRS";
    public static var _TrueDamage:String = "TrueDamage";
    public static var _TrueResist:String = "TrueResist";


    //


    private static function _getList() : Object {
        if (_list == null) {
            _list = new Object();
            _list[_HP] = _HP;
            _list[_Attack] = _Attack;
            _list[_Defense] = _Defense;
            _list[_AttackPower] = _AttackPower;
            _list[_DefensePower] = _DefensePower;
            _list[_RagePower] = _RagePower;
            _list[_MaxHP] = _MaxHP;
            _list[_MaxAttackPower] = _MaxAttackPower;
            _list[_MaxDefensePower] = _MaxDefensePower;
            _list[_MaxRagePower] = _MaxRagePower;
            _list[_AttackPowerRecoverSpeed] = _AttackPowerRecoverSpeed;
            _list[_DefensePowerRecoverCD] = _DefensePowerRecoverCD;
            _list[_RagePowerRecoverSpeed] = _RagePowerRecoverSpeed;
            _list[_CritChance] = _CritChance;
            _list[_DefendCritChance] = _DefendCritChance;
            _list[_CritHurtChance] = _CritHurtChance;
            _list[_CritDefendChance] = _CritDefendChance;
            _list[_BlockHurtChance] = _BlockHurtChance;
            _list[_RollerBlockChance] = _RollerBlockChance;
            _list[_HurtAddChance] = _HurtAddChance;
            _list[_HurtReduceChance] = _HurtReduceChance;
            _list[_CounterAttackChance] = _CounterAttackChance;
            _list[_RageRestoreWhenDamaged] = _RageRestoreWhenDamaged;
            _list[_RageRestoreWhenDamageTarget] = _RageRestoreWhenDamageTarget;
            _list[_RageRestoreWhenKillTarget] = _RageRestoreWhenKillTarget;
            _list[_MoveSpeed] = _MoveSpeed;
            _list[_HitChance] = _HitChance;
            _list[_DodgeChance] = _DodgeChance;
            _list[_PercentEquipATK] = _PercentEquipATK;
            _list[_PercentEquipDEF] = _PercentEquipDEF;
            _list[_PercentEquipHP] = _PercentEquipHP;
            _list[_BaseDamage] = _BaseDamage;
            _list[_BaseHealing] = _BaseHealing;
            _list[_CD] = _CD;
            _list[_ConsumeAP] = _ConsumeAP;
            _list[_ConsumePGP] = _ConsumePGP;
            _list[_ConsumeGP] = _ConsumeGP;
            _list[_ExCounterAttack] = _ExCounterAttack;
            _list[_SkillReleaseAngerRecover] = _SkillReleaseAngerRecover;
            _list[_SkillHitAngerRecover] = _SkillHitAngerRecover;
            _list[_ExtraAttribute] = _ExtraAttribute;
        }
        return _list;
    }
    private static var _list:Object = null;
}
}
