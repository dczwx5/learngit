//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 17:26
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.core.CGameObject;

public class CWhetherHitTheTargetCondition extends CBaseNodeCondition {
    private var m_pBT:CAIObject = null;
    private var attackTargetType:String = "Player";

    public function CWhetherHitTheTargetCondition(pBt:Object=null,nodeName:String=null,nodeIndex:int=-1) {
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
        if(m_pBT.cacheParamsDic[name+".attackTargetType"])
        {
            attackTargetType = m_pBT.cacheParamsDic[name+".attackTargetType"];
        }
    }
    [Inline]
    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if(pAIComponent.bSkillHit)
        {
            CAILog.logMsg("技能击中目标，返回true，退出"+getName(),pAIComponent.objId);
            pAIComponent.bSkillHit=false;
            return true;
        }
        CAILog.logMsg("没有击中目标，返回false，退出"+getName(),pAIComponent.objId);
        return false;
    }
}
}
