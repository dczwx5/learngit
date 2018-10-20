//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/5.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingAirComboSkill extends CTeachingCourseBasics {
    public function CTeachingAirComboSkill( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
        pHitArr = [false,false];
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

    protected function _onHitTarget( e : CFightTriggleEvent ) : void {
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        if(targetsIDArr[0] == skillID){
            pHitArr[0] = true;
            trace("击中目标"+skillID);
        }else if( pHitArr[0] ){
            pHitArr[1] = true;
        }
    }

    protected function _onSkillEnd( e:CFightTriggleEvent ) :void{
        if(pHitArr.indexOf(false) == -1){
            trace("连击成功!!!!");
            onCompleted();
        }else{
            trace("连击失败!!!");
        }
        pHitArr = [false,false];
    }

    protected var pHitArr:Array = [false,false];

    protected var targetsIDArr : Array;
}
}
