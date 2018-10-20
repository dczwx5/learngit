//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/12.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import flash.geom.Point;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.message.Fight.ExitSkillResponse;

public class CSkillEndStrategy extends CBaseStrategy {
    public function CSkillEndStrategy() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function doResponseAction() : void {
        if ( null == responseData ) return;
        _doExitSkillForResponse();
        super.doResponseAction();
    }

    private function _catchUp() : void {
        var exitSkillId : int = responseData.skillID;
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( pSkillCaster.isInSpecifySkill( exitSkillId ) ) {
            pSkillCaster.skillSpeed = 5;
        } else if ( pSkillCaster.isInSameMainSkill( exitSkillId ) ) {
            pSkillCaster.skillSpeed = 6;
        }
    }

    private function _doExitSkillForResponse() : void {
        var msg : ExitSkillResponse;
        msg = responseData;

        if ( msg == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }

        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        _setInputDiretion( owner, 0, 0 );

        var fHeight : Number = msg.dynamicStates[ CCharacterSyncBoard.NHEIGHT_PLAYER ]; //pSyncBoard.getValue( CCharacterSyncBoard.NHEIGHT_PLAYER );
        if ( pDisplay ) {
            if ( !pStateBoard.getValue( CCharacterStateBoard.IN_HURTING ) && !pStateBoard.getValue( CCharacterStateBoard.IN_CATCH ) )
                _setPosition( owner, msg.posX, msg.posY, false, fHeight );
        }

        var dir : int = msg.dynamicStates[ CCharacterSyncBoard.SKILL_DIR ];//pSyncBoard.getValue( CCharacterSyncBoard.SKILL_DIR );
        pStateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( dir, 0 ) );

        var pSkillCatch : CSkillCatcher;
        pSkillCatch = owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;
        if ( pSkillCatch ) {
            pSkillCatch.removeAll();
        }
    }

    final private function get responseData() : ExitSkillResponse {
        return action.actionData as ExitSkillResponse;
    }
}
}
