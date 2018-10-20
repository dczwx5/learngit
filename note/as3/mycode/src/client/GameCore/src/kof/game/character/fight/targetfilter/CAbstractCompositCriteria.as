//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import kof.game.core.CGameObject;

public class CAbstractCompositCriteria implements ICriteria{

    public function CAbstractCompositCriteria() {
        m_vCriterias = new Vector.<ICriteria>();
    }

    virtual public function meetCriteria( target : CGameObject ) : Boolean
    {
        return false;
    }

    public function addCriterias( criteria : ICriteria) : void
    {
        m_vCriterias.push( criteria );
    }

    public function setOwner( owner : CGameObject ) : void
    {
        m_pOwner = owner;
    }

    protected var m_vCriterias : Vector.<ICriteria>;
    protected var m_pOwner : CGameObject;
}
}
