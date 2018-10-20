//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/2/9.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import flash.utils.Dictionary;

import kof.game.character.fight.skillcalc.hurt.CProfessionRelationUtil;

import kof.game.character.property.CCharacterProperty;

import kof.game.core.CGameComponent;


public class CProfessionRelation extends CGameComponent{
    public function CProfessionRelation() {
        super("Profession Relation");
    }

    override public function dispose() : void{
        super.dispose();
        if( m_theRelationUtil )
                m_theRelationUtil.dispose();
        m_theRelationUtil = null;
    }

    override protected function onEnter() : void {
        m_pCharacterProperty = owner.getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
        m_theRelationUtil = new CProfessionRelationUtil();
    }

    override protected function onExit() : void{
        m_pCharacterProperty = null;
    }

    public function getAdvantageEnhance( targetProfession : int ) : int{
        var ret : int;
//       if( m_theRelationUtil ){
//          var bAdvantage : Boolean = m_theRelationUtil.getAdvantageRelation( profession , targetProfession );
//           if( bAdvantage )
                   ret = getAdvantageAttribute( targetProfession );
//       }

       return ret ;
    }

    public function getReduceAdvantageEnhance( targetProfession : int ) : int{
       var ret : int;
//        if( m_theRelationUtil ){
//            var bAdvantage : Boolean = m_theRelationUtil.getAdvantageRelation( targetProfession, profession );
//           if( bAdvantage )
                   ret = getReduceAdvantageAttributeByType( targetProfession );
//        }

        return ret;
    }

    public function bAdvantageToProfession( firstProfession : int, targetProfession : int ) : Boolean{
        var bAdvantage : Boolean = m_theRelationUtil.getAdvantageRelation( firstProfession , targetProfession );
        return bAdvantage;
    }

    private function getAdvantageAttribute( tProfession : int ) : int {
        if( m_pCharacterProperty ) {
            switch ( tProfession ){
                case CProfessionRelationUtil.PROFESSION_ATK:
                    return m_pCharacterProperty.AtkJobHurtAddChance;
                case CProfessionRelationUtil.PROFESSION_DEF:
                    return m_pCharacterProperty.DefJobHurtAddChance;
                case CProfessionRelationUtil.PROFESSION_TECH:
                    return m_pCharacterProperty.TechJobHurtAddChance;
                default:
                    return 0;
            }
        }
        return 0;
    }

    private function getReduceAdvantageAttributeByType( profession : int ) : int{
        if( m_pCharacterProperty ) {
            switch ( profession ){
                case CProfessionRelationUtil.PROFESSION_ATK:
                    return m_pCharacterProperty.AtkJobHurtReduceChance;
                case CProfessionRelationUtil.PROFESSION_DEF:
                    return m_pCharacterProperty.DefJobHurtReduceChance;
                case CProfessionRelationUtil.PROFESSION_TECH:
                    return m_pCharacterProperty.TechJobHurtReduceChance;
                default:
                    return 0;
            }
        }
        return 0;
    }

    final public function get profession() : int{
        if( m_pCharacterProperty ){
            return m_pCharacterProperty.profession;
        }

        return -1;
    }

    private var m_pCharacterProperty : CCharacterProperty;
    private var m_theRelationUtil : CProfessionRelationUtil;
}
}
