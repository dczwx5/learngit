//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skill.property {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;

import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.core.CGameComponent;
import kof.table.Skill;

public class CSkillPropertyComponent extends CGameComponent {
    public function CSkillPropertyComponent( pDatabase : IDatabase ) {
        super( "skillDataHolder" );
        m_pDataBase = pDatabase;
        m_skillDataList = new CMap( false );
    }

    override public function dispose() : void {
        super.dispose();
        if ( m_skillDataList )
            m_skillDataList.clear();
        m_skillDataList = null;
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        if ( owner.data.hasOwnProperty( "skillProperty" ) ) {
            var skillList : Object = owner.data.skillProperty as Object;
            var skillProperty : CSkillItemProperty;
            if ( skillList ) {
                var skillTable : IDataTable = m_pDataBase.getTable( KOFTableConstants.SKILL );
                for ( var skillID : String in skillList ) {
                    var id : int = int( skillID );
                    var skillItem : Object = skillList[ skillID ];

                    skillProperty = m_skillDataList.find( id ) as CSkillItemProperty;
                    if ( !skillProperty ) {
                        skillProperty = new CSkillItemProperty( id, skillTable );
                        skillProperty.fromObject( skillItem );
                        m_skillDataList.add( id, skillProperty );
                    } else {
                        skillProperty.fromObject( skillItem );
                    }

                }
            } else {
                CSkillDebugLog.logTraceMsg( " skillProperty list has no data" );
            }

            delete owner.data.skillProperty;
        }
    }

    public function getSkillPropertyByID( skillID : int ) : ISkillItemProperty {
        return m_skillDataList.find( skillID );
    }

    public function getSkillCD( skillID : int ) : Number {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        if ( !skillPro ) {
            var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
            if ( tSkill )
                return tSkill.CD;
            return 0.0;
        } else {
            return skillPro.CD;
        }
    }

    public function getSkillConsumeAp( skillID : int ) : int {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( !skillPro ) {
            if ( tSkill )
                return tSkill.ConsumeAP;
            return 0.0;
        } else {
            return skillPro.ConsumeAP;
        }
    }

    public function getSkillConsumeApRadio( skillID : int ) : int{
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( tSkill )
            return tSkill.ReturnAP;
        return 0;
    }

    public function getRestoreApWhenSkillHitNobody( skillID : int ) : int {
        return Math.floor( getSkillConsumeAp( skillID ) * (getSkillConsumeApRadio( skillID )/100.0) );
    }

    public function getSkillConsumePGP( skillID : int ) : int {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( !skillPro ) {
            if ( tSkill )
                return tSkill.ConsumePGP;
            return 0.0;
        } else {
            return skillPro.ConsumePGP;
        }
    }

    public function getSkillRagePowerRecoverty( skillID : int ) : int {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( !skillPro ) {
            if ( tSkill )
                return tSkill.RageRestoreWhenSpellSkill;
            return 0.0;
        } else {
            return skillPro.RageRestoreWhenSpellSkill;
        }
    }

    public function getSkillHitRagePowerRecoverty( skillID : int ) : int {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( !skillPro ) {
            if ( tSkill )
                return tSkill.RageRestoreWhenHitTarget;
            return 0.0;
        } else {
            return skillPro.RageRestoreWhenHitTarget;
        }
    }

    public function getSkillConsumeGP( skillID : int ) : int {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        var tSkill : Skill = skillTable.findByPrimaryKey( skillID );
        if ( !skillPro ) {
            if ( tSkill )
                return tSkill.ConsumeGP;
            return 0.0;
        } else {
            return skillPro.ConsumeGP;
        }
    }

    public function getBuffList( skillID : int ) : Array {
        var skillPro : CSkillItemProperty = m_skillDataList.find( skillID );
        if ( !skillPro ) return null;

        return skillPro.BuffList;
    }

    final private function get skillTable() : IDataTable {
        return m_pDataBase.getTable( KOFTableConstants.SKILL );
    }

    private var m_skillDataList : CMap;
    private var m_pDataBase : IDatabase;
}
}
