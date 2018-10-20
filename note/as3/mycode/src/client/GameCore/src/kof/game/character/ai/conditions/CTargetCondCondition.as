//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/9/1.
 * Time: 11:12
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.core.CGameObject;

/**目标状态的判断*/
public class CTargetCondCondition extends CBaseNodeCondition {
    private var m_pBT:CAIObject=null;

    private var targetTrueOrFalse:String="";
    private var targetActOrPro:String="";
    private var targetCondName:String="";
    private var targetCriteriaID : int;

    public function CTargetCondCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
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
        if(m_pBT.cacheParamsDic[name+".targetTrueOrFalse"])
        {
            targetTrueOrFalse = m_pBT.cacheParamsDic[name+".targetTrueOrFalse"];
        }
        if(m_pBT.cacheParamsDic[name+".targetActOrPro"])
        {
            targetActOrPro = m_pBT.cacheParamsDic[name+".targetActOrPro"];
        }
        if(m_pBT.cacheParamsDic[name+".targetCondName"])
        {
            targetCondName = m_pBT.cacheParamsDic[name+".targetCondName"];
        }
        if(m_pBT.cacheParamsDic[name+".targetCriteriaID"])
        {
            targetCriteriaID = m_pBT.cacheParamsDic[name+".targetCriteriaID"];
        }
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        var owner : CGameObject = inputData.owner as CGameObject;
        var dataIO:IAIHandler = inputData.handler as IAIHandler;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logEnterInfo(getName() , pAIComponent.objId ,"");//("进入"+getName(),pAIComponent.objId);
        if( targetCriteriaID != 0 ){
            var currentTarget : CGameObject = pAIComponent.currentAttackable;
            var rets : Array;
            if( currentTarget ){
                var pCriteriaComp : CTargetCriteriaComponet = owner.getComponentByClass( CTargetCriteriaComponet , true ) as CTargetCriteriaComponet;
                if( pCriteriaComp ) {
                    rets = pCriteriaComp.getTargetPerCriteriaID([currentTarget], targetCriteriaID );
                }
                var bInState : Boolean = rets != null && rets.length > 0;
                if( !bInState )
                    CAILog.logExistUnSatisfyInfo(getName(),"目标制定的状态可能不对 ID=" + targetCriteriaID , pAIComponent.objId );

                return bInState;
            }else {
                CAILog.logExistUnSatisfyInfo( getName(), "当前没有目标，不能攻击 过滤条件为ID=" + targetCriteriaID, pAIComponent.objId );
                return false;
            }
        }else {
            if ( targetActOrPro == RoleActOrPro.STATE_PARAMS ) {
                if ( targetTrueOrFalse == TrueOrFalse.TRUE ) {
                    if ( targetCondName == "attacking" ) {
                        var bool : Boolean = dataIO.isAttacking( pAIComponent.currentAttackable );
                        CAILog.logMsg( "判断目标是否处于攻击状态，返回" + bool + "，退出" + getName(), pAIComponent.objId );
                        return bool;
                    }
                }
            }
        }
        CAILog.logExistUnSatisfyInfo(getName(),"当前没有目标，不能攻击 ID=" + targetCriteriaID , pAIComponent.objId );
        return false;
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