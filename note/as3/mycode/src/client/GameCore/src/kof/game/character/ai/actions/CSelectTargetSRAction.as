//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/12.
 * Time: 17:13
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

/**按范围筛选*/
public class CSelectTargetSRAction extends CBaseNodeAction {

    /**范围半径X*/
    private var rangeX:int = 0;
    /**范围半径Y*/
    private var rangeY:int = 0;
    /**范围半径Z*/
    private var rangeZ:int = 0;
    /**范围偏移X*/
    private var offsetX:int = 0;
    /**范围偏移Y*/
    private var offsetY:int = 0;
    /**范围偏移Z*/
    private var offsetZ:int = 0;
    /**筛选条件*/
    private var rangeSearchType:String = "";
    /**阵营*/
    private var rangeCampType:String = "";
    /**角色类型*/
    private var rangeRoleType:String = "";

    private var m_pBT:CAIObject=null;

    public function CSelectTargetSRAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null,nodeIndex:int=-1 ) {
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
        if(m_pBT.cacheParamsDic[name+".rangeX"])
        {
            rangeX = m_pBT.cacheParamsDic[name+".rangeX"];
        }
        if(m_pBT.cacheParamsDic[name+".rangeY"])
        {
            rangeY = m_pBT.cacheParamsDic[name+".rangeY"];
        }
        if(m_pBT.cacheParamsDic[name+".rangeZ"])
        {
            rangeZ = m_pBT.cacheParamsDic[name+".rangeZ"];
        }
        if(m_pBT.cacheParamsDic[name+".offsetX"])
        {
            offsetX = m_pBT.cacheParamsDic[name+".offsetX"];
        }
        if(m_pBT.cacheParamsDic[name+".offsetY"])
        {
            offsetY = m_pBT.cacheParamsDic[name+".offsetY"];
        }
        if(m_pBT.cacheParamsDic[name+".offsetZ"])
        {
            offsetZ = m_pBT.cacheParamsDic[name+".offsetZ"];
        }
        if(m_pBT.cacheParamsDic[name+".rangeSearchType"])
        {
            rangeSearchType = m_pBT.cacheParamsDic[name+".rangeSearchType"];
        }
        if(m_pBT.cacheParamsDic[name+".rangeCampType"])
        {
            rangeCampType = m_pBT.cacheParamsDic[name+".rangeCampType"];
        }
        if(m_pBT.cacheParamsDic[name+".rangeRoleType"])
        {
            rangeRoleType = m_pBT.cacheParamsDic[name+".rangeRoleType"];
        }
    }

    override public final function _doExecute(inputData:Object):int
    {
        var handler:IAIHandler=inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logEnterInfo(getName() , pAIComponent.objId , '');//("进入"+getName(),pAIComponent.objId);

        return CNodeRunningStatusEnum.EXECUTING;
    }

}
}

class RangeSearchType
{
    /**所有*/
    public static const ALL:String = "所有";
    /**X最近*/
    public static const X_NEAREST:String = "X最近";
    /**Z最近*/
    public static const Z_NEAREST:String = "Z最近";
    /**距离最近*/
    public static const DISTANCE_NEAREST:String = "距离最近";
    /**距离最远*/
    public static const DISTANCE_FAREST:String = "距离最远";
    /**X最远*/
    public static const X_FAREST:String = "X最远";
    /**Z最远*/
    public static const Z_FAREST:String = "Z最远";
    /**随机*/
    public static const RANDOM:String ="随机";
    /**排除施法者*/
    public static const EXCLUDE_CASTER:String ="排除施法者";
    /**仅当前目标*/
    public static const ONLY_CURRENT_TARGET:String = "仅当前目标";
    /**当前目标之外*/
    public static const EXCLUDE_CURRENT_TARGET:String = "当前目标之外";
    /**百分比生命最少*/
    public static const PERCENT_HP_LEAST:String = "百分比生命最少";
}

class CampType
{
    /**敌方*/
    public static const ENEMY:String = "Enemy";
    /**友方*/
    public static const FRIENDY:String = "Friendy";
    /**中立*/
    public static const NEUTRALUNITS:String = "NeutralUnits";
}


class RoleType
{
    /**小兵*/
    public static const SOLDIER:String = "Soldier";
    /**精英*/
    public static const ELITE:String = "Elite";
    /**boss*/
    public static const BOSS:String = "Boss";
    /**玩家*/
    public static const PLAYER:String = "Player";
}

