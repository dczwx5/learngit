//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/13.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.behaviour {

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.emitter.CEmitterComponent;

import kof.game.character.movement.CMovement;
import kof.game.core.CGameObject;

/**
 * to handle the behavior of the missile  straight, fellow , laser ...
 */
public class CMissileBasicBehaviour implements IDisposable{
    public function CMissileBasicBehaviour( owner : CGameObject ) {
        m_pOwner = owner;
    }

    public function dispose() : void{

    }

    public function initiaBehaviour(... arg) : void
    {

    }

    public function updateBehaviour( delta : Number) : void
    {

    }

    public function get type() : int
    {
        return m_type;
    }

    public function get owner() : CGameObject
    {
        return m_pOwner;
    }

    public function get pAnimation() : IAnimation{
        return owner.getComponentByClass( IAnimation , true ) as IAnimation;
    }

    public function get pEmitterComp() : CEmitterComponent
    {
        return owner.getComponentByClass( CEmitterComponent , true ) as CEmitterComponent;
    }
    protected var m_type : int;
    protected var m_pOwner : CGameObject;
}
}
