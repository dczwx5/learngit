//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/9.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.emitter.CEmitterComponent;
import kof.game.character.fight.emitter.statemach.CTriStateConst;
import kof.game.character.fight.emitter.statemach.CTriStateMachine;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skilleffect.CSkillChainEffect;
import kof.game.character.state.CCharacterState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.Aero;

public class CAeroTriggerMechanism extends CAutoTriggleMechanism{
    public function CAeroTriggerMechanism( skillChain : CSkillChainEffect , owner : CGameObject ) {
        super ( skillChain , owner );
    }

    override protected function doTrigger() : void{
        if( !m_pOwner || !m_pOwner.isRunning)
            return;

        if( !CCharacterDataDescriptor.isMissile( m_pOwner.data )){
            CSkillDebugLog.logErrorMsg("The Chain Trigger a Target that with not a Missile Type");
            return;
        }
        var stateBoard : CCharacterStateBoard;
        var state : int = m_skillChain.chainData.SkillID;
        var fsm : CTriStateMachine = m_pOwner.getComponentByClass( CTriStateMachine , true ) as CTriStateMachine;
        var emitterComp : CEmitterComponent = m_pOwner.getComponentByClass( CEmitterComponent , true ) as CEmitterComponent;
        stateBoard = m_pOwner.getComponentByClass( CCharacterStateBoard , true )as CCharacterStateBoard;
        if( emitterComp == null || stateBoard.getValue( CCharacterStateBoard.DEAD ))
                return;

        switch ( state ){
            case 0:
                fsm.actionFSM.on( CTriStateConst.EVT_NOISE_END , emitterComp.missileData);
                break;
            case 1:
                fsm.actionFSM.on( CTriStateConst.EVT_NOISE_BEGINE , emitterComp.missileData  );
                break;
            case 2:
                fsm.actionFSM.on( CTriStateConst.EVT_FADE , emitterComp.missileData );
                break;
            default:
                CSkillDebugLog.logErrorMsg("The Missile has not define the  state type =" + state);
        }
    }
}
}
