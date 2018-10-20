//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/9/21.
 * Time: 10:45
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CDoTriggerAction extends CBaseNodeAction {
    private var m_pBT:CAIObject=null;

    private var targetEventState:String = CLOSE;
    private var targetEventId:int = 0;

    public static const OPEN:String="Open";
    public static const CLOSE:String="Close";

    public function CDoTriggerAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null,nodeIndex:int=-1 ) {
        super( parentNode, pBt, nodeName );
        this.m_pBT = pBt;
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
        try
        {
            if(m_pBT.cacheParamsDic[name+".targetEventState"])
            {
                targetEventState = m_pBT.cacheParamsDic[name+".targetEventState"];
            }
            if(m_pBT.cacheParamsDic[name+".targetEventId"])
            {
                targetEventId = m_pBT.cacheParamsDic[name+".targetEventId"];
            }
        }
        catch (e:Error)
        {
            throw e.message;
        }
    }

    override public final function _doExecute(inputData:Object):int {
        var dataIO : IAIHandler = inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        pAIComponent.dicIdToEventNodeState[targetEventId] = targetEventState;
        CAILog.logMsg("改变id为"+targetEventId+"的触发器状态为"+targetEventState,pAIComponent.objId);
        CAILog.logMsg("执行完毕，返回成功，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.SUCCESS;
    }

    }
}
