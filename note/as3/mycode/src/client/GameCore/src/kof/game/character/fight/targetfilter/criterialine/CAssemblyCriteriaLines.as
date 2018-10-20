//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {


import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.IDecodeFilterValue;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityNotBuffCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateValidCriteria;
import kof.game.character.fight.targetfilter.filterenum.ETargetFilterType;
import kof.game.character.fight.targetfilter.criterias.logiccomposite.CAndCompositeCriteria;
import kof.game.core.CGameObject;

public class CAssemblyCriteriaLines extends CAbstractCriteria {
    public function CAssemblyCriteriaLines() {
        super();
        m_andCompositeCriteria = new CAndCompositeCriteria();
    }

    override public function dispose() : void
    {
        super.dispose();
        m_andCompositeCriteria.dispose();
    }

    override public function meetCriteria(target : CGameObject) : Boolean
    {
        return m_andCompositeCriteria.meetCriteria( target );
    }

    public function buildLines( campMask : int , entityMask : int , actionMask : int , specifyMask : int ,fightStateMask : int = 0 ) : void
    {
        assemblyCampLine( campMask );
        assemblyEntityLine( entityMask );
        assemblySpecifyLine( specifyMask );
        assemblyStateLine( actionMask );
        assemblyFightStateLine( fightStateMask );

        /**buff不作为目标以及死亡不能作为目标*/
        var notBuffCri : CEntityNotBuffCriteria = new CEntityNotBuffCriteria();
        var validStateCriteria : CStateValidCriteria = new CStateValidCriteria();

        _addLineToCritieria( notBuffCri );
        _addLineToCritieria( validStateCriteria );
    }

    public function assemblyCampLine( mask : int ) : void
    {
        _buildFilterLine( ETargetFilterType.FILTER_BY_CAMP , mask);
    }

    public function assemblyEntityLine( mask : int ) : void
    {
        _buildFilterLine( ETargetFilterType.FILTER_BY_ENTITY , mask );
    }

    public function assemblyStateLine( mask : int ) : void
    {
        _buildFilterLine( ETargetFilterType.FILTER_BY_STATE , mask );
    }

    public function assemblyFightStateLine( mask : int ) : void
    {
        _buildFilterLine( ETargetFilterType.FILTER_BY_FIGHT_STATE , mask );
    }

    public function assemblySpecifyLine( mask : int ) : void
    {
        _buildFilterLine( ETargetFilterType.FILTER_BY_SPECIFY , mask );
    }

    public function get andComposeComposeCriterias() : CAndCompositeCriteria
    {
        return m_andCompositeCriteria;
    }

    public function _addLineToCritieria( line : ICriteria ) : void
    {
        m_andCompositeCriteria.addCriterias( line );
    }

    private function _buildFilterLine( type : int , mask : int ) : CBasicFilterLine
    {
        var line : CBasicFilterLine;
        switch(type){
            case  ETargetFilterType.FILTER_BY_CAMP:
                line = new CCampCriteriaLine();
                break;
            case ETargetFilterType.FILTER_BY_ENTITY:
                line = new CEntityCriteriaLine();
                break;
            case ETargetFilterType.FILTER_BY_STATE:
                line = new CStateCriteriaLine();
                break;
            case ETargetFilterType.FILTER_BY_SPECIFY:
                line = new CSpecifyCriteriaLine();
                break;
            case ETargetFilterType.FILTER_BY_FIGHT_STATE:
                line = new CFightStateCriteriaLine();
                break;
            default:
                CSkillDebugLog.logMsg( "has no specify filter type ");
                break;
        }

        var pDecodable : IDecodeFilterValue = line as IDecodeFilterValue;
        if( pDecodable )
                pDecodable.setCriteriaMask( mask );

        _addLineToCritieria( line );
        return line;
    }

    override public function setOwner( owner : CGameObject ) : void
    {
        super.setOwner( owner );
        m_andCompositeCriteria.setOwner( owner );
    }

    private var m_andCompositeCriteria : CAndCompositeCriteria;
}
}
