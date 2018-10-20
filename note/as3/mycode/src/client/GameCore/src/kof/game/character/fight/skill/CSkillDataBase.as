//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/27.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.ActionSeq;
import kof.table.Aero;
import kof.table.AeroAbsorber;
import kof.table.BuffEmitter;
import kof.table.Chain;
import kof.table.Chain.ECastType;
import kof.table.ChainCondition;
import kof.table.ChainCondition;
import kof.table.ChainKeyCondition;
import kof.table.ChainKeyCondition;
import kof.table.ChainPropertyStatus;
import kof.table.ChainPropertyStatus;
import kof.table.Criteria;
import kof.table.Criteria;
import kof.table.Damage;
import kof.table.Emitter;
import kof.table.Healing;
import kof.table.Hit;
import kof.table.HitShake;
import kof.table.HitShake;
import kof.table.Motion;
import kof.table.ScreenEffect;
import kof.table.Skill;
import kof.table.Skill.EEffectType;
import kof.table.SkillRush;
import kof.table.Summoner;
import kof.table.Teleport;
import kof.util.CAssertUtils;

/**
 * 主要考虑到其它的地方会用到技能描述等数据，一个单例的
 */
public class CSkillDataBase {

    public function CSkillDataBase( dbSys : IDatabase ) {
        m_pDBSys = dbSys;
    }

    public static function createSkillDataBase( dbSys : IDatabase ) : CSkillDataBase {
        if ( null == m_instance ) {
            m_instance = new CSkillDataBase( dbSys );
        }

        return m_instance;
    }

    final public function get skillTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.SKILL );
    }

    final public function get hitTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.HIT );
    }

    final public function get catchTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.SKILL_CATCH );
    }

    final public function get catchEndTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.SKILL_CATCH_END );
    }

    final public function get damageTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.DAMAGE );
    }

    final public function get motionTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.MOTION );
    }

    final public function get chainTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.Chain );
    }

    final public function get criteriaTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.HIT_CRITERIA );
    }

    final public function get hitShakeTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.HITSHAKE );
    }

    final public function get chainPropertyStatus() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.ChainPropertyStatus );
    }

    final public function get chainConditionTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.ChainCondition );
    }

    final public function get chainKeyConditionTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.ChainKeyCondition );
    }

    final public function get buffEmitterTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.BUFF_EMITTER );
    }

    final public function get AeroTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.AERO );
    }

    final public function get SummonerTable() : IDataTable{
        return m_pDBSys.getTable( KOFTableConstants.SUMMONER);
    }

    final public function get screenEffectTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.SCREEN_EFFECT );
    }

    final public function get teleportEffectTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.TELEPORT_EFFECT );
    }

    final public function get HealingEffectTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.HEALING );
    }

    final public function get  SkillRushTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.SKILLRUSH );
    }

    final public function get EmmiterTable() : IDataTable {
        return m_pDBSys.getTable( KOFTableConstants.EMITTER );
    }

    final public function get SkillAeroAbsorbTable() : IDataTable{
        return m_pDBSys.getTable( KOFTableConstants.AERO_ABSORBER);
    }

    final public function getSkillDataByID( skillID : int, logMsg : String = "" ) : Skill {
        if ( skillID <= 0 ) return null;
        var skill : Skill = skillTable.findByPrimaryKey( skillID ) as Skill;
        if ( !skill ) {
            CSkillDebugLog.logErrorMsg( "Skill Table has not Item that Specify ID = " + skillID + " <->" + logMsg );
            CAssertUtils.assertNotNull( skill, "Skill Table has not Item that Specify ID = " + skillID );
        }
        return skill;
    }

    final public function getDamageByID( actionID : int, logMsg : String = "" ) : Damage {
        if ( actionID <= 0 ) return null;
        var damage : Damage = damageTable.findByPrimaryKey( actionID ) as Damage;
        if ( !damage ) {
            CSkillDebugLog.logErrorMsg( "Damage Table has not Item that Specify ID = " + actionID + "<->" + logMsg );
            CAssertUtils.assertNotNull( damage, "Damage Table has not Item that Specify ID = " + actionID );
        }
        return damage;
    }

    final public function getHitDataByID( hitID : int, logMsg : String = "" ) : Hit {
        if ( hitID <= 0 ) return null;
        var hit : Hit = hitTable.findByPrimaryKey( hitID ) as Hit;
        if ( !hit ) {
            CSkillDebugLog.logErrorMsg( "Hit Table has not Item that Specify ID = " + hitID + "<->" + logMsg );
            CAssertUtils.assertNotNull( hit, "Hit Table has not Item that Specify ID = " + hitID );
        }
        return hit;
    }

    final public function getMotionDataByID( motionID : int, logMsg : String = "" ) : Motion {
        if ( motionID <= 0 ) return null;
        var motion : Motion = motionTable.findByPrimaryKey( motionID ) as Motion;
        if ( !motion ) {
            CSkillDebugLog.logErrorMsg( "Motion Table has not Item that Specify ID = " + motionID + "<->" + logMsg );
            CAssertUtils.assertNotNull( motion, "Motion Table has not Item that Specify ID = " + motionID );
        }
        return motion;
    }

    final public function getSkillChainByID( skillID : int, logMsg : String = '' ) : Chain {
        if ( skillID <= 0 ) return null;
        var chain : Chain = chainTable.findByPrimaryKey( skillID ) as Chain;
        if ( !chain ) {
            CSkillDebugLog.logErrorMsg( "Chain Table has not Item that Specify ID = " + skillID + "<->" + logMsg );
            CAssertUtils.assertNotNull( chain, "Chain Table has not Item that Specify ID = " + skillID );
        }
        return chain;
    }

    final public function getCriteriaByID( id : int, logMsg : String = '' ) : Criteria {
        if ( id <= 0 ) return null;
        var criteria : Criteria = criteriaTable.findByPrimaryKey( id ) as Criteria;
        if ( !criteria ) {
            CSkillDebugLog.logErrorMsg( "Criteria Table has not Item that Specify ID = " + id + "<->" + logMsg );
            CAssertUtils.assertNotNull( criteria, "Criteria Table has not Item that Specify ID = " + id );
        }
        return criteria;

    }

    final public function getChainCondition( ccID : int, logMsg : String = "" ) : ChainCondition {
        if ( ccID <= 0 ) return null;
        var chainCondition : ChainCondition = chainConditionTable.findByPrimaryKey( ccID );
        if ( !chainCondition ) {
            CSkillDebugLog.logErrorMsg( "ChainCondition Table has not Item that Specify ID = " + ccID + "<->" + logMsg );
            CAssertUtils.assertNotNull( chainCondition, "ChainCondition Table has not Item that Specify ID = " + ccID );
        }
        return chainCondition
    }

    final public function getChainKeyCondition( kID : int ) : ChainKeyCondition {
        if ( kID <= 0 ) return null;
        var keyCon : ChainKeyCondition = chainKeyConditionTable.findByPrimaryKey( kID );
        if ( !keyCon ) {
            CSkillDebugLog.logErrorMsg( "ChainKeyCondition Table has not Item that Specify ID = " + kID );
            CAssertUtils.assertNotNull( keyCon, "ChainKeyCondition Table has not Item that Specify ID = " + kID );
        }
        return keyCon;
    }

    final public function getAeroByID( aID : int, logMsg : String = '' ) : Aero {
        if ( aID <= 0 ) return null;
        var aero : Aero = AeroTable.findByPrimaryKey( aID );
        if ( !aero ) {
            CSkillDebugLog.logErrorMsg( "Aero Table has not Item that Specify ID = " + aID + "<->" + logMsg );
            CAssertUtils.assertNotNull( aero, "Aero Table has not Item that Specify ID = " + aID );
        }
        return aero;
    }

    final public function getEmmiterByID( eID : int ) : Emitter {
        if ( eID <= 0 ) return null;
        var emitter : Emitter = EmmiterTable.findByPrimaryKey( eID );
        if ( !emitter ) {
            CSkillDebugLog.logErrorMsg( "Emmiter Table has not Item that Specify ID = " + eID );
            CAssertUtils.assertNotNull( emitter, "Emmiter Table has not Item that Specify ID = " + eID );
        }
        return emitter;
    }

    final public function getHitShakeByID( hID : int ) : HitShake {
        if ( hID <= 0 ) return null;
        var hs : HitShake = hitShakeTable.findByPrimaryKey( hID );
        if ( !hs )
            CSkillDebugLog.logErrorMsg( "HitShake Table has not Item that Specify ID = " + hID );
        CAssertUtils.assertNotNull( hs, "HitShake Table has not Item that Specify ID = " + hID );
        return hs;
    }

    final public function getChainPropertyStatus( sID : int ) : ChainPropertyStatus {
        if ( sID <= 0 ) return null;
        var chainStatus : ChainPropertyStatus = chainPropertyStatus.findByPrimaryKey( sID );
        if ( !chainStatus )
            CSkillDebugLog.logErrorMsg( "ChainPropertyStatus Table has not Item that Specify ID = " + sID );
        CAssertUtils.assertNotNull( chainStatus, "ChainPropertyStatus Table has not Item that Specify ID = " + sID );
        return chainStatus;
    }

    final public function getBuffEmitterByInfo( ID : * ) : BuffEmitter {
        if ( ID <= 0 ) return null;
        var buffEmitter : BuffEmitter = buffEmitterTable.findByPrimaryKey( ID );
        if ( !buffEmitter )
            CSkillDebugLog.logErrorMsg( "BuffEmitter Table has not Item that Specify ID = " + ID );
        CAssertUtils.assertNotNull( buffEmitter, "BuffEmitter Table has not Item that Specify ID = " + ID );
        return buffEmitter;
    }

    final public function getSceenEffectByID( ID : int ) : ScreenEffect {
        if ( ID <= 0 ) return null;
        var screenShake : ScreenEffect = screenEffectTable.findByPrimaryKey( ID );
        if ( !screenShake )
            CSkillDebugLog.logErrorMsg( "ScreenEffect Table has not Item that Specify ID = " + ID );
        CAssertUtils.assertNotNull( screenShake, "ScreenEffect Table has not Item that Specify ID = " + ID );
        return screenShake;
    }

    final public function getTeleportEffectByID( id : int ) : Teleport {
        if ( id <= 0 ) return null;
        var teleEff : Teleport = teleportEffectTable.findByPrimaryKey( id );
        if ( !teleEff )
            CSkillDebugLog.logErrorMsg( " Teleport Table has not Item that Specify ID = " + id );
        CAssertUtils.assertNotNull( teleEff, " Teleport Table has not Item that Specify ID = " + id );
        return teleEff;
    }

    final public function getHealingEffectByID( id : int ) : Healing {
        if ( id <= 0 ) return null;
        var healEff : Healing = HealingEffectTable.findByPrimaryKey( id );
        if ( !healEff ) {
            CSkillDebugLog.logErrorMsg( " Healing Table has not Item that Specify ID = " + id );
        }
        CAssertUtils.assertNotNull( healEff, " Healing Table has not Item that Specify ID = " + id );
        return healEff;
    }

    final public function getSkillRushEffectByID( id : int ) : SkillRush {
        if ( id <= 0 ) return null;
        var rushEff : SkillRush = SkillRushTable.findByPrimaryKey( id );
        if ( !rushEff ) {
            CSkillDebugLog.logErrorMsg( " Rush Table has not Item that Specify ID = " + id );
        }

        return rushEff;
    }

    final public function getAeroAbsorberByID( id : int ) : AeroAbsorber {
        if( id <=0 ) return null
        var aeroAbsorber : AeroAbsorber = SkillAeroAbsorbTable.findByPrimaryKey( id );
        if( !aeroAbsorber )
        {
            CSkillDebugLog.logErrorMsg( " AeroAbsorber Table has not Item that Specify ID = " + id );
        }
        return aeroAbsorber;
    }

    final public function getSummoner( id : int ) : Summoner{
        if( id <= 0 ) return null;
        var summoner : Summoner = SummonerTable.findByPrimaryKey( id );
        if( !summoner ){
            CSkillDebugLog.logErrorMsg("Summoner table has not Item that Specify ID = " + id );
        }

        return summoner;
    }

    private var m_pDBSys : IDatabase;
    private static var m_instance : CSkillDataBase;
    /**
     * Union of China service phone number;
     */
    public static const SKILL_ID_DODGE_SIM : int = 1000011;
    /**
     * China mobile service phone number;
     */
    public static const SKILL_ID_QUICKSTAND_SIM : int = 1008611;
    /**
     * some params of  timer type in skill excel，must tranfer to real time tick,
     * we use 30 frames in one second in unity editor,if editor change its frame'length,  keep consistent here.
     */
    public static var TIME_IN_ONEFRAME : Number = 0.033;

}
}
