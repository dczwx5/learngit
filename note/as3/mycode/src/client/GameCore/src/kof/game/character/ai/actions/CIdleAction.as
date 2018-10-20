//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/9.
 * Time: 15:14
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.paramsTypeEnum.EFightStateType;
    import kof.game.core.CGameObject;

public class CIdleAction extends CBaseNodeAction {

    private var idleState:String ="无敌";
    private var idleDuration:Number = 2;

    private var m_pBT:CAIObject=null;
    private var m_elapsedTime:Number = 0;

    public function CIdleAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null,nodeIndex:int=-1) {
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
            if(m_pBT.cacheParamsDic[name+".idleState"])
            {
                idleState = m_pBT.cacheParamsDic[name+".idleState"];
            }
            if(m_pBT.cacheParamsDic[name+".idleDuration"])
            {
                idleDuration = m_pBT.cacheParamsDic[name+".idleDuration"];
            }
    }

    override public final function _doEnter( input : Object ) : void {
//                m_waitingTime = m_time;
    }

    override public final function _doExecute( inputData : Object ) : int {
        var handler:IAIHandler=inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        m_elapsedTime += inputData.deltaTime;
        if(executable)
        {
            m_elapsedTime=0;
            CAILog.logMsg("执行时间间隔为"+idleDuration+"当前经过的时间为"+m_elapsedTime
                    +"所以返回false，退出"+getName(),pAIComponent.objId);
            return CNodeRunningStatusEnum.SUCCESS;
        }
        if(idleState == "无敌")
        {
            CAILog.logMsg("设置角色状态为不可攻击",pAIComponent.objId);
            handler.setCharacterState(owner,EFightStateType.NOT_BE_ATTACK,false);
        }
        CAILog.logMsg("执行完毕，返回成功，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.EXECUTING;
    }

    private function get executable():Boolean
    {
        return m_elapsedTime - idleDuration>=0;
    }

}
}
