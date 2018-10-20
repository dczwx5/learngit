//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/6.
 */
package kof.game.character.scripts.appear {

import flash.events.Event;

import kof.framework.events.CEventPriority;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;
import kof.game.character.collision.CCollisionComponent;

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;

public class CSkillAppearAction extends CAppearAction {

    private var m_skillID:int;
    private var m_pAppearData:Object;

    public function CSkillAppearAction( pOwner : CGameObject, pAppearData : Object ) {
        super( pOwner );
        m_skillID = pAppearData.playSkill;
        m_pAppearData = pAppearData;
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        if((owner.getComponentByClass(CSkillCaster,true) as CSkillCaster).boSkillReady){
            _onCharacterSkillReady(null);
        }
        else{
            var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.addEventListener( CCharacterEvent.SKILL_COMP_READY, _onCharacterSkillReady, false, CEventPriority.DEFAULT, true );
            }
        }
    }

    private function _onCharacterSkillReady(e:Event):void{
        (owner.getComponentByClass(CCollisionComponent,true) as CCollisionComponent).enabled = false;
        (owner.getComponentByClass(CSimulateSkillCaster,true) as CSimulateSkillCaster).castSkillIngoreAll(m_skillID);
        (owner.getComponentByClass(CCharacterFightTriggle,true) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.SPELL_SKILL_END, skillEndFun);
    }

    private function skillEndFun(event:Event):void{
        this.setResult( m_pAppearData.isPlayAction  );
        (owner.getComponentByClass(CCollisionComponent,true) as CCollisionComponent).enabled = true;
        (owner.getComponentByClass(CCharacterFightTriggle,true) as CCharacterFightTriggle).removeEventListener(CFightTriggleEvent.SPELL_SKILL_END, skillEndFun);
        (owner.getComponentByClass( CEventMediator, true ) as CEventMediator).removeEventListener(CCharacterEvent.SKILL_COMP_READY, _onCharacterSkillReady);
    }
}
}
