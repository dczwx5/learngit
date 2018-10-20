//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/12.
 * Time: 16:33
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

public class CStopAction extends CBaseNodeAction {

    /**停止多久，0是一直停止*/
    private var timeLength:Number = 0;

    private var m_pBT:CAIObject=null;

    public function CStopAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null,nodeIndex:int=-1 ) {
        super( parentNode , pBt);
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
        if(m_pBT.cacheParamsDic[name+".timeLength"])
        {
            timeLength = m_pBT.cacheParamsDic[name+".timeLength"];
        }
    }

    override public final function _doExecute(inputData:Object):int
    {
        var handler : IAIHandler = inputData.handler;
        if(handler==null)return CNodeRunningStatusEnum.FAIL;
        var owner : CGameObject = inputData.owner;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        CAILog.logMsg("正在停止，返回正在执行，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.EXECUTING;
    }
}
}
