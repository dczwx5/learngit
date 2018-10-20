//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/4.
 * Time: 18:00
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;

import kof.game.character.ai.CAIEvent;
import kof.game.character.ai.CAILog;
import kof.game.core.CGameObject;

public class CExecuteAIAction extends CBaseNodeAction {

    private var m_pBT:CAIObject=null;
    private var targetAIId:String = "";
    private var designAIId:String = ""
    private var m_aiIdArr:Array = [];
    private var m_designId:Array = [];

    public function CExecuteAIAction( parentNode : CBaseNode, pBt:CAIObject=null, nodeName:String=null,nodeIndex:int =-1 ) {
        super( parentNode, pBt, nodeName );
        if(nodeIndex>-1)
        {
            setTemplateIndex(nodeIndex);
            setName(nodeIndex+"_"+nodeName);
        }
        else
        {
            setName(nodeName);
        }
        this.m_pBT = pBt;
        _initNodeData();
    }
    [Inline]
    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
        if(m_pBT.cacheParamsDic[name+".targetAIId"])
        {
            targetAIId = m_pBT.cacheParamsDic[name+".targetAIId"];
        }
        if(m_pBT.cacheParamsDic[name+".designAIId"])
        {
            designAIId = m_pBT.cacheParamsDic[name+".designAIId"];
        }
        if(targetAIId!=null&&targetAIId!="")
        {
            m_aiIdArr = targetAIId.split("-");
        }
        if(designAIId!=null&&designAIId!="")
        {
            m_designId = designAIId.split("-");
        }
    }
    [Inline]
    override public final function _doExecute(inputData:Object):int
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        var len:int = pAIComponent.iCurrentAIIdToIndexArr.length;
        var targetDesignId:int = 0;
        var designIndex:int = 0;
        for(var i:int=0;i<len;i++)
        {
            targetDesignId = pAIComponent.iCurrentAIIdToIndexArr[i];
            designIndex = m_designId.indexOf(targetDesignId.toString());
            if(designIndex!=-1)
            {
                pAIComponent.bIsTrrigerChangeAIEvent = true;
                break;
            }
            else
            {
                pAIComponent.bIsTrrigerChangeAIEvent = false;
            }
        }

        if(!pAIComponent.bIsFirstInMasterAI&&designIndex!=-1&&pAIComponent.bIsTrrigerChangeAIEvent)
        {
            CAILog.logMsg("发送切换AI的事件，切换ID为"+targetid,pAIComponent.objId);
            var targetid:int = m_aiIdArr[designIndex];
            pAIComponent.bIsTrrigerChangeAIEvent = false;
            pAIComponent.eventDispatcher.dispatchEvent(new CAIEvent(CAIEvent.CHANGE_AI_ID,{id:targetid}));
        }
        else if(pAIComponent.bIsFirstInMasterAI)
        {
            CAILog.logMsg("发送执行默认AI的事件，执行ID为"+m_aiIdArr[0],pAIComponent.objId);
            pAIComponent.bIsFirstInMasterAI = false;
            pAIComponent.eventDispatcher.dispatchEvent(new CAIEvent(CAIEvent.CHANGE_AI_ID,{id:m_aiIdArr[0]}));
        }
        CAILog.logMsg("执行成功，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.SUCCESS;
    }
}
}
