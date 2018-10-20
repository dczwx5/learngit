//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.state {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.state.CCharacterLyingState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;

public class CStateInHurtCriteria extends CAbstractCriteria {
    public function CStateInHurtCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var boHurt : Boolean;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard
        if( pStateBoard){
            boHurt = pStateBoard.getValue( CCharacterStateBoard.IN_HURTING );
        }

        var pCharacterFSM : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
        if( pCharacterFSM )
                boHurt = boHurt || pCharacterFSM.actionFSM.currentState is CCharacterLyingState;

        return boHurt;
    }
}
}
