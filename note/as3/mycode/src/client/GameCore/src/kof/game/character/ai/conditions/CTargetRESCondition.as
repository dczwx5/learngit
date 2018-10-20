//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/22.
 * Time: 10:28
 */
package kof.game.character.ai.conditions {

    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.core.CGameObject;

    public class CTargetRESCondition extends CBaseNodeCondition {

        private var m_pBT : CAIObject = null;

        private var targetResOperatorType : String = "";
        private var targetResPropertyType : String = "";
        private var targetResValue : Number = 0;
        private var targetResRoleType : String = "";

        private var m_pAIComponent : CAIComponent = null;

        public function CTargetRESCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super();
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
            if ( m_pBT.cacheParamsDic[ name + ".targetResPropertyType" ] ) {
                targetResPropertyType = m_pBT.cacheParamsDic[ name + ".targetResPropertyType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".targetResOperatorType" ] ) {
                targetResOperatorType = m_pBT.cacheParamsDic[ name + ".targetResOperatorType" ];
            }
            if ( m_pBT.cacheParamsDic.hasOwnProperty( name + ".targetResValue" ) ) {
                targetResValue = m_pBT.cacheParamsDic[ name + ".targetResValue" ];
            }
            if ( m_pBT.cacheParamsDic.hasOwnProperty( name + ".targetResRoleType" ) ) {
                targetResRoleType = m_pBT.cacheParamsDic[ name + ".targetResRoleType" ];
            }
        }

        override protected final function externalCondition( inputData : Object ) : Boolean {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pFacadeProperty : ICharacterProperty = null;
            var pAIComponent : CAIComponent = null;
            if ( targetResRoleType == "Player" ) {
                owner = dataIO.getPlayer( owner );
                pFacadeProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                pAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
                if ( pAIComponent ) {
                    CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
                }
            }
            else {
                pAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
                if ( pAIComponent ) {
                    CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
                }

                if ( !pAIComponent.currentAttackable ) {
                    CAILog.logMsg( "攻击目标为null，返回false，退出" + getName(), pAIComponent.objId );
                    return false;
                }
                pFacadeProperty = pAIComponent.currentAttackable.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
            }
            m_pAIComponent = pAIComponent;
            if ( !pFacadeProperty ) {
                CAILog.logMsg( "属性组件为null，返回false，退出" + getName(), pAIComponent.objId );
                return false;
            }

            switch ( targetResPropertyType ) {
                case PropertyType.DEFENSE:
                    return judgementValue( pFacadeProperty.DefensePower / pFacadeProperty.MaxDefensePower );
                    break;
                case PropertyType.ATTACK:
                    return judgementValue( pFacadeProperty.AttackPower / pFacadeProperty.MaxAttackPower );
                    break;
                case PropertyType.LIFE:
                    return judgementValue( pFacadeProperty.HP / pFacadeProperty.MaxHP );
                    break;
                case PropertyType.ANGER: //目前没有怒气值
                    return judgementValue( 1 );
                    break;
            }
            return true;
        }

        private function judgementValue( propertyValue : Number ) : Boolean {
            if ( targetResValue == -1 )//-1表示不判断属性，直接通过
            {
                CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                        + propertyValue + "，目标值为:" + targetResValue + "，直接返回true，退出" + getName(), m_pAIComponent.objId );
                return true;
            }
            var operatorValue : Number = targetResValue / 100;
            switch ( targetResOperatorType ) {
                case OperatorType.DA_YU:
                    if ( propertyValue > operatorValue ) {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                        return true;
                    }
                    else {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                        return false;
                    }
                    break;
                case OperatorType.DAYU_DENGYU:
                    if ( propertyValue >= operatorValue ) {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                        return true;
                    }
                    else {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                        return false;
                    }
                    break;
                case OperatorType.DENG_YU:
                    if ( propertyValue == operatorValue ) {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                        return true;
                    }
                    else {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                        return false;
                    }
                    break;
                case OperatorType.XIAO_YU:
                    if ( propertyValue < operatorValue ) {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                        return true;
                    }
                    else {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                        return false;
                    }
                    break;
                case OperatorType.XIAOYU_DENGYU:
                    if ( propertyValue <= operatorValue ) {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                        return true;
                    }
                    else {
                        CAILog.logMsg( "判断目标属性类型:" + targetResPropertyType + "，运算类型：" + targetResOperatorType + "，当前值为:"
                                + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                        return false;
                    }
                    break;
            }
            return true;
        }
    }
}

class PropertyType {
    public static const LIFE : String = "Life";
    public static const ATTACK : String = "Attack";
    public static const DEFENSE : String = "Defense";
    public static const ANGER : String = "Anger";
}
class OperatorType {
    public static const DENG_YU : String = "等于";
    public static const DA_YU : String = "大于";
    public static const XIAO_YU : String = "小于";
    public static const DAYU_DENGYU : String = "大于等于";
    public static const XIAOYU_DENGYU : String = "小于等于";
}
