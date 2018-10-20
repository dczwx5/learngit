//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/16.
//----------------------------------------------------------------------
package kof.game.character.fight.buff.buffentity {

import QFLib.Foundation.CMap;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillcalc.hurt.CProfessionRelation;
import kof.game.character.fight.skillcalc.hurt.CProfessionRelationUtil;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.ECharacterConst;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;
import kof.table.Buff.EAGMMode;

public class CBuffAttModifiedProperty extends CCharacterProperty {
    public function CBuffAttModifiedProperty() {
    }

    override protected function onEnter() : void {
        super.onEnter();
        m_buffModifiersDic = new CMap();
        m_pBuffData = {};
        m_theComingBuff = [];
        m_AttPercent = {};
    }

    override protected function onExit() : void {
        m_buffModifiersDic.clear();
        m_pBuffData = null;
        m_buffModifiersDic = null;
        m_theComingBuff.splice( 0, m_theComingBuff );
        m_theComingBuff = null;
        m_AttPercent = null;
    }

    override protected virtual function onDataUpdated() : void {
    }

    override public function update( delta : Number ) : void {
        if ( m_bDirty ) {
            m_bDirty = false;
            for each( var buff : IBuff in m_theComingBuff ) {
                addBuffProperty( buff );
            }
            m_theComingBuff.splice( 0, m_theComingBuff.length )
        }
    }

    public function pushPropertyBuff( buff : IBuff ) : void {
        m_theComingBuff.push( buff );
        m_bDirty = true;
    }

    protected function addBuffProperty( buff : IBuff ) : void {
        _addBuffModifiers( buff, false )
    }

    public function removeBuffProperty( buff : IBuff ) : void {
        _removeBuffModifiers( buff );
    }

    private function _addBuffModifiers( buff : IBuff, boRemove : Boolean = false ) : void {
        var buffSkillOwner : CGameObject = (buff as CBuff).buffSkillOwner;
        var buffSkillOwnerProperty : ICharacterProperty;
        var buffModifierList : Vector.<_modifierStruct> = new Vector.<_modifierStruct>();

        if ( buffSkillOwner )
            buffSkillOwnerProperty = buffSkillOwner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;

        for each( var attModifier : CBuffModifierInfo in buff.buffAttModifierList ) {
            var modifiedPro : _modifierStruct = _changeByAttriModifier( attModifier, buffSkillOwnerProperty, boRemove );
            buffModifierList.push( modifiedPro );
        }

        m_buffModifiersDic.add( buff.id, buffModifierList, true );
    }

    override public function get data() : Object {
        return m_pBuffData;
    }

    private function _removeBuffModifiers( buff : IBuff ) : void {
        var modifierList : Vector.<_modifierStruct> = m_buffModifiersDic[ buff.id ];
        if ( modifierList ) {
            for each( var theModifier : _modifierStruct in modifierList ) {
                if ( !theModifier.boPercent )
                    _changeProperty( theModifier.sAttributeName, -theModifier.fModifierValue );
                else
                    _changePercentProperty( theModifier.sAttributeName, -theModifier.fModifierPercent );

                theModifier = null;
            }

            modifierList.splice( 0, modifierList.length );
        }

        delete m_buffModifiersDic[ buff.id ];
    }

    private function _changeByAttriModifier( attModifier : CBuffModifierInfo, coPropery : ICharacterProperty = null,
                                             boRemove : Boolean = false ) : _modifierStruct {
        var coCalProperty : ICharacterProperty;
        var attName : String = attModifier.AttributeName;
        var changedValue : int;
        coCalProperty = attModifier.boCalByOwnerProperty ? pOwnerProperty : coPropery;
        if ( coCalProperty == null )CSkillDebugLog.logTraceMsg( "@CBuffAttmmodifiedProperty ,the buff u add has no target property to cal" );
        changedValue = ( attModifier.AttributeModifyValue );
        if ( !attModifier.boCalByPercent )
            _changeProperty( attName, boRemove ? -changedValue : changedValue );
        else
            _changePercentProperty( attName, boRemove ? -changedValue : changedValue );

        return new _modifierStruct( attName, changedValue, attModifier.boCalByPercent );
    }

    private function _changeProperty( attName : String, changeValue : Number ) : void {
        var currAttValue : Number = this[ attName ];
        currAttValue = currAttValue + changeValue;
        this[ attName ] = currAttValue;
    }

    private function _changePercentProperty( attName : String, changeValue : int ) : void {
        var percentAtt : String = attName + "_Percent";
        var currentValue : int = !m_AttPercent.hasOwnProperty( percentAtt ) ? 0 : m_AttPercent[ percentAtt ];
        m_AttPercent[ percentAtt ] = currentValue + changeValue;
    }

    public function getPercentProperty( attName : String ) : int {
        var percentAtt : String = attName + "_Percent";
        if ( !m_AttPercent.hasOwnProperty( percentAtt ) )
            return 0;
        return m_AttPercent[ percentAtt ];
    }

    private function get pOwnerProperty() : ICharacterProperty {
        return owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
    }

    private function get pProfessionRelation() : CProfessionRelation {
        return owner.getComponentByClass( CProfessionRelation, true ) as CProfessionRelation;
    }

    public function getAddJobEnhance( fromJob : int , toJob : int ) : int {
        var theProfessionRel : CProfessionRelation = pProfessionRelation;
        var ret : int;
        if ( theProfessionRel ) {
//            var bEnhance : Boolean = theProfessionRel.bAdvantageToProfession(fromJob , toJob );
//            if ( bEnhance ) {
                switch ( fromJob ) {
                    case CProfessionRelationUtil.PROFESSION_ATK:
                        ret = AtkJobHurtAddChance;
                        break;
                    case CProfessionRelationUtil.PROFESSION_DEF:
                        ret = DefJobHurtAddChance;
                        break;
                    case CProfessionRelationUtil.PROFESSION_TECH:
                        ret = TechJobHurtAddChance;
                        break;
                }
//            }
        }
        return ret;
    }

    public function getReduceJobEnhance(fromJob : int , toJob : int ) : int {
        var theProfessionRel : CProfessionRelation = pProfessionRelation;
        var ret : int;
        if ( theProfessionRel ) {
//            var bEnhance : Boolean = theProfessionRel.bAdvantageToProfession( fromJob , toJob );
//            if ( bEnhance ) {
                switch ( fromJob ) {
                    case CProfessionRelationUtil.PROFESSION_ATK:
                        ret = AtkJobHurtReduceChance;
                        break;
                    case CProfessionRelationUtil.PROFESSION_DEF:
                        ret = DefJobHurtReduceChance;
                        break;
                    case CProfessionRelationUtil.PROFESSION_TECH:
                        ret = TechJobHurtReduceChance;
                        break;
                }
//            }
        }
        return ret;
    }

    private function get iUpdateIndex() : int {
        return m_iUpdateIndex;
    }

    private function set iUpdateIndex( value : int ) : void {
        m_iUpdateIndex = value;
    }

    private var m_buffModifiersDic : CMap;
    private var m_pBuffData : Object = {};
    private var m_iUpdateIndex : int;
    private var m_bDirty : Boolean;
    private var m_theComingBuff : Array;
    private var m_AttPercent : Object;
}
}


class _modifierStruct {
    public function _modifierStruct( attName : String, modifyValue : int, boPercent : Boolean = false ) {
        this.sAttributeName = attName;
        this.boPercent = boPercent;
        if ( !boPercent )
            this.fModifierValue = modifyValue;
        else
            this.fModifierPercent = modifyValue;
    }

    public var sAttributeName : String;
    public var fModifierValue : int;
    public var fModifierPercent : int;
    public var boPercent : Boolean;
}