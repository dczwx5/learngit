//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.state {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.state.CCharacterDeadState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.message.Map.CharacterDeadRequest;

public class CStateValidCriteria extends CAbstractCriteria {
    public function CStateValidCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean {
        if ( target == null || !target.isRunning )
            return false;

        //判定是否死亡状态，子弹没有所谓的状态，是子弹就行
        var boDead : Boolean;

        var pStateMachine : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
        if( pStateMachine && pStateMachine.actionFSM )
               if( pStateMachine.actionFSM.currentState is CCharacterDeadState )
                       boDead = true;

//        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard
//        boDead =  pStateBoard.getValue( CCharacterStateBoard.DEAD);

        return !boDead || CCharacterDataDescriptor.isMissile( target.data );
    }
}
}
