//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/20.
 * Time: 11:53
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.actions.CDoTriggerAction;
import kof.game.core.CGameObject;

public class CEventTrueCondition extends CBaseNodeCondition {
    private var m_pBT:CAIObject=null;

    /**自身id标识*/
    private var eventTrueId:int = 0;
    /**优先级*/
    public var eventTruePriority:int=0;

    public function CEventTrueCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
        super();
        this.m_pBT = pBt as CAIObject;
        if(nodeIndex>-1)
        {
            setTemplateIndex(nodeIndex);
            setName(nodeIndex+"_"+nodeName);
        }
        else
        {
            setName(nodeName);
        }
        _initNodeData();
    }

    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
       if(m_pBT.cacheParamsDic[name+".eventTrueId"])
        {
            eventTrueId = m_pBT.cacheParamsDic[name+".eventTrueId"];
        }
       if(m_pBT.cacheParamsDic[name+".eventTruePriority"])
        {
            eventTruePriority = m_pBT.cacheParamsDic[name+".eventTruePriority"];
        }
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if(pAIComponent.bWheatherTriggerEvent)
        {
            if(pAIComponent.iCrrentEventPriority>eventTruePriority)
            {
                CAILog.logMsg("当前正在执行事件的优先级为"+pAIComponent.iCrrentEventPriority+"大于本次执行优先级"+eventTruePriority+"，所以返回false，退出"+getName(),pAIComponent.objId);
                return false;
            }
        }
        if(pAIComponent.currentEventNodeName == getName())
        {
            CAILog.logMsg("正在执行，返回true，退出"+getName(),pAIComponent.objId);
            return true;
        }
        if(pAIComponent.dicIdToEventNodeState[eventTrueId])
        {
            if(pAIComponent.dicIdToEventNodeState[eventTrueId]==CDoTriggerAction.CLOSE)
            {
                CAILog.logMsg("本次事件处于关闭状态，事件id为"+eventTrueId+"，返回false，退出"+getName(),pAIComponent.objId);
                return false;
            }
        }
        CAILog.logMsg("可以执行本次事件，返回true，退出"+getName(),pAIComponent.objId);
        pAIComponent.currentEventNodeName = getName();
        pAIComponent.iCrrentEventPriority = eventTruePriority;
        pAIComponent.bWheatherTriggerEvent = true;
        return true;
    }

}
}
