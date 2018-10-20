//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/8/24.
 * Time: 12:06
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import flash.geom.Point;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CJudgeDistanceTargetCondition extends CBaseNodeCondition {

    private var m_pBT:CAIObject = null;
    private var m_distance:Number =0 ;
    private var m_operatorType:String = "大于";

    public function CJudgeDistanceTargetCondition( pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
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
       if(m_pBT.cacheParamsDic[name+".judgeDistance"])
        {
            m_distance = m_pBT.cacheParamsDic[name+".judgeDistance"];
        }
        if(m_pBT.cacheParamsDic[name+".operatorType"])
        {
            m_operatorType = m_pBT.cacheParamsDic[name+".operatorType"];
        }
    }
    [Inline]
    override protected final function externalCondition(inputData:Object):Boolean
    {
        var dataIO:IAIHandler=inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        var attackble:CGameObject = pAIComponent.currentAttackable;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if (null == attackble)
        {
            CAILog.logMsg("攻击目标为null，返回false，退出"+getName(),pAIComponent.objId);
            return false;
        }
        var dis:Number = Math.abs(Point.distance(new Point(attackble.transform.x,attackble.transform.y),new Point(owner.transform.x,owner.transform.y)));
        switch (m_operatorType)
        {
            case OperatorType.TYPE_1:
                if(dis>m_distance)
                {
                    CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回true，退出"+getName(),pAIComponent.objId);
                    return true;
                }
                break;
            case OperatorType.TYPE_2:
                if(dis<m_distance)
                {
                    CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回true，退出"+getName(),pAIComponent.objId);
                    return true;
                }
                break;
            case OperatorType.TYPE_3:
                if(dis==m_distance)
                {
                    CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回true，退出"+getName(),pAIComponent.objId);
                    return true;
                }
                break;
            case OperatorType.TYPE_4:
                if(dis>=m_distance)
                {
                    CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回true，退出"+getName(),pAIComponent.objId);
                    return true;
                }
                break;
            case OperatorType.TYPE_5:
                if(dis<=m_distance)
                {
                    CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回true，退出"+getName(),pAIComponent.objId);
                    return true;
                }
                break;
        }
        CAILog.logMsg("运算类型："+m_operatorType+"，本次距离:"+dis+"，目标距离："+m_distance+"，返回false，退出"+getName(),pAIComponent.objId);
        return false;
    }
}
}

class OperatorType
{
    /**大于*/
    public static const TYPE_1:String = "大于";
    /**小于*/
    public static const TYPE_2:String = "小于";
    /**等于*/
    public static const TYPE_3:String = "等于";
    /**大于等于*/
    public static const TYPE_4:String = "大于等于";
    /**小于等于*/
    public static const TYPE_5:String = "小于等于";
}
