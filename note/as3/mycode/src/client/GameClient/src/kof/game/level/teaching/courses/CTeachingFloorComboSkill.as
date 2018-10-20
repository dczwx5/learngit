//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/5.
 */
package kof.game.level.teaching.courses {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CTarget;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingFloorComboSkill extends CTeachingCourseBasics {
    public function CTeachingFloorComboSkill( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( TargetHero ){
            (TargetHero.getComponentByClass(CCharacterStateMachine,false) as CCharacterStateMachine).actionFSM.removeEventListener(CStateEvent.ENTER, onEnter);
        }
        (hero.getComponentByClass( CEventMediator,false ) as CEventMediator).removeEventListener( CCharacterEvent.TARGET_CHANGED, onTargetChanged );
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        m_pSkillIDArray = teachingData.SkillID.split(";");

        (hero.getComponentByClass( CEventMediator,false ) as CEventMediator).addEventListener( CCharacterEvent.TARGET_CHANGED, onTargetChanged );
    }

    private function onTargetChanged(e:Event):void{
        if( TargetHero != null ){
            (TargetHero.getComponentByClass(CCharacterStateMachine,false) as CCharacterStateMachine).actionFSM.addEventListener(CStateEvent.ENTER, onEnter);
        }
    }

    private function onEnter(e:CStateEvent):void{
        if( m_pIsHitFloorSkill && e.to == CCharacterActionStateConstants.IDLE ){
            m_pIsHitFloorSkill = false;
        }

        if(m_pIsHitFloorSkill && ( e.to == CCharacterActionStateConstants.HURT || e.to == CCharacterActionStateConstants.KNOCK_UP || e.to == CCharacterActionStateConstants.BE_CATCH) ){
            onCompleted();
            m_pIsHitFloorSkill = false;
        }

        if( e.from == CCharacterActionStateConstants.LYING && e.to == CCharacterActionStateConstants.KNOCK_UP ){
            if((hero.getComponentByClass(CSkillCaster,false) as CSkillCaster).skillID == m_pSkillIDArray[0]){
                trace("击中目标"+m_pSkillIDArray[0]);
                m_pIsHitFloorSkill = true;
            }
        }
    }

    private function get TargetHero():CGameObject{
        return (hero.getComponentByClass(CTarget,false) as CTarget).targetObject;
    }
    private var m_pSkillIDArray:Array;

    private var m_pIsHitFloorSkill:Boolean;
}
}
