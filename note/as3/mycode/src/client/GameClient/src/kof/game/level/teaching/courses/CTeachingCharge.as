//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/5.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingCharge extends CTeachingCourseBasics {
    public function CTeachingCharge( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END , _onSkillEnd);
        }
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        m_pSkillID = int(teachingData.SkillID);

        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SPELL_SKILL_END , _onSkillEnd);
        }
    }

    private function _onHitTarget( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var _skillID : int = paramsList[0];
        var _isNotHit:Boolean = paramsList[2];
        var rootSkill : int = CSkillUtil.getMainSkill( _skillID );
        if(m_pSkillID == rootSkill && !_isNotHit){
            m_pHitTarget = true;
            trace("击中目标"+m_pSkillID);
        }
    }

    private function _onSkillEnd( e : CFightTriggleEvent ) : void{
        if(m_pHitTarget){
            onCompleted();
        }
        m_pHitTarget = false;
    }

    private var m_pHitTarget:Boolean;
    private var m_pSkillID:int;
}
}
