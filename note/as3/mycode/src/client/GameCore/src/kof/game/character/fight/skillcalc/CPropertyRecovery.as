//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/30.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc {

import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;

import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.level.CLevelMediator;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.util.CAssertUtils;

import org.msgpack.NullWorker;

/**
 * 各种属性回复机制
 */
public class CPropertyRecovery implements IUpdatable {
    public function CPropertyRecovery( pFightCal : CFightCalc ) {
        m_pFightCal = pFightCal;
    }

    private function getRecordTypes() : Array {
        return [ RECOVERY_TYPE_AP, RECOVERY_TYPE_DP, RECOVERY_TYPE_RP, RECOVERY_TYPE_AP_IN_SKILL ];
    }

    public function dispose() : void {
        if ( m_recoveryRecords )
            m_recoveryRecords.clear();

        m_recoveryRecords = null
    }

    public function update( delta : Number ) : void {

        var record : _recoveryInfo;
        var nextAddValue : Number;
        for ( var key : int in m_recoveryRecords ) {
            record = m_recoveryRecords[ key ];

            var boNeedUpdate : Boolean = !checkMaxPower( key ) || checkZeroPower( key );

            if ( !boNeedUpdate )
                continue;

            if ( !_checkSkillAllowRecovery( key ) )
                continue;

            if ( record.stoppedTime > 0.0 ) {
                record.stoppedTime -= delta;
                continue;
            }

//            CAssertUtils.assertNotEquals( record.recoveryCD , 0 ,"属性：攻击值，防御值回复间隔不能为0");
            if ( int( record.elapseTime / record.recoveryCD ) > record.recordCount || record.recordCount == 0 ) {

                nextAddValue = record.recordCount * ( record.recoveryAcceleration ) + record.recoverySpeed;
                if ( record.type == RECOVERY_TYPE_AP || record.type == RECOVERY_TYPE_AP_IN_SKILL ) {
                    m_pFightCal.battleEntity.calcAttackPower( nextAddValue, false );
                }
                else if ( record.type == RECOVERY_TYPE_DP ) {
                    var monsterProperty : CMonsterProperty = m_pICharacterProperty as CMonsterProperty;
                    if ( monsterProperty )
                        m_pFightCal.battleEntity.calcDefensePower( nextAddValue, false, true );
                    else {
                        var pLevelFacade : CLevelMediator = pLevelMediator;
                        if ( pLevelFacade ) {
                            if ( pLevelFacade.isPVE ) {
                                m_pFightCal.battleEntity.calcDefensePower( nextAddValue, false, true );
                            }
                        }
                    }

                } else if ( record.type == RECOVERY_TYPE_RP ) {
                    m_pFightCal.battleEntity.calcRagePower( nextAddValue, false, true );
                }
                record.recordCount = record.recordCount + 1;
            }

            record.elapseTime = record.elapseTime + delta;
        }

    }

    private function checkMaxPower( type : int ) : Boolean {
        var ret : Boolean;
        if ( type == RECOVERY_TYPE_AP || type == RECOVERY_TYPE_AP_IN_SKILL ) {
            ret = m_pFightCal.battleEntity.boIsMaxAttackPower;
        }
        else if ( type == RECOVERY_TYPE_DP ) {
            ret = m_pFightCal.battleEntity.boIsMaxDefensePower;
        } else if ( type == RECOVERY_TYPE_RP ) {
            ret = m_pFightCal.battleEntity.boIsMaxRagePower;
        }
        var record : _recoveryInfo = m_recoveryRecords.find( type );

        if ( ret ) {
            record.recordCount = 0;
            record.elapseTime = 0;
        }

        return ret;

    }

    private function checkZeroPower( type : int ) : Boolean {
        var ret : Boolean;
        if ( type == RECOVERY_TYPE_AP || type == RECOVERY_TYPE_AP ) {
            ret = m_pFightCal.battleEntity.boIsZeroAttackPower;
        }
        else if ( type == RECOVERY_TYPE_DP ) {
            ret = m_pFightCal.battleEntity.boIsZeroDefensePower;
        }
        return ret;
    }

    private function _checkSkillAllowRecovery( type : int ) : Boolean {

        var pLevelFacade : CLevelMediator = pLevelMediator;
        var bPvP : Boolean;
        if ( pLevelFacade )
            bPvP = !pLevelFacade.isPVE && !pLevelFacade.isMainCity;

        if ( type == RECOVERY_TYPE_AP && pSkillCaster ) {
            if ( bPvP )
                return false;

            return pSkillCaster.isAllowRecoveryAttackPower();
        } else if ( type == RECOVERY_TYPE_AP_IN_SKILL ) {
            if ( bPvP )
                return false;
            return pSkillCaster.skillID != 0;
        }

        return true;
    }

    public function set pCharacterProperty( value : CCharacterProperty ) : void {
        m_pICharacterProperty = value;

        if ( null == m_recoveryRecords ) {
            m_recoveryRecords = new CMap;
            var recoverys : Array = getRecordTypes();
            var rInfo : _recoveryInfo;

            for ( var i : int = 0; i < recoverys.length; ++i ) {
                if ( recoverys[ i ] == RECOVERY_TYPE_AP ) {
                    rInfo = _buildRecoveryInfo( RECOVERY_TYPE_AP,
                            m_pICharacterProperty.attackPowerRecoverCD / 1000,
                            m_pICharacterProperty.AttackPowerRecoverSpeed,
                            m_pICharacterProperty.attackPowerRecoverAcceleration,
                            m_pICharacterProperty.attackPowerRecoverStopTime / 1000 );
                }
                if ( recoverys[ i ] == RECOVERY_TYPE_DP ) {
                    rInfo = _buildRecoveryInfo( RECOVERY_TYPE_DP,
                            m_pICharacterProperty.DefensePowerRecoverCD / 1000,
                            m_pICharacterProperty.defensePowerRecoverSpeed,
                            m_pICharacterProperty.defensePowerRecoverAcceleration,
                            m_pICharacterProperty.defensePowerRecoverStopTime / 1000 );
                }

                if ( recoverys[ i ] == RECOVERY_TYPE_RP ) {
                    rInfo = _buildRecoveryInfo( RECOVERY_TYPE_RP,
                            m_pICharacterProperty.rageRestoreComboInterval
                            , m_pICharacterProperty.RagePowerRecoverSpeed, 0, 0 );
                }

                if ( recoverys[ i ] == RECOVERY_TYPE_AP_IN_SKILL ) {
                    rInfo = _buildRecoveryInfo( RECOVERY_TYPE_AP_IN_SKILL,
                            m_pICharacterProperty.defaultAPRC / 1000,
                            m_pICharacterProperty.defaultAPRS,
                            m_pICharacterProperty.attackPowerRecoverAcceleration,
                            0.0 );
                }

                m_recoveryRecords.add( recoverys[ i ], rInfo );
            }
        }
    }

    private function _buildRecoveryInfo( type : int, cd : Number, speed : Number, Acc : Number, stopTime : Number ) : _recoveryInfo {
        var rInfo : _recoveryInfo = new _recoveryInfo();
        rInfo.type = type;
        rInfo.recoveryCD = cd;
        rInfo.recoverySpeed = speed;
        rInfo.recoveryAcceleration = Acc;
        rInfo.recoveryStopTime = stopTime;
        return rInfo;
    }

    public function resetRecoveryByType( type : int ) : void {
        var rInfo : _recoveryInfo = m_recoveryRecords.find( type ) as _recoveryInfo;
        rInfo.recordCount = 0;
        rInfo.elapseTime = 0;
        rInfo.stoppedTime = rInfo.recoveryStopTime;
    }

    public function get pLevelMediator() : CLevelMediator {
        return m_pFightCal.owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
    }

    public function resetAttackPowerRecovery() : void {
        resetRecoveryByType( RECOVERY_TYPE_AP );
//        resetRecoveryByType( RECOVERY_TYPE_AP_IN_SKILL );
    }

    final private function get pSkillCaster() : CSkillCaster {
        return m_pFightCal.owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }


    private var m_pICharacterProperty : CCharacterProperty;
    public static const RECOVERY_TYPE_AP : int = 0;
    public static const RECOVERY_TYPE_DP : int = 1;
    public static const RECOVERY_TYPE_RP : int = 2;
    public static const RECOVERY_TYPE_AP_IN_SKILL : int = 3;

    private var m_recoveryRecords : CMap;
    private var m_pFightCal : CFightCalc;


}
}

class _recoveryInfo {
    public var elapseTime : Number = 0.0;
    public var stoppedTime : Number = 0.0;
    public var recordCount : int = 0;
    public var recoverySpeed : Number = 0.0;
    public var recoveryCD : Number = 0.0;
    public var recoveryStopTime : Number = 0.0;
    public var recoveryAcceleration : Number = 0.0;
    public var type : int;
}
