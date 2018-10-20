//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/10.
 * Time: 15:22
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CActionNodeStatusEnum;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CEventOverAction extends CBaseNodeAction {
    public function CEventOverAction( parentNode : CBaseNode, data : CAIObject = null, nodeName : String = null,nodeIndex:int=-1 ) {
        super( parentNode, data );
        m_nodeIndex = nodeIndex;
        if(nodeIndex>-1)
        {
            setTemplateIndex(nodeIndex);
            setName(nodeIndex+"_"+nodeName);
        }
        else
        {
            setName(nodeName);
        }
    }

    override public final function _doExecute(inputData:Object):int
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var dataIO:IAIHandler = inputData.handler as IAIHandler;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        if(pAIComponent.bWheatherTriggerEvent)
        {
            CAILog.logMsg("进入"+getName(),pAIComponent.objId);
            pAIComponent.bWheatherTriggerEvent = false;
            pAIComponent.currentEventNodeName = "";
            pAIComponent.currentSelfConditionNodeName='';
            pAIComponent.iCrrentEventPriority = 0;
            pAIComponent.isOverrideAction = false;
            CAILog.logMsg("重置wheatherTriggerEvent=false（是否触发事件）,currentEventNodeName为=\"\"，currentTimeEventNodeName=\"\"，iCrrentEventPriority=0",pAIComponent.objId);
            CAILog.logMsg("执行完毕，返回成功，退出"+getName(),pAIComponent.objId);
        }

        if( pAIComponent.m_bNeedCoolDown )
            _coolTimeBegin( pAIComponent );

        return CNodeRunningStatusEnum.SUCCESS;
    }

    private function _coolTimeBegin( pAIComponent : CAIComponent ) : void{
        if( pAIComponent )
        {
            var coolTime : Number;
            coolTime = pAIComponent.actionNodeCoolTimeCMap.find( m_nodeIndex );
            if( !isNaN( coolTime ) && coolTime > 0.0 ) {
                pAIComponent.addNodeCoolTime( m_nodeIndex , coolTime );

                CAILog.logEnterSubNodeInfo( getName() + "-Next Cool Time" , "执行成功 进入 -长长长长长- 冷却CD为：" + coolTime, pAIComponent.objId );
            }else{
                pAIComponent.removeNodeCoolTime( m_nodeIndex );
            }

            pAIComponent.m_bNeedCoolDown = false;
        }
    }

    private var m_nodeIndex : int;
}
}
