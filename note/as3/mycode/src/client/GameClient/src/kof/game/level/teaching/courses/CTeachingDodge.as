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

//受身
public class CTeachingDodge extends CTeachingCourseBasics {
    public function CTeachingDodge( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_DODGE , _onBegin);
        }
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.REQUEST_SYNC_DODGE , _onBegin);
        }
    }

    private function _onBegin( e : CFightTriggleEvent ) : void{
        onCompleted();
    }
}
}
