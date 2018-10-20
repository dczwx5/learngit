//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/5.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import QFLib.Foundation.free;

import kof.game.character.fight.targetfilter.criterialine.CAssemblyCriteriaLines;
import kof.game.character.fight.targetfilter.groupcriterias.CGroupAssemblyLine;

import kof.game.core.CGameObject;
import kof.table.Criteria;

public class CCriteriaLine {

    public function CCriteriaLine(criteriaData : Criteria ) {
        m_pData = criteriaData;
    }

    public function dispose() : void
    {

        free( m_pCriteria );
        m_pCriteria = null;

        free( m_pGroupCriteria );
        m_pGroupCriteria = null;

        m_pTargetList = null;
        m_pCriteria = null;
    }

    private function _initCriteria() : void
    {
        m_pCriteria = new CAssemblyCriteriaLines();
        m_pCriteria.buildLines( m_pData.EffectTribe , m_pData.TypeFilter ,
                                m_pData.ActionFliter,m_pData.SpecifyFilter,m_pData.StateFilter);

        m_pGroupCriteria = CGroupAssemblyLine.GetGroupCriteria( m_pData.TargetFilter );
    }

    public function getResult( targetList : Array)  :Array
    {
        this.m_pTargetList = targetList;
        return _executeCriteria(targetList);
    }

    private function _executeCriteria(targetList : Array) : Array
    {
        var resultList : Array = [];

        for each ( var target : CGameObject in targetList )
        {
            if(m_pCriteria.meetCriteria( target ))
                    resultList.push( target );
        }

        resultList = m_pGroupCriteria.meetCriteria( resultList );
        return resultList;
    }

    public function setOwner( owner : CGameObject ) : void
    {
        m_pOwner = owner;
        _initCriteria();
        m_pCriteria.setOwner( m_pOwner );
        m_pGroupCriteria.setOwner( m_pOwner );
    }

    private var m_pCriteria : CAssemblyCriteriaLines;
    private var m_pGroupCriteria : IGroupCriteria;
    private var m_pTargetList : Array;
    private var m_pData : Criteria;
    private var m_pOwner : CGameObject;
}
}
