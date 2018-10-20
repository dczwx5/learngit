//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/9/7.
 * Time: 14:39
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.table.AI;
/**判断自身状态*/
public class CSelfCondCondition extends CBaseNodeCondition {

    private var m_pBT:CAIObject=null;

    private var selfActOrPro:String="";
    private var selfTrueOrFalse:String ="";
    private var selfCondName:String="";

    public function CSelfCondCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
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
        if(m_pBT.cacheParamsDic[name+".selfActOrPro"])
        {
            selfActOrPro = m_pBT.cacheParamsDic[name+".selfActOrPro"];
        }
        if(m_pBT.cacheParamsDic[name+".selfTrueOrFalse"])
        {
            selfTrueOrFalse = m_pBT.cacheParamsDic[name+".selfTrueOrFalse"];
        }
        if(m_pBT.cacheParamsDic[name+".selfCondName"])
        {
            selfCondName = m_pBT.cacheParamsDic[name+".selfCondName"];
        }
    }
    [Inline]
    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var dataIO:IAIHandler = inputData.handler as IAIHandler;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logEnterInfo(getName() , pAIComponent.objId , '');//("进入"+getName(),pAIComponent.objId);
        if(selfCondName=="defense")
        {
            var bool:Boolean=dataIO.isDefensing(owner);
            if(bool)
            {
                CAILog.logMsg("判断自身状态类型："+selfCondName+"，自身处于防御状态，返回true，退出"+getName(),pAIComponent.objId);
                return true;
            }
            else
            {
                CAILog.logMsg("判断自身状态类型："+selfCondName+"，自身不在防御状态，返回false，退出"+getName(),pAIComponent.objId);
                return false;
            }
        }
        CAILog.logMsg("判断自身状态类型："+selfCondName+"，还没实现这个，统一返回true，退出"+getName(),pAIComponent.objId);
        return true;
//        switch (selfState)
//        {
//            case NOT_DEFENSE:
//                return true;
//            case DEFENSE:
//                return false;
//            default:
//                return false;
//        }

    }
}
}

class RoleActOrPro
{
    /**动作状态*/
    public static const ACTION_STATE:String="动作状态";
    /**状态参数*/
    public static const STATE_PARAMS:String="状态参数";
}

class TrueOrFalse
{
    /**是*/
    public static const TRUE:String = "是";
    /**不是*/
    public static const FALSE:String = "不是";
}
