//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {


import QFLib.Interface.IDisposable;

import flash.events.EventDispatcher;

import kof.game.core.CGameObject;

public class CFightingTriggle extends EventDispatcher implements IDisposable{

    public function CFightingTriggle() {
        super();
    }

    public function dispose() : void
    {
        m_owner = null;
        if(m_parmsList != null)
                m_parmsList.splice(0,m_parmsList.length);
        m_parmsList = null;
    }

    final public function get owner() : CGameObject
    {
        return m_owner;
    }

    final public function get parmsList() : Array
    {
        return m_parmsList;
    }

    private var m_owner : CGameObject;
    private var m_parmsList : Array;
}
}
