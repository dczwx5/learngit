//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/5.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.effecttrigger {

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.framework.events.CEventPriority;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.animation.IAnimation;

import kof.game.character.fight.emitter.CEmitterComponent;

import kof.game.character.fight.emitter.CEmitterComponent;
import kof.game.character.fight.emitter.CMissileStateValue;
import kof.game.character.fight.emitter.statemach.CTriStateMachine;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.property.CMissileProperty;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Emitter;

public class CMissileBaseEffect  implements IUpdatable , IDisposable{
    public function CMissileBaseEffect( owner : CGameObject ) {
        this.owner = owner;
    }

    public function dispose() : void
    {
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator , true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onCharacterStateValueChanged);
        }
    }

    public function update( delta : Number ) : void{

    }

    public function initEffect( missile : CGameObject ) : void {

        owner = owner;
        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty , true ) as CMissileProperty;
        m_pMissileInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator , true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onCharacterStateValueChanged, false, CEventPriority.DEFAULT, true );
        }
    }

    protected function playEffectAnimation() : Boolean
    {
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;

        if( !pAnimation.isStateActive( CMissileStateValue.EFFECT_1 ) ) {
            pAnimation.pushState( CMissileStateValue.EFFECT_1 );
            pAnimation.playAnimation( m_pMissileInfo.EffectSFXName.toUpperCase(), true );
            return true;
        }

        return false;
    }

    final protected function get triStateMachine() : CTriStateMachine
    {
        return owner.getComponentByClass( CTriStateMachine , true ) as CTriStateMachine;
    }

    protected function _onCharacterStateValueChanged( e : Event ) : void
    {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        if ( pStateBoard && pStateBoard.isDirty( CCharacterStateBoard.DEAD ) && true == pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) {
            setFade();
        }
    }

    protected function setFade() : void
    {
        m_boFade = true;
    }

    protected function get boFade() : Boolean
    {
        const pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.DEAD );
        }
        return true;
    }

    final protected function get aeroInfo() : Aero
    {
        return m_pMissileInfo;
    }

    protected var owner : CGameObject;
    protected var m_pMissileInfo : Aero;
    protected var m_boFade : Boolean;

}
}
