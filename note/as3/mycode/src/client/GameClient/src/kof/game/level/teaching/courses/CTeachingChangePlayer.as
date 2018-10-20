//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/2.
 */
package kof.game.level.teaching.courses {

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneSystem;
import kof.table.TeachingGoal;

public class CTeachingChangePlayer extends CTeachingCourseBasics {
    public function CTeachingChangePlayer( pTeachingData : TeachingGoal, _system:CAppSystem) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN , _onBegin);
        }
        (system.stage.getSystem( CSceneSystem ) as CSceneSystem).removeEventListener( CSceneEvent.HERO_READY, _playerGetReady );
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        targetsIDArr = teachingData.SkillID.split(";");
        _playerGetReady(null);
        (system.stage.getSystem( CSceneSystem ) as CSceneSystem).addEventListener( CSceneEvent.HERO_READY, _playerGetReady );
    }

    private function _playerGetReady( e : CSceneEvent ) : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN , _onBegin);
        }
    }

    private function _onBegin( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
        for( var k:int in targetsIDArr){
            if(targetsIDArr[k] == skillID){
                trace("释放技能!!!!");
                if(!pStartArr[k]){
                    pStartArr[k] = true;
                    onCompleted();
                }
                return;
            }
        }

    }

    private var pStartArr:Array = [false,false,false];

    private var targetsIDArr : Array;
}
}
