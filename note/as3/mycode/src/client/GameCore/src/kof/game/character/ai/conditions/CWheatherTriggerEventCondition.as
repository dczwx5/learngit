//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/9/13.
 * Time: 17:29
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.core.CGameObject;

public class CWheatherTriggerEventCondition extends CBaseNodeCondition {

    public function CWheatherTriggerEventCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
        super();
        setName(nodeName);
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if(pAIComponent.bWheatherTriggerEvent)
        {
            CAILog.logMsg("触发了事件的行为，不执行非时间行为，返回false，退出"+getName(),pAIComponent.objId);
            return false;
        }
        else
        {
            CAILog.logMsg("没有触发事件行为，可以执行非事件行为，返回true，退出"+getName(),pAIComponent.objId);
            return true;
        }
    }
}
}
