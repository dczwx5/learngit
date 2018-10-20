//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/24.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Foundation;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CSkillList;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skill.property.ISkillItemProperty;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.table.Damage;

public class CFightDamageComponent extends CGameComponent {
    public function CFightDamageComponent( name : String = null ) {
        super( name );
    }

    override public function dispose() : void {
        if ( m_fightHurtFacade )
            m_fightHurtFacade.dispose();
        m_fightHurtFacade = null;

        if ( m_fightPropertyFacade )
            m_fightPropertyFacade.dispose();
        m_fightPropertyFacade = null;
    }

    override protected function onEnter() : void {

    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();

        if ( CCharacterDataDescriptor.isMissile( owner.data ) ||
                CCharacterDataDescriptor.isBuff( owner.data ) ) {
            var masterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            setOwnerFacade( masterComp.master );
        } else
            setOwnerFacade( owner );
    }

    protected function setOwnerFacade( realOwner : CGameObject ) : void {
        if ( m_OwnerFacade === realOwner )
            return;

        var targetOwner : CGameObject = realOwner as CGameObject;
        if ( targetOwner ) {
            m_OwnerFacade = targetOwner;
            m_fightHurtFacade = new CFightHurtFacade( m_OwnerFacade );
            m_fightPropertyFacade = new CFightPropertyFacade( m_OwnerFacade );
        } else {
            Foundation.Log.logErrorMsg( "the fightDamageCompnent has not Owner to Cal the damage" );
        }
    }

    public function executeHurt( target : CGameObject, damageInfo : Damage, skillID : int ) : int {
        var skillUpInfo : ISkillItemProperty;
        var mainSkillID : int = CSkillUtil.getMainSkill( skillID );
        var skillPropertyComp : CSkillPropertyComponent = m_OwnerFacade.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
        if ( skillPropertyComp ) {
            skillUpInfo = skillPropertyComp.getSkillPropertyByID( mainSkillID );
        } else {
            skillUpInfo = null;
        }

        var revision : Number;
        if ( bNeedSkillRevision ) {
            revision = getSkillDamageRevision( mainSkillID );
        }

        var retDamage : int = m_fightHurtFacade.executeHurt( target, damageInfo, skillUpInfo , revision );

        return retDamage;
    }

    public function get bNeedSkillRevision() : Boolean {
        var isMonster : Boolean = CCharacterDataDescriptor.isMonster( owner.data );
        var isMonsterMaster : Boolean;
        var pMasterComponent : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( pMasterComponent ) {
            var pMaster : CGameObject = pMasterComponent.master;
            if ( pMaster )
                isMonsterMaster = CCharacterDataDescriptor.isMonster( pMaster.data );
        }
        return isMonster || isMonsterMaster;
    }

    public function executeGuardHurt( target : CGameObject, damageInfo : Damage, skillID : int ) : int {
        var skillUpInfo : ISkillItemProperty;
        var mainSkillID : int = CSkillUtil.getMainSkill( skillID );
        var skillPropertyComp : CSkillPropertyComponent = m_OwnerFacade.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
        if ( skillPropertyComp ) {
            skillUpInfo = skillPropertyComp.getSkillPropertyByID( mainSkillID );
        } else {
            skillUpInfo = null;
        }

        var revision : Number;
        if ( bNeedSkillRevision ) {
            revision = getSkillDamageRevision( mainSkillID );
        }

        var retDamage : int = m_fightHurtFacade.executeGuardHurt( target, damageInfo, skillUpInfo , revision );

        return retDamage
    }

    public function getSkillDamageRevision( skillID : int ) : Number {
        var damageRevision : Number = 1.0;
        var skillIndex : int;
        var pSkillList : CSkillList = owner.getComponentByClass( CSkillList, true ) as CSkillList;
        var pMasterComponent : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;

        if ( pSkillList == null || pMasterComponent != null ) {
            var isMonsterMaster : Boolean;
            if ( pMasterComponent ) {
                var pMaster : CGameObject = pMasterComponent.master;
                if ( pMaster )
                    isMonsterMaster = CCharacterDataDescriptor.isMonster( pMaster.data );

                if ( isMonsterMaster )
                    pSkillList = pMaster.getComponentByClass( CSkillList, true ) as CSkillList;
            }
        }

        if ( pSkillList ) {
            skillIndex = pSkillList.findIndexBySkill( skillID );
            if ( skillIndex > -1 )
                damageRevision = pSkillList.getSkillDamageRevisionByIndex( skillIndex );
        }

        return damageRevision;
    }

    public function get fightPropertyFacade() : CFightPropertyFacade {
        return m_fightPropertyFacade;
    }

    private var m_OwnerFacade : CGameObject;
    private var m_fightHurtFacade : CFightHurtFacade;
    private var m_fightPropertyFacade : CFightPropertyFacade;

}
}
