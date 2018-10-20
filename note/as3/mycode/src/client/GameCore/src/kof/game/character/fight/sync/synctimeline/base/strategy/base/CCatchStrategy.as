//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/20.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.message.Fight.CatchResponse;

public class CCatchStrategy extends CBaseStrategy {
    public function CCatchStrategy() {
    }

    override public function doResponseAction() : void {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( !pStateBoard.getValue( CCharacterStateBoard.IN_ATTACK ) ) {
            CSkillDebugLog.logTraceMsg("The puppet don't in attack state , can't catch somebody");
            return;
        }
        _doCatch();
    }

    protected function _doCatch() : void {
        var target : CGameObject;
        var targetList : Array = [];
        var boCatchEnd : Boolean;

        var sceneFacade : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;

        for each( var obj : Object in catchResponse.targets ) {
            target = sceneFacade.findGameObj( obj.type, obj.ID );
            if ( target != null ) {
                targetList.push( target );
            }
        }

        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        //新版边处理机制中这个不在有用
        var nCatchMoveDir : int;
        boCatchEnd = catchResponse.bCatchEnd == 1;
        if ( catchResponse.dynamicStates && catchResponse.dynamicStates.hasOwnProperty( CCharacterSyncBoard.CATCH_MOVE_DIR ) ) {
            nCatchMoveDir = catchResponse.dynamicStates[ CCharacterSyncBoard.CATCH_MOVE_DIR ];
        }
        if ( !boCatchEnd )
            pSkillCaster.castCatchToTargets( catchResponse.catchId, targetList, true, nCatchMoveDir );
        else
            pSkillCaster.castCatchEndToTarget( catchResponse.catchId, targetList );
    }

    final protected function get catchResponse() : CatchResponse {
        return action.actionData as CatchResponse;
    }

}
}
