//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 16:14
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;

public class CSelfResCondition extends CBaseNodeCondition {
    private var m_pBT : CAIObject = null;
    private var m_bExecuting : Boolean;
//        private var selfResPropertyType : String = PropertyType.LIFE;
//        private var selfResOperatorType : String = OperatorType.DENG_YU;
//        private var selfResValue : Number = 0;

    private var m_pAIComponent : CAIComponent = null;

    public function CSelfResCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
        super();
        this.m_pBT = pBt as CAIObject;
        if ( nodeIndex > -1 ) {
            setTemplateIndex( nodeIndex );
            setName( nodeIndex + "_" + nodeName );
        }
        else {
            setName( nodeName );
        }
//            _initData();
        _initListData();
    }

    private var m_selfTypeList : Array;
    private var m_selfOperatorList : Array;
    private var m_selfValueList : Array;

    private function _initListData() : void {
        var name : String = getName();
        if ( name == null )return;

        if ( m_pBT.cacheParamsDic[ name + ".selfResPropertyType" ] ) {
            m_selfTypeList = String( m_pBT.cacheParamsDic[ name + ".selfResPropertyType" ] ).split( "-" );
        }
        if ( m_pBT.cacheParamsDic[ name + ".selfResOperatorType" ] ) {
            m_selfOperatorList = String( m_pBT.cacheParamsDic[ name + ".selfResOperatorType" ] ).split( "-" );
        }
        if ( m_pBT.cacheParamsDic[ name + ".selfResValue" ] ) {
            m_selfValueList = String( m_pBT.cacheParamsDic[ name + ".selfResValue" ] ).split( "-" );
        }
    }

//        private function _initData() : void {
//            var name : String = getName();
//            if ( name == null )return;
//
//            if ( m_pBT.cacheParamsDic[ name + ".selfResPropertyType" ] ) {
//                selfResPropertyType = m_pBT.cacheParamsDic[ name + ".selfResPropertyType" ];
//            }
//            if ( m_pBT.cacheParamsDic[ name + ".selfResOperatorType" ] ) {
//                selfResOperatorType = m_pBT.cacheParamsDic[ name + ".selfResOperatorType" ];
//            }
//            if ( m_pBT.cacheParamsDic[ name + ".selfResValue" ] ) {
//                selfResValue = m_pBT.cacheParamsDic[ name + ".selfResValue" ];
//            }
//        }

    [Inline]
    override protected final function externalCondition( inputData : Object ) : Boolean {
        var owner : CGameObject = inputData.owner as CGameObject;
        var dataIO : IAIHandler = inputData.handler as IAIHandler;
        var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        m_pAIComponent = pAIComponent;
        CAILog.logMsg( "进入" + getName(), pAIComponent.objId, CAILog.enabledFailLog );

        var bRet : Boolean;
        if ( !m_selfOperatorList || !m_selfTypeList || !m_selfValueList ) {
            CAILog.logMsg( "自身条件参数为空 不能通过", m_pAIComponent.objId );
            return false;
        }
        if ( m_selfTypeList.length != m_selfOperatorList.length || m_selfTypeList.length != m_selfValueList.length ) {
            CAILog.logMsg( "自身条件参数长度不匹配 不能通过", m_pAIComponent.objId );
            return false;
        }

        if ( pAIComponent.bWheatherTriggerEvent && pAIComponent.currentSelfConditionNodeName == getName() &&
            m_pAIComponent.isMulEnterTemplate( getTemplateName()) ) {

            CAILog.logMsg( "正在执行，返回true，退出" + getName(), pAIComponent.objId );
            pAIComponent.isOverrideAction = false;
            pAIComponent.bWheatherTriggerEvent = true;
            return true;
        }

        /*if ( m_pAIComponent.isMulEnterTemplate( getTemplateName() ) ) {
            if ( m_pAIComponent.bSeqConditionPassAndExecuting ) {
                CAILog.logMsg( "当前条件节点正在执行，固定返回ture 执行节点", m_pAIComponent.objId );
                return true;
            }
        }*/

        for ( var i : int = 0; i < m_selfTypeList.length; i++ ) {
            bRet = checkSelfItemPass( inputData, m_selfTypeList[ i ], m_selfOperatorList[ i ], m_selfValueList[ i ] );
            if ( !bRet )
                return false;
        }

        m_pAIComponent.currentSelfConditionNodeName = getName();
        return bRet;
    }

    [Inline]
    private function checkSelfItemPass( inputData : Object, selfResPropertyType : String, selfResOperatorType : String, selfResValue : Number ) : Boolean {
        var owner : CGameObject = inputData.owner as CGameObject;
        var pFacadeProperty : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        switch ( selfResPropertyType ) {
            case PropertyType.DEFENSE:
                return judgementValue( pFacadeProperty.DefensePower / pFacadeProperty.MaxDefensePower, selfResPropertyType, selfResValue, selfResOperatorType );
                break;
            case PropertyType.ATTACK:
                return judgementValue( pFacadeProperty.AttackPower / pFacadeProperty.MaxAttackPower, selfResPropertyType, selfResValue, selfResOperatorType );
                break;
            case PropertyType.LIFE:
                return judgementValue( pFacadeProperty.HP / Number( pFacadeProperty.MaxHP ), selfResPropertyType, selfResValue, selfResOperatorType );
                break;
            case PropertyType.ANGER:
                return judgementValue( pFacadeProperty.RagePower / pFacadeProperty.MaxRagePower, selfResPropertyType, selfResValue, selfResOperatorType );
                break;
        }
        return true;
    }

    private function judgementValue( propertyValue : Number, selfResPropertyType : String,
                                     selfResValue : Number, selfResOperatorType : String ) : Boolean {
        var operatorValue : Number = selfResValue / 100;
        switch ( selfResOperatorType ) {
            case OperatorType.DA_YU:
                if ( propertyValue > operatorValue ) {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                    return true;
                }
                else {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId, CAILog.enabledFailLog );
                    return false;
                }
                break;
            case OperatorType.DAYU_DENGYU:
                if ( propertyValue >= operatorValue ) {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                    return true;
                }
                else {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId, CAILog.enabledFailLog );
                    return false;
                }
                break;
            case OperatorType.DENG_YU:
                if ( propertyValue == operatorValue ) {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                    return true;
                }
                else {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId, CAILog.enabledFailLog );
                    return false;
                }
                break;
            case OperatorType.XIAO_YU:
                if ( propertyValue < operatorValue ) {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                    return true;
                }
                else {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId, CAILog.enabledFailLog );
                    return false;
                }
                break;
            case OperatorType.XIAOYU_DENGYU:
                if ( propertyValue <= operatorValue ) {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回true，退出" + getName(), m_pAIComponent.objId );
                    return true;
                }
                else {
                    CAILog.logMsg( "判断自身属性类型:" + selfResPropertyType + "，运算类型：" + selfResOperatorType + "，当前值为:"
                            + propertyValue + "，目标值为:" + operatorValue + "，返回false，退出" + getName(), m_pAIComponent.objId );
                    return false;
                }
                break;
        }
        return true;
    }
}
}
class SwitchType {
    public static const Close : String = "Close";
    public static const Open : String = "Open";

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
