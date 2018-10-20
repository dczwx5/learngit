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

public class CTeachingSeniorCombo extends CTeachingCourseBasics {
    public function CTeachingSeniorCombo( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT , _onCombo);
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END , _onSkillEnd);
        }
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        comboCount = int(teachingData.SkillID);

        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT , _onCombo);
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SPELL_SKILL_END , _onSkillEnd);
        }
    }

    private function _onCombo( e : CFightTriggleEvent ) : void{
        var _comboCnt : int = int( e.parmList[ 0 ] );
        currentComboCount = _comboCnt;
    }

    private function _onSkillEnd( e : CFightTriggleEvent ) : void{
        if(currentComboCount>=comboCount){
            onCompleted();
        }
        currentComboCount = 0;
    }

    private var comboCount:int;
    private var currentComboCount:int;
}
}
