//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/9/9.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc {

import QFLib.Interface.IUpdatable;

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;

/**
 * to handle other fighting param for UI
 */
public class CFightOthersCalc implements IUpdatable{
    public function CFightOthersCalc( owenr : CGameObject ) {
        m_owner = owenr;
    }

    public function dispose() : void {

    }

    public function update( delta : Number ) : void
    {
        if( isNaN(m_fNextClearTime))
                return;

        m_fNextClearTime -= delta ;

        if(m_fNextClearTime <= 0.0 )
        {
            resetCHit();
            m_fNextClearTime= NaN;
//            m_fNextClearTime = 2.0;
        }
    }

    final public function get ContinusHit() : int
    {
        return m_continueHit;
    }

    final public function increaseCHitWithCount( count : int ) : void
    {
        m_continueHit = m_continueHit + count ;
        m_fNextClearTime = 2.0;
        dispatchContinusCount();
    }

    final public function resetCHit() : void
    {
        if(m_boForceCancel)
            return;
        m_continueHit = 0;
        dispatchContinusCount();
    }

    private function dispatchContinusCount() : void
    {
        var ft : CCharacterFightTriggle = m_owner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
        var count : int = ContinusHit - 1 > 0 ? ContinusHit : 0 ;

        if( ft )
            ft.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT, null ,[count]));
    }

    public function set boForceCancel(boForce : Boolean) : void
    {
        m_boForceCancel = boForce;
    }

    public function set boResetNext( bo : Boolean ) : void
    {
        m_boReset = bo;
    }

    public function get boResetNext( ) : Boolean
    {
        return m_boReset;
    }

    private var m_boForceCancel : Boolean;
    private var m_continueHit : int;
    private var m_owner : CGameObject;
    private var m_fNextClearTime : Number = 2.0;
    private var m_boReset : Boolean;
}
}
