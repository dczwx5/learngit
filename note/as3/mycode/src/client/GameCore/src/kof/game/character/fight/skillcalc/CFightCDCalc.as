//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/9/2.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc {

import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.game.character.ai.CAIComponent;

import kof.game.character.ai.CAILog;

import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.property.CSkillItemProperty;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skill.property.ISkillItemProperty;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.INeedSync;
import kof.game.core.CGameObject;
import kof.table.Skill;

import org.msgpack.NullWorker;

public class CFightCDCalc implements IUpdatable{
    public function CFightCDCalc( owner : CGameObject ) {
        m_skillCDPool = new CMap();
        m_pOwner = owner;
        initialize();
    }

    public function dispose() : void
    {
        if( m_pOwner ) {
            var pTrigger : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if( pTrigger ) pTrigger.removeEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL , _onDriveRemoveCD );
        }
        m_skillCDPool.clear();
        m_skillCDPool = null;
    }

    public function initialize() : void
    {
        if( m_pOwner )
        {
            var pTrigger: CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
            pTrigger.addEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL , _onDriveRemoveCD );
        }
    }

    public function update( delta : Number ) : void
    {
        for ( var key : int in m_skillCDPool )
        {
            var cding : Number;
            if( _isInSameSkill( key ) )
                    continue;
            cding = m_skillCDPool[ key ] - delta;
            m_skillCDPool[ key ] = cding;

            if( cding <= 0 )
                    removeSkillCD( key );
        }
    }

    public function addSkillCD( skillID : int) : Boolean
    {

        if( !isNeedCDEvaluate( skillID )) return false;

        var cd : Number  = m_skillCDPool.find( skillID );
        if( cd >= 0.0)
            return false;

        var CD : Number = pSkillPropertyComponent.getSkillCD( skillID );
        m_skillCDPool.add( skillID , CD );
        CSkillDebugLog.logTraceMsg( "CD加入释放CD队列 ID = " + skillID);
        return true;
    }

    public function addCommoneCD( skillID : int , time : Number ) : Boolean
    {
        var cd : Number = m_skillCDPool.find( skillID );
        if( cd > 0.0 )
                return false;

        m_skillCDPool.add( skillID , time );
        CSkillDebugLog.logTraceMsg( "CCD加入释放cd队列 ID =" + skillID );
        return true;
    }

    private function _isInSameSkill(  skillId : int ) : Boolean
    {
        var pSkillCaster : CSkillCaster = m_pOwner.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
        if( pSkillCaster ) {
            return pSkillCaster.isInSameMainSkill( skillId );
        }

        return false;
    }

    private function isNeedCDEvaluate( skillID : int ) : Boolean
    {
        var cd : Number;
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );

        if( !skillData )
            return false;

        cd = pSkillPropertyComponent.getSkillCD( skillID );

        if( cd <= 0.0 )return false;

        return true;
    }

    public function get skillCDPool() : CMap
    {
        return m_skillCDPool;
    }

    public function isInCD( skillID : int ) : Boolean
    {
        if( !isNeedCDEvaluate(skillID) ) return false;

        var cd : Number = m_skillCDPool.find(skillID);
        if(cd && cd > 0.0) {
            CSkillDebugLog.logTraceMsg( "你的技能还在CD中 不能释放 ID = " + skillID);
            var aiComponet:CAIComponent = m_pOwner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.warningMsg("你的技能还在CD中 不能释放 ID = " + skillID,aiComponet.objId);
            return true;
        }

        return false;
    }

    public function removeSkillCD( skillID : int) : void
    {
        delete m_skillCDPool[skillID];
    }

    public function encodeCDPool() : Object
    {
        var ret : Object = {};

        if( m_skillCDPool == null )
                return null;
        for( var key : * in m_skillCDPool )
        {
            ret[ key ] = m_skillCDPool[key];
        }

        return ret ;
    }

    final private function get pSkillPropertyComponent() : CSkillPropertyComponent
    {
        return m_pOwner.getComponentByClass( CSkillPropertyComponent , true ) as CSkillPropertyComponent;
    }

    public function decodeCDPool( syncData : Object ) : void
    {
        m_skillCDPool.clear();

        for ( var key : * in syncData ) {
            m_skillCDPool[ key ] = syncData[ key ];
        }
    }

    private function _onDriveRemoveCD( e : CFightTriggleEvent ) : void
    {
        var skillID : int = e.parmList[0] as int ;
        if( skillID > 0 ) {
            removeSkillCD( CSkillUtil.getMainSkill( skillID ) );
        }
    }



    private var m_skillCDPool : CMap;
    private var m_pOwner : CGameObject;
}
}
