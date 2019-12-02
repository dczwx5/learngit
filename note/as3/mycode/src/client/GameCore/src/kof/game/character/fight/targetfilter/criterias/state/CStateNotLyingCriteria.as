//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.state {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.state.CCharacterHurtState;
import kof.game.character.state.CCharacterLyingState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;

public class CStateNotLyingCriteria extends CAbstractCriteria {
    public function CStateNotLyingCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var ret : Boolean;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard
        if( pStateBoard){
            ret = !pStateBoard.getValue( CCharacterStateBoard.LYING );
        }
        var pCharacterFSM : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
        if( pCharacterFSM ) {
             var hurtState : CCharacterHurtState = pCharacterFSM.actionFSM.currentState as  CCharacterHurtState ;
            if( hurtState != null ) { ret = ret && !hurtState.lying; }
        }

        return ret;
        //var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard
        //if( pStateBoard){
        //    return !pStateBoard.getValue( CCharacterStateBoard.LYING );
        // }
        // return false
    }
}
}