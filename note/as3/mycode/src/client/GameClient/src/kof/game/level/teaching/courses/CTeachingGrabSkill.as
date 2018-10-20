//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/5.
 */
package kof.game.level.teaching.courses {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CTarget;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;
import kof.table.TeachingGoal;

public class CTeachingGrabSkill extends CTeachingCourseBasics {
    public function CTeachingGrabSkill( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( m_targetHero ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED , _onInterrupted);
            m_targetHero = null;
        }

        var pSceneFacade : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        pSceneFacade.removeEventListener( CSceneEvent.BOSS_APPEAR, _onBossAppear );
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        m_pSkillID = int(teachingData.SkillID);
        var pSceneFacade : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        pSceneFacade.addEventListener( CSceneEvent.BOSS_APPEAR, _onBossAppear );
    }

    private function _onBossAppear(evt : CSceneEvent ):void{
        if( evt.value != null ){
            m_targetHero = evt.value;
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED , _onInterrupted);
        }
    }

    private function _onInterrupted( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        var rootSkill : int = CSkillUtil.getMainSkill( skillID );
        if(m_pSkillID == rootSkill){
            onCompleted();
            trace("技能被打断"+skillID);
        }
    }

    override public function get pFightTriggerEvent() : CCharacterFightTriggle {
        if(m_targetHero){
            return m_targetHero.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
        }
        return null;
    }

    private var m_targetHero:CGameObject;
    private var m_pSkillID:int;
}
}
