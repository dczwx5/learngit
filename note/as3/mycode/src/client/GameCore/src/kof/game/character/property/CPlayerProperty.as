//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property {

import QFLib.Foundation;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.interfaces.ITXPlatformProperty;
import kof.game.instance.IInstanceFacade;
import kof.table.PlayerBasic;
import kof.util.CAssertUtils;

/**
 * @author Eddy
 */
public class CPlayerProperty extends CCharacterProperty implements ITXPlatformProperty {

    private var m_pDbSys : IDatabase;
    private var m_pPlayerData : PlayerBasic;
    private var m_pFightProperty : Object;

    public function CPlayerProperty() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        m_pDbSys = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        m_pDbSys = getComponent( IDatabase ) as IDatabase;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        var pTable : IDataTable = m_pDbSys.getTable( KOFTableConstants.PLAYER_BASIC );
        CAssertUtils.assertNotNull( pTable );

        var pData : PlayerBasic = pTable.findByPrimaryKey( this.prototypeID ) as PlayerBasic;

        if ( !pData ) {
            Foundation.Log.logErrorMsg( "Can't find the Player from the PLAYER_BASIC table by PK = " + this.prototypeID );
            return;
        }

        _updateBasicPropertyFromTable( pData );
        _updateInstanceProperty();

        if ( owner.data.hasOwnProperty( "fightProperty" ) ) {
            updateFightProperty( owner.data.fightProperty );
            delete owner.data.fightProperty;
        }

//        if ( owner.data.hasOwnProperty( "tx" ) ) {
//            updateTXPlatformProperty( owner.data.tx );
//            delete owner.data.tx;
//        }

        if (owner.data.hasOwnProperty("platformInfo")) {
            var platformInfo:Object = owner.data.platformInfo;
            if (platformInfo) {
                var platformDescData:Object = platformInfo.data;
                if (platformDescData) {
                    updateTXPlatformProperty( platformDescData );
                    delete owner.data.platformInfo;
                }
            }
        }

        if( owner.data.hasOwnProperty( "vipLevel")){
            vipLevel = owner.data.vipLevel;
            delete owner.data.vipLevel;
        }

        if( owner.data.hasOwnProperty("title")){
            honorID = owner.data.title;
            delete  owner.data.title;
        }
    }

    private function _updateBasicPropertyFromTable( pData : PlayerBasic ) : void {
        this.m_pPlayerData = pData;
        {
            this.attackPowerRecoverCD = pData.AttackPowerRecoverCD;
            this.attackPowerRecoverAcceleration = pData.AttackPowerRecoverAcceleration;
            this.attackPowerRecoverStopTime = pData.AttackPowerRecoverStopTime;

            this.defensePowerRecoverSpeed = pData.DefensePowerRecoverSpeed;
            this.defensePowerRecoverAcceleration = pData.DefensePowerRecoverAcceleration;
            this.defensePowerRecoverStopTime = pData.DefensePowerRecoverStopTime;

            this.rollCost = pData.RollCost;
            this.driveRollCost = pData.DriveRollCost;
            this.quickStandCost = pData.QuickStandCost;
            this.rollCD = pData.RollCD;
            this.quickStandCD = pData.QuickStandCD;
            this.namedOffsetY = pData.NamedOffsetY;
            this.profession = pData.Profession;
            this.quickStandStopTime = pData.QuickStandStopTime;
            this.CounterAttackChance = pData.CounterAttackChance;
        }
    }

    private function _updateInstanceProperty() : void {
        var pInstenceFacade : CLevelMediator = owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
        if ( !pInstenceFacade || !pInstenceFacade.instanceFacade )
            return;

        this.rageRestoreComboInterval = pInstenceFacade.instanceFacade.rageRestoreComboInterval;
    }

    override public function updateFightProperty( fightProperty : Object ) : void {
        HP = _propertyInFightData( "HP", fightProperty );
        Attack = _propertyInFightData( "Attack", fightProperty );
        Defense = _propertyInFightData( "Defense", fightProperty );
        AttackPower = _propertyInFightData( "AttackPower", fightProperty );
        DefensePower = _propertyInFightData( "DefensePower", fightProperty );
        RagePower = _propertyInFightData( "RagePower", fightProperty );
        MaxHP = _propertyInFightData( "MaxHP", fightProperty );
        MaxAttackPower = _propertyInFightData( "MaxAttackPower", fightProperty );
        MaxDefensePower = _propertyInFightData( "MaxDefensePower", fightProperty );
        MaxRagePower = _propertyInFightData( "MaxRagePower", fightProperty );
        AttackPowerRecoverSpeed = _propertyInFightData( "AttackPowerRecoverSpeed", fightProperty );
        DefensePowerRecoverCD = _propertyInFightData( "DefensePowerRecoverCD", fightProperty );
        RagePowerRecoverSpeed = _propertyInFightData( "RagePowerRecoverSpeed", fightProperty );
        CritChance = _propertyInFightData( "CritChance", fightProperty );
        DefendCritChance = _propertyInFightData( "DefendCritChance", fightProperty );
        CritHurtChance = _propertyInFightData( "CritHurtChance", fightProperty );
        CritDefendChance = _propertyInFightData( "CritDefendChance", fightProperty );
        BlockHurtChance = _propertyInFightData( "BlockHurtChance", fightProperty );
        RollerBlockChance = _propertyInFightData( "RollerBlockChance", fightProperty );
        HurtAddChance = _propertyInFightData( "HurtAddChance", fightProperty );
        HurtReduceChance = _propertyInFightData( "HurtReduceChance", fightProperty );
        CounterAttackChance = _propertyInFightData( "CounterAttackChance", fightProperty );
        RageRestoreWhenDamaged = _propertyInFightData( "RageRestoreWhenDamaged", fightProperty );
        RageRestoreWhenDamageTarget = _propertyInFightData( "RageRestoreWhenDamageTarget", fightProperty );
        RageRestoreWhenKillTarget = _propertyInFightData( "RageRestoreWhenKillTarget", fightProperty );
        RageRestoreAttackPowerConsume = _propertyInFightData( "RageRestoreAttackPowerConsume", fightProperty );
        RageRestoreWhenHitted = _propertyInFightData( "RageRestoreWhenHitted", fightProperty );
        RageRestoreWhenCombo = _propertyInFightData( "RageRestoreWhenCombo", fightProperty );
        RageRestoreWhenMateKilled = _propertyInFightData( "RageRestoreWhenMateKilled", fightProperty );
        AtkJobHurtAddChance = _propertyInFightData("AtkJobHurtAddChance" , fightProperty);
        AtkJobHurtReduceChance = _propertyInFightData("AtkJobHurtReduceChance" , fightProperty );
        DefJobHurtAddChance = _propertyInFightData("DefJobHurtAddChance" , fightProperty);
        DefJobHurtReduceChance = _propertyInFightData("DefJobHurtReduceChance" , fightProperty );
        TechJobHurtAddChance = _propertyInFightData("TechJobHurtAddChance" , fightProperty);
        TechJobHurtReduceChance = _propertyInFightData("TechJobHurtReduceChance" , fightProperty );
        defaultAPRC = _propertyInFightData( "DefaultAPRC", fightProperty);
        defaultAPRS = _propertyInFightData( "DefaultAPRS", fightProperty);

        TrueDamage = _propertyInFightData("TrueDamage" , fightProperty);
        TrueResist = _propertyInFightData("TrueResist"  , fightProperty);
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pDbSys = null;
    }

    private function updateTXPlatformProperty( data : Object ) : void {
        this.pf = data.pf;
        this.isBlueYearVip = data.isBlueYearVip;
        this.blueVipLevel = data.blueVipLevel;
        this.isBlueVip = data.isBlueVip;
        this.isSuperBlueVip = data.isSuperBlueVip;
        this.isYellowHighVip = data.isYellowHighVip;
        this.yellowVipLevel = data.yellowVipLevel;
        this.isYellowYearVip = data.isYellowYearVip;
        this.isYellowVip = data.isYellowVip;
    }

    override public function get aiID() : int {
        var ret : int = super.aiID;
//        if ( !ret )
//            return m_pPlayerData.AIID;
        return ret;
    }

    public function get pf() : String {
        return data.pf;
    }

    public function get yellowVipLevel() : int {
        return data.yellowVipLevel;
    }

    public function get isYellowYearVip() : int {
        return data.isYellowYearVip;
    }

    public function get isBlueYearVip() : int {
        return data.isBlueYearVip;
    }

    public function get blueVipLevel() : int {
        return data.blueVipLevel;
    }

    public function set pf( pf : String ) : void {
        if ( this.pf == pf ) return;
        data.pf = pf;
    }

    public function set yellowVipLevel( level : int ) : void {
        if ( this.yellowVipLevel == level ) return;
        data.yellowVipLevel = level;
    }

    public function set isYellowYearVip( isYear : int ) : void {
        if ( this.isYellowYearVip == isYear ) return;
        data.isYellowYearVip = isYear;
    }

    public function set isBlueYearVip( isBlueYear : int ) : void {
        if ( this.isBlueYearVip == isBlueYear )
            return;
        data.isBlueYearVip = isBlueYear;
    }

    public function set blueVipLevel( level : int ) : void {
        if ( this.blueVipLevel == level )
            return;
        data.blueVipLevel = level;
    }

    public function get isBlueVip() : int {
        return data.isBlueVip;
    }

    public function set isBlueVip( isBV : int ) : void {
        if ( isBlueVip == isBV ) return;
        data.isBlueVip = isBV;
    }

    public function get  isYellowVip() : int{
        return data.isYellowVip;
    }

    public function set  isYellowVip( isYellowVip : int ) : void{
        if( isYellowVip == this.isYellowVip ) return;
        data.isYellowVip = isYellowVip;
    }

    public function get isYellowHighVip() : int{
        return data.isYellowHighVip;
    }

    public function set isYellowHighVip( isYHV : int) : void{
        if( isYellowHighVip == isYHV ) return;
        data.isYellowHighVip = isYHV;
    }

    public function get  isSuperBlueVip() : int{
        return data.isSuperBlueVip;
    }

    public function set isSuperBlueVip( isSBV : int) : void {
        if ( isSuperBlueVip == isSBV )return;
        data.isSuperBlueVip = isSBV;
    }

    public function get vipLevel() :int{
        return data.vipLevel;
    }

    public function set vipLevel( value : int) : void{
        if( vipLevel == value )
                return;
        data.vipLevel = value;
    }

    public function get honorID() : int {
        return data.honorID;
    }

    public function set honorID( value : int ) : void{
        if( honorID == value )
                return;
        data.honorID = value;
    }

    public function get namedOffsetY() : int {
        return data.namedOffsetY;
    }

    public function set namedOffsetY( value : int ) : void {
        if ( this.namedOffsetY == value )
                return;
        data.namedOffsetY = value;
    }

}
}
