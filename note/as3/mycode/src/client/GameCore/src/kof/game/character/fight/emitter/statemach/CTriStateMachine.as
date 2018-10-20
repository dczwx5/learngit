//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/3.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.statemach {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import kof.framework.fsm.CFiniteStateMachine;
import kof.framework.fsm.CState;
import kof.game.character.state.CBaseStateMachine;

import kof.game.core.CSubscribeBehaviour;

public class CTriStateMachine extends CBaseStateMachine implements IUpdatable{
    public function CTriStateMachine()  {
        super("triFSM");
    }

    override protected function onEnter( ) : void
    {
        if ( !m_pActionFsm ) {
            m_pActionFsm = CFiniteStateMachine.create( {
                events : [
                    {
                        name : STARTUP,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CTriStateConst.SILENCE
                    },
                    {
                        name : CTriStateConst.EVT_NOISE_BEGINE,
                        from : [CTriStateConst.SILENCE,
                                CTriStateConst.NOISY,],
                        to : CTriStateConst.NOISY
                    },
                    {
                        name : CTriStateConst.EVT_NOISE_END,
                        from : CTriStateConst.NOISY,
                        to : CTriStateConst.SILENCE
                    },
                    {
                        name : CTriStateConst.EVT_FADE,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CTriStateConst.FADE
                    }]
            } );
        }

       addState( new CTriFadeState());
       addState( new CTriSilenceState() );
       addState( new CTriNoisyState());
       actionFSM.on( STARTUP );
    }

    public function addState( state : CTriBaseState) : void
    {
       if( !state )  return;
        state.m_pOwner = owner;
        actionFSM.addState( state );
    }

    override public function get actionFSM() : CFiniteStateMachine{
        return m_pActionFsm;
    }

    override protected function onExit( ) : void
    {

    }

    override public function update( delta : Number ) : void{
    }

    private var m_pActionFsm : CFiniteStateMachine;
    private const STARTUP : String = "startup";
}
}
