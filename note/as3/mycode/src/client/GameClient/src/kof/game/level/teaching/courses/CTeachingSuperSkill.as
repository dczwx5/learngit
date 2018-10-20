//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/2.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingSuperSkill extends CTeachingCourseBasics {

    private var targetsIDArr : Array;

    public function CTeachingSuperSkill( pTeachingData : TeachingGoal, _system:CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        targetsIDArr = teachingData.SkillID.split(";");

        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
        }
    }

    private function _onHitTarget( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        var rootSkill : int = CSkillUtil.getMainSkill( skillID );
        for( var k:int in targetsIDArr){
            if(targetsIDArr[k] == rootSkill){
                trace("击中目标!!!!");
                onCompleted();
                return;
            }
        }
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
        }
        super.dispose();
    }
}
}
