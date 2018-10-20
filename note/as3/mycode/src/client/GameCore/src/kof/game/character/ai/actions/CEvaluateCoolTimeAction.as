//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/10.
//----------------------------------------------------------------------
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CEvaluateCoolTimeAction extends CBaseNodeAction {
    private var m_pBT : CAIObject;
    private var m_fCoolTime : Number;
    private var m_iNodeIndex : Number;

    public function CEvaluateCoolTimeAction( parentNode : CBaseNode, data : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
        super( parentNode, data, nodeName );
        this.m_pBT = data;
        m_iNodeIndex = nodeIndex;
        if ( nodeIndex > -1 ) {
            setTemplateIndex( nodeIndex );
            setName( nodeIndex + "_" + nodeName );
        }
        else {
            setName( nodeName );
        }
        _initNodeData();
    }

    private function _initNodeData() : void {
        var name : String = getName();
        if ( name == null )return;
        if ( m_pBT.cacheParamsDic[ name + ".evaluateCoolTime" ] ) {
            m_fCoolTime = m_pBT.cacheParamsDic[ name + ".evaluateCoolTime" ];
        }
    }

    override public function _doExecute( inputData : Object ) : int {
        if ( isNaN( m_fCoolTime ) || m_fCoolTime == 0.0 )
            return CNodeRunningStatusEnum.SUCCESS;

        var dataIO : IAIHandler = inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;

        if( !pAIComponent.actionNodeCoolTimeCMap.find( m_iNodeIndex ))
                pAIComponent.actionNodeCoolTimeCMap.add( m_iNodeIndex , m_fCoolTime , true);


        return CNodeRunningStatusEnum.SUCCESS;

//        var fCoolTime : Number;
//        fCoolTime = pAIComponent.getNodeCoolTime( m_iNodeIndex );
//        if( isNaN(fCoolTime) || fCoolTime <= 0.0 ) {
//            pAIComponent.removeNodeCoolTime( m_iNodeIndex );
//            return CNodeRunningStatusEnum.SUCCESS;
//        }

//        CAILog.logExistUnSatisfyInfo( getName() , "行为还在冷却时间" ,pAIComponent.objId );
//        return CNodeRunningStatusEnum.FAIL;
    }
}
}
