//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skill.property {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;
import kof.game.character.fight.skill.CSkillDebugLog;

import kof.table.Skill;
import kof.util.CAssertUtils;

public class CSkillItemProperty implements ISkillItemProperty,IDisposable {
    public function CSkillItemProperty( id : int, skillTable : IDataTable ) {
        m_data = {};
        m_pskillDataTable = skillTable;
        this.SkillID = id;
    }

    public function dispose() : void {
        m_data = null;
        m_skillData = null;
    }

    public function fromObject( obj : Object ) : void {
        CAssertUtils.assertNotNull( m_skillData, "Can not find skillData ID=" + SkillID);
        if( m_skillData == null ) {
            Foundation.Log.logTraceMsg("技能数据不存在：skillid=" + SkillID );
            return;
        }

        this.BaseDamage = obj.hasOwnProperty( "BaseDamage" ) ? obj.BaseDamage : 0;
        this.BaseHealing = obj.hasOwnProperty( "BaseHealing" ) ? obj.BaseHealing : 0;
        this.BuffList = obj.hasOwnProperty( "BuffList" ) ? obj.BuffList : null;
        this.CD = obj.hasOwnProperty( "CD" ) ? obj.CD / 1000 : m_skillData.CD;
        this.DamagePer = obj.hasOwnProperty( "DamagePer" ) ? obj.DamagePer : 0;
        this.HealingPer = obj.hasOwnProperty( "HealingPer" ) ? obj.HealingPer : 0;
        this.ExCounterAttack = obj.hasOwnProperty( "ExCounterAttack" ) ? obj.ExCounterAttack : 0;
        this.RageRestoreWhenSpellSkill =
                obj.hasOwnProperty( "RageRestoreWhenSpellSkill" ) ? obj.RageRestoreWhenSpellSkill : m_skillData.RageRestoreWhenSpellSkill;
        this.RageRestoreWhenHitTarget =
                obj.hasOwnProperty( "RageRestoreWhenHitTarget" ) ? obj.RageRestoreWhenHitTarget : m_skillData.RageRestoreWhenHitTarget;

        this.ConsumeAP = obj.hasOwnProperty( "ConsumeAP" ) ? m_skillData.ConsumeAP + obj.ConsumeAP : m_skillData.ConsumeAP;
        this.ConsumeGP = obj.hasOwnProperty( "ConsumeGP" ) ? m_skillData.ConsumeGP + obj.ConsumeGP : m_skillData.ConsumeGP;
        this.ConsumePGP = obj.hasOwnProperty( "ConsumePGP" ) ? m_skillData.ConsumePGP + obj.ConsumePGP : m_skillData.ConsumePGP;
    }

    public function get SkillID() : int {
        return m_data.SkillID;
    }

    public function get BaseDamage() : int {
        return m_data.BaseDamage;
    }

    public function get BaseHealing() : int {
        return m_data.BaseHealing;
    }

    public function get DamagePer() : int {
        return m_data.DamagePer;
    }

    public function get HealingPer() : int {
        return m_data.HealingPer;
    }

    public function get CD() : Number {
        return m_data.CD;
    }

    public function get ConsumeAP() : int {
        return m_data.ConsumeAP;
    }

    public function get ConsumePGP() : int {
        return m_data.ConsumePGP;
    }

    public function get ConsumeGP() : int {
        return m_data.ConsumeGP;
    }

    public function get ExCounterAttack() : int {
        return m_data.ExCounterAttack;
    }

    public function get RageRestoreWhenSpellSkill() : int {
        return m_data.RageRestoreWhenSpellSkill;
    }

    public function get RageRestoreWhenHitTarget() : int {
        return m_data.RageRestoreWhenHitTarget;
    }

    public function get BuffList() : Array {
        return m_data.BuffList;
    }

    public function set SkillID( value : int ) : void {
        if ( SkillID == value )
            return;
        m_data.SkillID = value;

        if ( m_pskillDataTable ) {
            m_skillData = m_pskillDataTable.findByPrimaryKey( SkillID );
            if ( m_skillData == null ) {
                CSkillDebugLog.logErrorMsg( "skill table has not item that ID = " + value );
            }
        }
    }

    public function set BaseDamage( value : int ) : void {
        if ( BaseDamage == value )
            return;
        m_data.BaseDamage = value;
    }

    public function set BaseHealing( value : int ) : void {
        if ( BaseHealing == value )
            return;
        m_data.BaseHealing = value;
    }

    public function set DamagePer( value : int ) : void {
        if ( DamagePer == value )
            return;
        m_data.DamagePer = value;
    }

    public function set HealingPer( value : int ) : void {
        if ( HealingPer == value )
            return;
        m_data.HealingPer = value;
    }

    public function set CD( value : Number ) : void {
        if ( CD == value )
            return;
        m_data.CD = value;
    }

    public function set ConsumeAP( value : int ) : void {
        if ( ConsumeAP == value )
            return;
        m_data.ConsumeAP = value;
    }

    public function set ConsumePGP( value : int ) : void {
        if ( ConsumePGP == value )
            return;
        m_data.ConsumePGP = value;
    }

    public function set ConsumeGP( value : int ) : void {
        if ( ConsumeGP == value )
            return;
        m_data.ConsumeGP = value;
    }

    public function set ExCounterAttack( value : int ) : void {
        if ( ExCounterAttack == value )
            return;
        m_data.ExCounterAttack = value;
    }

    public function set RageRestoreWhenSpellSkill( value : int ) : void {
        if ( RageRestoreWhenSpellSkill == value )
            return;
        m_data.RageRestoreWhenSpellSkill = value;
    }

    public function set RageRestoreWhenHitTarget( value : int ) : void {
        if ( RageRestoreWhenHitTarget == value )
            return;
        m_data.RageRestoreWhenHitTarget = value;
    }

    public function set BuffList( value : Array ) : void {
        m_data.BuffList = value;
    }

    private var m_data : Object;
    private var m_skillData : Skill;
    private var m_pskillDataTable : IDataTable;
}
}
