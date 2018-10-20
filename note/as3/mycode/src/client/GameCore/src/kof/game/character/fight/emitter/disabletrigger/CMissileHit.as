//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/22.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.disabletrigger {
import QFLib.Interface.IUpdatable;

import kof.game.character.fight.emitter.statemach.CTriStateMachine;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;

import kof.game.core.CGameObject;

/**
 * the basic class for the  a missile that explosion
 */
public class CMissileHit implements IUpdatable{

    public function CMissileHit( owner : CGameObject ) {
        m_pOwner = owner;

    }
    public function dispose() : void
    {
        m_pOwner = null;
    }

    public function initHitBehavior(... arg) : void
    {

    }

    public function update(delta : Number): void
    {

    }

    protected function isEvaluate() : Boolean
    {
        return true;
    }

    protected function executeEffect() : void
    {

    }

    private var m_effectType : int ;

    public function get effectType() : int {
        return m_effectType;
    }

    public function set effectType( value : int ) : void {
        m_effectType = value;
    }

    public function get owner() : CGameObject{
        return m_pOwner;
    }

    final protected function get triStateMachine() : CTriStateMachine
    {
        return owner.getComponentByClass( CTriStateMachine , true ) as CTriStateMachine;
    }

    final protected function get pFightTrigger() : CCharacterFightTriggle{
        return owner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
    }
    private var m_pOwner : CGameObject;
}
}
