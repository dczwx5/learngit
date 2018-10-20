//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/1.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.state {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.state.CCharacterAttackState;
import kof.game.character.state.CCharacterIdleState;
import kof.game.character.state.CCharacterRunState;
import kof.game.character.state.CCharacterState;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;

public class CStateNormalCriteria extends CAbstractCriteria {
    public function CStateNormalCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean {
        var pStateMachine : CCharacterStateMachine;
        var boNormalState : Boolean;
        pStateMachine = target.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( pStateMachine ) {
            var currentState : CCharacterState = pStateMachine.actionFSM.currentState as CCharacterState;
            boNormalState = ( currentState is CCharacterIdleState) ||
                    ( currentState is CCharacterAttackState ) ||
                            ( currentState is CCharacterRunState );
        }
        return boNormalState;
    }
}
}
