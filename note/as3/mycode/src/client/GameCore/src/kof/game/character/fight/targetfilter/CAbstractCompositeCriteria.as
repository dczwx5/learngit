//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import QFLib.Interface.IDisposable;

import kof.game.core.CGameObject;

public class CAbstractCompositeCriteria implements ICriteria , IDisposable{

    public function CAbstractCompositeCriteria() {
        m_vCriterias = new Vector.<ICriteria>();
    }

    public function dispose() : void
    {
        m_vCriterias.splice( 0 , m_vCriterias.length ) ;
        m_vCriterias = null;
        m_pOwner = null;
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
        for each( var criterias : ICriteria in m_vCriterias )
        {
            var abCri : CAbstractCriteria = criterias as CAbstractCriteria;
            abCri.setOwner( m_pOwner );
        }
    }

    public function get boHasCriterias() : Boolean
    {
        return m_vCriterias.length > 0;
    }
    protected var m_vCriterias : Vector.<ICriteria>;
    protected var m_pOwner : CGameObject;
}
}
