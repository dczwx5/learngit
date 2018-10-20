//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import QFLib.Interface.IDisposable;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.core.CGameObject;

public class CAbstractCriteria implements ICriteria , IDisposable{
    public function CAbstractCriteria() {
    }

    public function dispose() : void
    {
        m_pOwner = null;
    }

    virtual public function meetCriteria( target : CGameObject ) : Boolean
    {
        return false;
    }

    public function setOwner( owner : CGameObject ) : void
    {
        m_pOwner = owner;
    }

    protected var m_pOwner : CGameObject;
}
}
