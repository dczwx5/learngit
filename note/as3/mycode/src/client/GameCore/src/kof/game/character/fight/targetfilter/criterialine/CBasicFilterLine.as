//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/8.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import QFLib.Interface.IDisposable;

import kof.game.character.fight.targetfilter.CAbstractCriteria;

import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.IDecodeFilterValue;
import kof.game.character.fight.targetfilter.criterias.logiccomposite.COrCompositeCriteria;
import kof.game.core.CGameObject;

public class CBasicFilterLine extends CAbstractCriteria implements ICriteria , IDecodeFilterValue, IDisposable{
    public function CBasicFilterLine( name : String ="bl") {
        m_sName = name;
        m_pOrCompositeCriteria = new COrCompositeCriteria();
    }

    override public function dispose() : void
    {
        m_pOrCompositeCriteria.dispose();
        m_pOrCompositeCriteria = null;
    }

    virtual public function setCriteriaMask( mask : int ) : void
    {
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        if( !m_pOrCompositeCriteria.boHasCriterias )
            return true;

        return m_pOrCompositeCriteria.meetCriteria( target );
    }

    protected function _addCriteria( criteria : ICriteria ) : void {
        m_pOrCompositeCriteria.addCriterias( criteria );
    }

    override public function setOwner( owner : CGameObject ) : void
    {
        super.setOwner( owner );
        m_pOrCompositeCriteria.setOwner( owner );
    }

    public function get boHasCriteria() : Boolean
    {
        return m_pOrCompositeCriteria.boHasCriterias;
    }

    protected function get orCompositeCriteria() : COrCompositeCriteria
    {
        return m_pOrCompositeCriteria;
    }

    private var m_pOrCompositeCriteria : COrCompositeCriteria;
    private var m_sName : String;

}
}
