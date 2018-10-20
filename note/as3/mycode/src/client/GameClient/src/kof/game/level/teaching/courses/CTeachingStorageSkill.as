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
//蓄力
public class CTeachingStorageSkill extends CTeachingCourseBasics {
    public function CTeachingStorageSkill( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
        }
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        m_pSkillID = int(teachingData.SkillID);

        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
        }
    }

    protected function _onHitTarget( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var _skillID : int = paramsList[0];
        var _isNotHit:Boolean = paramsList[2];
        var rootSkill : int = CSkillUtil.getMainSkill( _skillID );
        if(m_pSkillID == rootSkill && !_isNotHit){
            onCompleted();
            trace("击中目标"+m_pSkillID);
        }
    }

    protected var m_pSkillID:int;
}
}
