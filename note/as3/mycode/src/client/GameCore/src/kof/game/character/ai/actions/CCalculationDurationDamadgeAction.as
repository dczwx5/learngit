//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/25.
 * Time: 14:36
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAILog;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/25
     *
     * 计算指定时间内受击相关（伤害、击打等）
     */
    public class CCalculationDurationDamadgeAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var calculationDuration : Number = 0;//指定的持续时间
        private var calculationType : String = "";//计算类型
        private var calculationValue : Number = 0;//指定的值

        private var m_aiComponent : CAIComponent = null;

        public function CCalculationDurationDamadgeAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            this.m_pBT = pBt as CAIObject;
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( m_pBT.cacheParamsDic[ name + ".calculationDuration" ] ) {
                calculationDuration = m_pBT.cacheParamsDic[ name + ".calculationDuration" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".calculationType" ] ) {
                calculationType = m_pBT.cacheParamsDic[ name + ".calculationType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".calculationValue" ] ) {
                calculationValue = m_pBT.cacheParamsDic[ name + ".calculationValue" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            m_aiComponent = pAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if(calculationDuration==0){
                return CNodeRunningStatusEnum.SUCCESS;
            }
            if ( pAIComponent.calculationResult == 2 ) {
                CAILog.logMsg( "受击条件满足，返回成功，退出" + getName(), pAIComponent.objId );
                pAIComponent.calculationResult = 0;
                pAIComponent.calculationElapsedTime = 0;
                return CNodeRunningStatusEnum.SUCCESS;
            } else if ( pAIComponent.calculationResult == 1 ) {
                CAILog.logMsg( "受击条件不满足，返回失败，退出" + getName(), pAIComponent.objId );
                pAIComponent.calculationResult = 0;
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( calculationType == CalculationType.LIFE_PERCENT ) {
                CAILog.logMsg( "受击类型，"+calculationType+"，指定受击时间"+calculationDuration+"，指定受击数值"+calculationValue+"，返回正在执行，退出" + getName(), pAIComponent.objId );
                pAIComponent.calculationValue = calculationValue;
                pAIComponent.calculationDuration = calculationDuration;
                pAIComponent.calculationType = CalculationType.LIFE_PERCENT;
                return CNodeRunningStatusEnum.EXECUTING;
            }
            else if ( calculationType == CalculationType.BEATTACKED_TIME ) {
                CAILog.logMsg( "受击类型，"+calculationType+"，指定受击时间"+calculationDuration+"，返回正在执行，退出" + getName(), pAIComponent.objId );
                pAIComponent.calculationDuration = calculationDuration;
                pAIComponent.calculationType = CalculationType.BEATTACKED_TIME;
                return CNodeRunningStatusEnum.EXECUTING;
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}

class CalculationType {
    public static const LIFE_PERCENT : String = "LifePercent";
    public static const BEATTACKED_TIME : String = "BeAttackedTime";
}
