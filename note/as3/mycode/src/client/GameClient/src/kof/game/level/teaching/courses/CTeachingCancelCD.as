//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/5/10.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.table.TeachingGoal;

public class CTeachingCancelCD extends CTeachingCourseBasics {
    public function CTeachingCancelCD( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL , _onDriveCancel);
        }
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL , _onDriveCancel);
        }
    }

    private function _onDriveCancel(evt:CFightTriggleEvent):void{
        onCompleted();
    }
}
}
