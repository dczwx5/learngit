//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight {

import QFLib.Foundation.CMap;
import QFLib.Foundation.free;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDatabase;

import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.targetfilter.CCriteriaLine;
import kof.game.core.CGameComponent;
import kof.table.Criteria;

public class CTargetCriteriaComponet extends CGameComponent {
    public function CTargetCriteriaComponet( db : IDatabase ) {
        super("target criteria");
        m_pDbSys  = db;
    }

    override protected function onEnter() : void
    {
        m_pCriteria = new CMap();
    }

    override protected function onExit() : void
    {
        for( var key : * in m_pCriteria )
        {
            free( m_pCriteria[ key ] );
            m_pCriteria[ key ] = null;
        }
        m_pCriteria.clear();
        m_pCriteria = null;
    }

    /**
     * 根据碰撞框标识找目标
     * @param hitEvent
     * @param criteriaID
     * @return
     */
    public function getTargetByCollision( hitEvent : String , criteriaID : int = 0 ) : Array
    {
        var targets : Array = collisionComp.getTargetByHitEvent( hitEvent );

        if( criteriaID == 0 || targets == null || targets.length == 0) return targets;

        var criLine : CCriteriaLine;
        if( m_pCriteria.find( criteriaID )){
            criLine = m_pCriteria[criteriaID] as CCriteriaLine;
        }else {
            var criData : Criteria ;
            criData = m_pDbSys.getTable( KOFTableConstants.HIT_CRITERIA ).findByPrimaryKey( criteriaID ) as Criteria;
            criLine = _buildCriteriaLine( criData );
            m_pCriteria.add( criteriaID , criLine );
        }

        return criLine.getResult( targets );
    }

    /**
     * 原有目标列表，过滤条件
     * @param targetsList
     * @param criteria
     * @return
     */
    public function getTargetPerCriteria( targetsList : Array , criteria : Criteria ) : Array
    {
        if( targetsList == null || targetsList.length == 0 ) return null;

        if( !criteria ) return targetsList;
        var criLine : CCriteriaLine;
        if( m_pCriteria.find(criteria.ID))
        {
            criLine = m_pCriteria[criteria.ID] as CCriteriaLine;
        }else {
            criLine = _buildCriteriaLine( criteria );
            m_pCriteria.add( criteria.ID, criLine );
        }
        return criLine.getResult( targetsList );
    }

    public function getTargetPerCriteriaID( targets : Array , criteriaID : int) : Array{
        var criData : Criteria = m_pDbSys.getTable( KOFTableConstants.HIT_CRITERIA ).findByPrimaryKey( criteriaID ) as Criteria;
        return getTargetPerCriteria( targets , criData );
    }

    private function _buildCriteriaLine( criteriaData : Criteria ) : CCriteriaLine
    {
        var criLine : CCriteriaLine= new CCriteriaLine( criteriaData );
        criLine.setOwner( owner );
        return criLine;
    }

    private final function get collisionComp( ) : CCollisionComponent
    {
        return this.getComponent( CCollisionComponent , true ) as CCollisionComponent;
    }

    private var m_pCriteria : CMap;
    private var m_pDbSys : IDatabase;

}
}
