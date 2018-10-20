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

//初级连招
public class CTeachingPrimaryCombo extends CTeachingCourseBasics {
    protected var pHitArr:Array = [false,false,false];

    protected var targetsIDArr : Array;

    public function CTeachingPrimaryCombo( pTeachingData : TeachingGoal, _system:CAppSystem ) {
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

    protected function _onSkillEnd( e:CFightTriggleEvent ) :void{
//        if(pHitArr.indexOf(false) == -1){
//            trace("连击成功!!!!");
//            onCompleted();
//        }else{
//            trace("连击失败!!!");
//        }
        pHitArr = [false,false,false];
    }

    protected function _onHitTarget( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        var rootSkill : int = CSkillUtil.getMainSkill( skillID );
        for( var k:int in targetsIDArr){
            if(targetsIDArr[k] == rootSkill){
                if(k != 0 && pHitArr[k - 1] == false){
                    return;
                }
                pHitArr[k] = true;
                trace("击中目标"+skillID);
                if(pHitArr.indexOf(false) == -1){
                    trace("连击成功!!!!");
                    onCompleted();
                    pHitArr = [false,false,false];
                }else{
                    trace("连击失败!!!");
                }
            }
        }
    }

}
}
