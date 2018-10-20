//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property {

import kof.util.CObjectUtils;

public class CBuffProperty extends CCharacterProperty {

    private var m_pData : Object;

    public function CBuffProperty() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        this.extendData( owner.data );
        if( m_pData == null )
                m_pData = owner.data;

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
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

}
}
