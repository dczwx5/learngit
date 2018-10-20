//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/30.
//----------------------------------------------------------------------
package kof.game.character.property {

public class CMissileProperty extends CCharacterProperty {
    public function CMissileProperty() {
        super();
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        if ( owner.data && owner.data.hasOwnProperty( 'missileId' ) ) {
            missileId = owner.data.missileId;
        }

        if ( owner.data && owner.data.hasOwnProperty( "missileSeq" ) ) {
            missileSeq = owner.data.missileSeq;
        }

        if ( owner.data && owner.data.hasOwnProperty( "missileHP" ) ) {
            missileHP = owner.data.missileHP;
        }

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

    }

    //配置表的ID
    public function get missileId() : int {
        return data.missileId;
    }

    public function set missileId( value : int ) : void {
        if ( this.missileId == value )
            return;
        data.missileId = value;
    }

    //唯一标识ID
    public function get missileSeq() : Number{
        return data.missileSeq;
    }

    public function set missileSeq( value : Number) : void {
        if ( this.missileSeq == value )
            return;
        data.missileSeq = value;
    }

    public function get missileHP() : int {
        return data.missileHP;
    }

    public function set missileHP( value : int ) : void {
        if ( this.missileHP == value )
            return;
        data.missileHP = value;
        setPropertyChanged( ECharacterConst.missileHP, value );
    }

}
}
