//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property {

import QFLib.Foundation;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.level.CLevelMediator;
import kof.game.instance.IInstanceFacade;
import kof.game.level.ILevelFacade;
import kof.table.Monster;
import kof.util.CAssertUtils;

public class CMonsterProperty extends CCharacterProperty {

    private var m_pDBSys : IDatabase;
    private var m_pMonsterData : Monster;

    public function CMonsterProperty() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pDBSys = null;
        m_pMonsterData = null;
    }

    override public function get nickName() : String {
        if ( m_pMonsterData )
            return m_pMonsterData.Name;
        return super.nickName;
    }

    public function get shadow() : int {
        if ( m_pMonsterData )
            return m_pMonsterData.shadow;
        return 0;
    }

    public function get monsterType() : int {
        if ( m_pMonsterData )
            return m_pMonsterData.Type;
        return 0;
    }

    public function get style() : int {
        if ( m_pMonsterData )
            return m_pMonsterData.style;
        return 0;
    }

    public function get BeTargeted() : int {
        if ( m_pMonsterData )
            return m_pMonsterData.BeTargeted;
        return 1;
    }

    public function get dieCameraEffect() : Array {
        return m_pMonsterData.DieCameraEffect;
    }

    public function get disappearType() : int {
        return m_pMonsterData.DispearType;
    }

    public function get initialGravity() : int {
        return m_pMonsterData.initialgravity;
    }

    override public function get outsideName() : String {
        return m_pMonsterData.OutsideName;
    }

    override public function get weapon() : String {
        return m_pMonsterData.weapon;
    }

    public function get getupinvulnerable() : int {
        return m_pMonsterData.getupinvulnerable;
    }

    public function get bStopHitFrozen() : int {
        return m_pMonsterData.BStopHitFrozen;
    }

    override public function get aiID() : int {
        //召唤怪听从服务器数据 没有默认
        if ( CCharacterDataDescriptor.isSummoned( owner.data ) )
            return super.aiID;

        var ret : int = super.aiID;
        if ( !ret )
            return m_pMonsterData.AIID;
        return ret;
    }

    override public function get size() : Number {
        if ( m_pMonsterData ) {
            return m_pMonsterData.Size;
        }
        return 1.0;
    }

    public function get neverDead() : int {
        if ( m_pMonsterData ) {
            return m_pMonsterData.NeverDead;
        }
        return 0;
    }

    /** 怪物品质类型 */
    public function get quality() : int {
        return m_pMonsterData.Type;
    }

//    /** 攻击 */
//    public override function get attack() : int {
//        return m_pMonsterData.Attack;
//    }
//
//    /** 攻击 */
//    public override function get defense() : int {
//        return m_pMonsterData.Defense;
//    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        m_pDBSys = getComponent( IDatabase ) as IDatabase;
        _initialData();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        if ( owner.data.hasOwnProperty( "fightProperty" ) ) {
            updateFightProperty( owner.data.fightProperty );
            delete owner.data.fightProperty;
        }
    }

    override public function updateFightProperty( theFightProperty : Object ) : void {
        HP = _propertyInFightData( "HP", theFightProperty );
        Attack = _propertyInFightData( "Attack", theFightProperty );
        Defense = _propertyInFightData( "Defense", theFightProperty );
        AttackPower = _propertyInFightData( "AttackPower", theFightProperty );
        DefensePower = _propertyInFightData( "DefensePower", theFightProperty );
        RagePower = _propertyInFightData( "RagePower", theFightProperty );
        MaxHP = _propertyInFightData( "MaxHP", theFightProperty );
        MaxAttackPower = _propertyInFightData( "MaxAttackPower", theFightProperty );
        MaxDefensePower = _propertyInFightData( "MaxDefensePower", theFightProperty );
        MaxRagePower = _propertyInFightData( "MaxRagePower", theFightProperty );
        AttackPowerRecoverSpeed = _propertyInFightData( "AttackPowerRecoverSpeed", theFightProperty );
        DefensePowerRecoverCD = _propertyInFightData( "DefensePowerRecoverCD", theFightProperty );
        RagePowerRecoverSpeed = _propertyInFightData( "RagePowerRecoverSpeed", theFightProperty );
        CritChance = _propertyInFightData( "CritChance", theFightProperty );
        DefendCritChance = _propertyInFightData( "DefendCritChance", theFightProperty );
        CritHurtChance = _propertyInFightData( "CritHurtChance", theFightProperty );
        CritDefendChance = _propertyInFightData( "CritDefendChance", theFightProperty );
        BlockHurtChance = _propertyInFightData( "BlockHurtChance", theFightProperty );
        RollerBlockChance = _propertyInFightData( "RollerBlockChance", theFightProperty );
        HurtAddChance = _propertyInFightData( "HurtAddChance", theFightProperty );
        HurtReduceChance = _propertyInFightData( "HurtReduceChance", theFightProperty );
        CounterAttackChance = _propertyInFightData( "CounterAttackChance", theFightProperty );
        RageRestoreWhenDamaged = _propertyInFightData( "RageRestoreWhenDamaged", theFightProperty );
        RageRestoreWhenDamageTarget = _propertyInFightData( "RageRestoreWhenDamageTarget", theFightProperty );
        RageRestoreWhenKillTarget = _propertyInFightData( "RageRestoreWhenKillTarget", theFightProperty );
        RageRestoreAttackPowerConsume = _propertyInFightData( "RageRestoreAttackPowerConsume", theFightProperty );
        RageRestoreWhenHitted = _propertyInFightData( "RageRestoreWhenHitted", theFightProperty );
        RageRestoreWhenCombo = _propertyInFightData( "RageRestoreWhenCombo", theFightProperty );
        RageRestoreWhenMateKilled = _propertyInFightData( "RageRestoreWhenMateKilled", theFightProperty );
        AtkJobHurtAddChance = _propertyInFightData( "AtkJobHurtAddChance", theFightProperty);
        AtkJobHurtReduceChance = _propertyInFightData( "AtkJobHurtReduceChance", theFightProperty);
        DefJobHurtAddChance = _propertyInFightData( "DefJobHurtAddChance", theFightProperty);
        DefJobHurtReduceChance = _propertyInFightData( "DefJobHurtReduceChance", theFightProperty);
        TechJobHurtAddChance = _propertyInFightData( "TechJobHurtAddChance", theFightProperty);
        TechJobHurtReduceChance = _propertyInFightData( "TechJobHurtReduceChance", theFightProperty);
        defaultAPRC = _propertyInFightData( "DefaultAPRC", theFightProperty );
        defaultAPRS = _propertyInFightData( "DefaultAPRS", theFightProperty );
        TrueDamage = _propertyInFightData("TrueDamage" , theFightProperty);
        TrueResist = _propertyInFightData("TrueResist"  , theFightProperty);
    }

    private function _initialData() : void {
        var playerTable : IDataTable = m_pDBSys.getTable( KOFTableConstants.MONSTER );
        CAssertUtils.assertNotNull( playerTable, "Table for PlayerProperty required." );

        var pData : Monster = playerTable.findByPrimaryKey( this.prototypeID ) as Monster;

        if ( !pData ) {
            Foundation.Log.logErrorMsg( "Can't find the Monster from the MONSTER table by PK = " + this.prototypeID );
            return;
        }
        var monsterPropertyData : CMonsterPropertyData = new CMonsterPropertyData();
        var instanceFacade : IInstanceFacade = (owner.getComponentByClass( CLevelMediator, false ) as CLevelMediator).instanceFacade;
        monsterPropertyData = new CMonsterPropertyCale( instanceFacade, m_pDBSys, pData ).calcProperty() as CMonsterPropertyData;

        this.m_pMonsterData = pData;

        {

            this.HP = monsterPropertyData.HP;
            this.MaxHP = monsterPropertyData.HP;
            this.moveSpeed = pData.MoveSpeed;
            this.skinName = pData.SkinName;
            this.Attack = monsterPropertyData.Attack;
            this.Defense = monsterPropertyData.Defense;
            this.CritChance = monsterPropertyData.iCritRate;
            this.DefendCritChance = monsterPropertyData.iCritDefendRate;
            this.CritHurtChance = monsterPropertyData.iCritDamageRate;
            this.CritDefendChance = monsterPropertyData.iCritDamageDefendRate;
            this.BlockHurtChance = monsterPropertyData.iDamageBlockRate;
            this.RollerBlockChance = monsterPropertyData.iRollerBlockRate;
            this.HurtAddChance = monsterPropertyData.iDamageHardRate;
            this.HurtReduceChance = monsterPropertyData.iDamageReduceRate;


            // data initialize from Database.
            this.AttackPower = monsterPropertyData.iAttackPower;
            this.MaxAttackPower = monsterPropertyData.iAttackPower;
            this.attackPowerRecoverCD = monsterPropertyData.attackPowerRecoverCD;
            this.AttackPowerRecoverSpeed = monsterPropertyData.attackPowerRecoverSpeed;
            this.attackPowerRecoverAcceleration = monsterPropertyData.attackPowerRecoverAcceleration;
            this.attackPowerRecoverStopTime = monsterPropertyData.attackPowerRecoverStopTime;

            this.DefensePower = monsterPropertyData.iDefendPower;
            this.MaxDefensePower = monsterPropertyData.iDefendPower;
            this.DefensePowerRecoverCD = monsterPropertyData.defensePowerRecoverCD;
            this.defensePowerRecoverSpeed = monsterPropertyData.defensePowerRecoverSpeed;
            this.defensePowerRecoverAcceleration = monsterPropertyData.defensePowerRecoverAcceleration;
            this.defensePowerRecoverStopTime = monsterPropertyData.defensePowerRecoverStopTime;

            this.rollCost = monsterPropertyData.rollCost;
            this.driveRollCost = monsterPropertyData.driveRollCost;
            this.quickStandCost = monsterPropertyData.quickStandCost;
            this.rageRestoreComboInterval = monsterPropertyData.rageRestoreComboInterval;


            this.RagePower = monsterPropertyData.ragePowerInit;
            this.RageRestoreWhenDamaged = monsterPropertyData.rageRestoreWhenDamaged;
            this.RageRestoreAttackPowerConsume = monsterPropertyData.rageRestoreAttackPowerConsume;
            this.RageRestoreWhenHitted = monsterPropertyData.rageRestoreWhenHitted;
            this.RageRestoreWhenCombo = monsterPropertyData.rageRestoreWhenCombo;
            this.RageRestoreWhenKillTarget = monsterPropertyData.rageRestoreWhenKillTarget;
            this.RageRestoreWhenMateKilled = monsterPropertyData.rageRestoreWhenMateKilled;
            this.RagePowerRecoverSpeed = monsterPropertyData.rageRestoreSpeed;
            this.RageRestoreWhenDamageTarget = monsterPropertyData.rageRestoreWhenAttack;

            this.AtkJobHurtAddChance = monsterPropertyData.atkJobHurtAddChance;
            this.AtkJobHurtReduceChance = monsterPropertyData.atkJobHurtReduceChance;
            this.DefJobHurtAddChance = monsterPropertyData.defJobHurtAddChance;
            this.DefJobHurtReduceChance = monsterPropertyData.defJobHurtReduceChance;
            this.TechJobHurtAddChance = monsterPropertyData.techJobHurtAddChance;
            this.TechJobHurtReduceChance = monsterPropertyData.techJobHurtReduceChance;

            this.defaultAPRC = monsterPropertyData.defaultAPRC;
            this.defaultAPRS = monsterPropertyData.defaultAPRS;
            this.CounterAttackChance = monsterPropertyData.counterAttackChance;


            this.profession = pData.Profession;

            TrueDamage = monsterPropertyData.trueDamage;
            TrueResist = monsterPropertyData.trueResist;

//            this.rollCD = pData.RollCD;
//            this.quickStandCD = pData.QuickStandCD;
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pDBSys = null;
        m_pMonsterData = null;
    }

}
}
