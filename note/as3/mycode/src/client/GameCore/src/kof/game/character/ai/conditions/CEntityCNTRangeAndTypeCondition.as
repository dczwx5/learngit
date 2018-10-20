//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/5.
 * Time: 17:45
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

public class CEntityCNTRangeAndTypeCondition extends CBaseNodeCondition {
    private var entityRangeX:int = 0;//范围半径X
    private var entityRangeY:int = 0;//范围半径Y
    private var entityRangeZ:int = 0;//范围半径Z
    private var entityType:String = EntityType.FRIENDLY;//实体类型
    private var entityOperatorType:String = OperatorType.TYPE_1;//比较关系
    private var entityNumber:int = 0;//数量

    private var m_pBT:CAIObject=null;
    public function CEntityCNTRangeAndTypeCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
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
        if(m_pBT.cacheParamsDic[name+".entityRangeX"])
        {
            entityRangeX = m_pBT.cacheParamsDic[name+".entityRangeX"];
        }
       if(m_pBT.cacheParamsDic[name+".entityRangeY"])
        {
            entityRangeY = m_pBT.cacheParamsDic[name+".entityRangeY"];
        }
       if(m_pBT.cacheParamsDic[name+".entityRangeZ"])
        {
            entityRangeZ = m_pBT.cacheParamsDic[name+".entityRangeZ"];
        }
        if(m_pBT.cacheParamsDic[name+".entityType"])
        {
            entityType = m_pBT.cacheParamsDic[name+".entityType"];
        }
        if(m_pBT.cacheParamsDic[name+".entityOperatorType"])
        {
            entityOperatorType = m_pBT.cacheParamsDic[name+".entityOperatorType"];
        }
        if(m_pBT.cacheParamsDic[name+".entityNumber"])
        {
            entityNumber = m_pBT.cacheParamsDic[name+".entityNumber"];
        }
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        return true;
    }
}
}

class EntityType
{
    /**友方*/
    public static const FRIENDLY:String = "Friendly";
    /**敌方*/
    public static const ENEMY:String = "Enemy";
    /**飞行道具*/
    public static const FLYING_PROPS:String = "FlyingProps";
    /**中立单位*/
    public static const NEUTRAL_UNITS:String = "NeutralUnits";
}

class OperatorType
{
    public static const TYPE_1:String = "大于";
    public static const TYPE_2:String = "小于";
    public static const TYPE_3:String = "等于";
    public static const TYPE_4:String = "大于等于";
    public static const TYPE_5:String = "小于等于";
}


