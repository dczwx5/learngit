//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/5.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.table.TeachingGoal;

public class CTeachingSeniorStorageSkill extends CTeachingStorageSkill {
    public function CTeachingSeniorStorageSkill( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override protected function _onHitTarget( e : CFightTriggleEvent ) : void {
        var paramsList : Array = e.parmList;
        var _skillID : int = paramsList[0];
        var _isNotHit:Boolean = paramsList[2];
        if(m_pSkillID == _skillID && !_isNotHit){
            onCompleted();
            trace("击中目标"+m_pSkillID);
        }
    }
}
}
