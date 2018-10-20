//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/23.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingCommonAttack extends CTeachingCourseBasics {
    public function CTeachingCommonAttack( pTeachingData : TeachingGoal, _system:CAppSystem ) {
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
        targetsIDArr = teachingData.SkillID.split(";");

        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.HIT_TARGET , _onHitTarget);
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SPELL_SKILL_END , _onSkillEnd);
        }
    }

    private function _onSkillEnd( e:CFightTriggleEvent ) :void{
        if(pHitArr.indexOf(false) == -1){
            trace("连击成功!!!!");
            onCompleted();
        }else{
            trace("连击失败!!!");
        }
        pHitArr = [false,false,false];
    }

    private function _onHitTarget( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        for( var k:int in targetsIDArr){
            if(targetsIDArr[k] == skillID){
                pHitArr[k] = true;
            }
        }
    }

    private var pHitArr:Array = [false,false,false];

    private var targetsIDArr : Array;
}
}
