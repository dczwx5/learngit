//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/9.
 * Time: 11:45
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.core.CGameObject;

public class CWheatherTriggerChangeAIEventCondition extends CBaseNodeCondition {
    public function CWheatherTriggerChangeAIEventCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
        super();
        setName(nodeName);
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if(pAIComponent.bIsTrrigerChangeAIEvent)
        {
            CAILog.logMsg("服务器触发了切换AI的事件，返回true，退出"+getName(),pAIComponent.objId);
            return true;
        }else if(pAIComponent.bIsFirstInMasterAI)
        {
            CAILog.logMsg("首次进入changeAI树，返回true，退出"+getName(),pAIComponent.objId);
            return true;
        }
        CAILog.logMsg("没有触发切换AI的事件，返回false，退出"+getName(),pAIComponent.objId);
        return false;
    }
}
}
