//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/28.
//----------------------------------------------------------------------
package kof.game.character.fight.buff.buffentity {

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.character.fight.buff.IBuffEffectContainer;

import kof.game.character.fight.buff.buffentity.IBuff;
import kof.table.Buff;

public class CAbstractBuff implements IBuff, IUpdatable ,IDisposable {
    public function CAbstractBuff( id : int , buffId : int ) {
        this.m_nId = id;
        this.m_nBuffId = buffId;
    }

    public function update( delta : Number ) : void
    {
    }

    public function dispose() : void{

    }

    public function get id() : int
    {
        return m_nId;
    }

    public function get buffId() : int
    {
        return m_nBuffId;
    }

    public function get isValid() : Boolean
    {
        return m_boValid;
    }

    public function get buffEffectList() : Array
    {
        return null;
    }

    public function get buffAttModifierList() : Array
    {
        return null;
    }

    public function get buffData() : Buff
    {
        return m_pBuff;
    }

    public function get parent() : IBuffEffectContainer
    {
        return m_theContainer;
    }

    public function addEffectCount() : void
    {
        m_nEffectCount++;
    }

    public function addOverLapCount() : void
    {
        m_nOverlapCount++;
    }

    public function get nEffectCount() : int
    {
        return m_nEffectCount;
    }

    public function get nOverlapCount() : int
    {
        return m_nOverlapCount
    }

    public function get randomSeed() : int
    {
        return m_randomSeed;
    }

    public function set randomSeed( seed : int) : void
    {
        m_randomSeed = seed;
    }

    public function setParent( container : IBuffEffectContainer ) : void
    {
        this.m_theContainer = container;
    }

    protected var m_nId : int;
    protected var m_nBuffId : int;
    protected var m_pBuff : Buff;
    protected var m_theContainer : IBuffEffectContainer;
    protected var m_boValid : Boolean;
    protected var m_nEffectCount : int;
    protected var m_nOverlapCount : int;
    protected var m_randomSeed : int;
}
}
