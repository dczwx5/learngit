//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 14:46
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.ai.paramsTypeEnum.EBaseOnRole;
import kof.game.character.ai.paramsTypeEnum.EPropertyFilterCondtions;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

public class CSelectTargetAction extends CBaseNodeAction {
    private var selectCriteriaID:int;
    private var m_pBT:CAIObject=null;
    private var selectTargetType: int;
    private var selectTargetParam : Number;
    private var m_pAiComponent : CAIComponent;

    public static const TYPE_TIMEER : int = 2;
    public static const TYPE_BE_HURTED: int = 1;

    public function CSelectTargetAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null ,nodeIndex:int=-1) {
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
        try
        {
            /*if(m_pBT.cacheParamsDic[name+".baseOnRole"])
            {
                baseOnRole = m_pBT.cacheParamsDic[name+".baseOnRole"];
            }
            if(m_pBT.cacheParamsDic[name+".filterCondition"])
            {
                filterCondition = m_pBT.cacheParamsDic[name+".filterCondition"];
            }
            if(m_pBT.cacheParamsDic[name+".campType"])
            {
                campType = m_pBT.cacheParamsDic[name+".campType"];
            }
            if(m_pBT.cacheParamsDic[name+".roleType"])
            {
                roleType = m_pBT.cacheParamsDic[name+".roleType"];
            }
            if(m_pBT.cacheParamsDic[name+".campID"])
            {
                campID = m_pBT.cacheParamsDic[name+".campID"];
            }
            */
            if(m_pBT.cacheParamsDic[name+".selectTargetType"])
            {
                selectTargetType = m_pBT.cacheParamsDic[name+".selectTargetType"];
            }
            if(m_pBT.cacheParamsDic[name+".selectTargetParam"])
            {
                 selectTargetParam = m_pBT.cacheParamsDic[name+".selectTargetParam"];
            }
            if(m_pBT.cacheParamsDic[name+".selectCriteriaID"])
            {
                selectCriteriaID = m_pBT.cacheParamsDic[name+".selectCriteriaID"];
            }
        }
        catch (e:Error)
        {
            throw e.message;
        }
    }
    //characterPro 攻防技筛选规则
    override public final function _doExecute( inputData : Object ) : int
    {
        var handler:IAIHandler=inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        m_pAiComponent = pAIComponent;
        m_pAiComponent.selectTargetType = selectTargetType;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId, CAILog.enabledFailLog );
        if( !_targetIsValid( pAIComponent.currentAttackable )) {
            pAIComponent.currentAttackable = handler.findAttackableByCriteriaID(owner , selectCriteriaID );//handler.findAttackable( owner, campType, roleType, filterCondition, baseOnRole, campID, serialID );
        }
        CAILog.logMsg("查找可以攻击的目标，找到目标为"+pAIComponent.currentAttackable,pAIComponent.objId , CAILog.enabledFailLog );
        CAILog.logMsg("执行完毕，返回成功，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
        return CNodeRunningStatusEnum.SUCCESS;
    }

    private function _targetIsValid( target : CGameObject ) : Boolean {
        if( selectTargetType == TYPE_TIMEER &&
                (m_pAiComponent.selectTargetCountTime <= 0.0 || isNaN(m_pAiComponent.selectTargetCountTime))) {
              m_pAiComponent.selectTargetCountTime = selectTargetParam;
              return false;
        }

        if( target == null || !target.isRunning )
                return false;

        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        if( pStateBoard )
                return !pStateBoard.getValue( CCharacterStateBoard.DEAD );
        return false;
    }

}
}