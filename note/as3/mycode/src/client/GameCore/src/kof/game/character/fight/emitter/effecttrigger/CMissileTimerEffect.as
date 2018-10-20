//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/5.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.effecttrigger {

import kof.game.character.fight.emitter.CEmitterComponent;
import kof.game.character.fight.emitter.statemach.CTriFadeState;
import kof.game.character.fight.emitter.statemach.CTriStateConst;
import kof.game.core.CGameObject;

public class CMissileTimerEffect extends CMissileBaseEffect {
    public function CMissileTimerEffect( owner : CGameObject ) {
        super(owner);
    }

    override public function update( delta : Number ) : void
    {
        if( boFade ) return;
        m_fTriggerLeftTime += delta;
        if( m_fTriggerLeftTime >= aeroInfo.TriggerEffectTime || isNaN(m_fTriggerLeftTime)){
            m_fTriggerLeftTime = 0.0;
            _triggerEffect( delta );
        }
    }

    private function _triggerEffect( delta : Number) : void
    {
        if( m_boFade )
            return;
        triStateMachine.actionFSM.on( CTriStateConst.EVT_NOISE_BEGINE , aeroInfo );
    }

    override protected function setFade() : void
    {
        super.setFade();

    }

    private var m_fTriggerLeftTime : Number = NaN ;
}
}
