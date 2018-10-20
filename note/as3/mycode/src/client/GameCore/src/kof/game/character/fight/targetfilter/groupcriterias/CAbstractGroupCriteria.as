//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.groupcriterias {

import kof.game.character.fight.targetfilter.IGroupCriteria;
import kof.game.core.CGameObject;

public class CAbstractGroupCriteria implements IGroupCriteria {
    public function CAbstractGroupCriteria( name : String = '') {
        m_sName = name;
    }

    public function meetCriteria( targetList : Array ) : Array
    {
        return null;
    }

    public function setOwner(obj : CGameObject) : void
    {
        m_Owner = obj;
    }

    protected function get owner() : CGameObject
    {
        return this.m_Owner;
    }

    private var m_Owner : CGameObject ;
    private var m_sName : String;
}
}
