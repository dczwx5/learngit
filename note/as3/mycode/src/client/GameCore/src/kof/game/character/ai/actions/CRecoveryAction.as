//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/25.
 * Time: 17:59
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import flash.geom.Point;

    import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.paramsTypeEnum.EFleeType;
    import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/25
     *
     * 恢复节点，恢复防御值、攻击值等
     */
    public class CRecoveryAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var recoveryValue : Number = 0;
        private var recoveryResType : String = PropertyType.ATTACK;
        private var keepawayDistance : Number = 0;

        private var _updateTime:Number=0.5;//0.5秒检测一次和敌方的距离
        private var _elapsedTime:Number=0.5;
        private var _bFinishFirstMove : Boolean;

        public function CRecoveryAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt, nodeName );
            this.m_pBT = pBt;
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
            if ( m_pBT.cacheParamsDic[ name + ".recoveryValue" ] ) {
                recoveryValue = m_pBT.cacheParamsDic[ name + ".recoveryValue" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".recoveryResType" ] ) {
                recoveryResType = m_pBT.cacheParamsDic[ name + ".recoveryResType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".keepawayDistance" ] ) {
                keepawayDistance = m_pBT.cacheParamsDic[ name + ".keepawayDistance" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
            _elapsedTime+=inputData.deltaTime;
            var pFacadeProperty : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
            var curValue : Number = 0;
            if ( recoveryResType == PropertyType.LIFE ) {
                curValue = pFacadeProperty.HP / pFacadeProperty.MaxHP;
            } else if ( recoveryResType == PropertyType.ATTACK ) {
                curValue = pFacadeProperty.AttackPower / pFacadeProperty.MaxAttackPower;
            } else if ( recoveryResType == PropertyType.DEFENSE ) {
                curValue = pFacadeProperty.DefensePower / pFacadeProperty.MaxDefensePower;
            } else if ( recoveryResType == PropertyType.ANGER ) {
                curValue = pFacadeProperty.RagePower / pFacadeProperty.MaxRagePower;
            }
            var targetValue : Number = recoveryValue / 100;
            if ( curValue < targetValue ) {
                var isMoving : Boolean;
                if( pAIComponent.currentAttackable ) {
                    isMoving = dataIO.getCharacterState( pAIComponent.currentAttackable, CCharacterStateBoard.MOVING );
                }
                if ( !isMoving && _bFinishFirstMove ) {
                    return CNodeRunningStatusEnum.EXECUTING;
                }
                if ( keepawayDistance != 0 ) {
                    if(_bExcute()){
                        _elapsedTime=0;
                        dataIO.moveTo( owner, keepawayDistance, 0, new Point( 0, 0 ), null, "ToFlee",false,EFleeType.DISTANCE);
                        _bFinishFirstMove = true;
                    }
                }
                CAILog.logMsg( "recoveryResType为" + recoveryResType + "当前值为"+curValue+"，目标值为:"+targetValue+"，返回正在执行，退出" + getName(), pAIComponent.objId );
//                CAILog.traceTemp("正在恢复，当前值"+curValue+"，目标值"+targetValue);
                return CNodeRunningStatusEnum.EXECUTING;
            }
            CAILog.logMsg( "recoveryResType为" + recoveryResType + "返回成功，退出" + getName(), pAIComponent.objId );
            _elapsedTime = _updateTime;
            _bFinishFirstMove = false;
            return CNodeRunningStatusEnum.SUCCESS;
        }

        private function _bExcute():Boolean{
            if(_elapsedTime-_updateTime>=0){
                return true;
            }
            return false;
        }
    }
}

class PropertyType {
    public static const LIFE : String = "Life";
    public static const ATTACK : String = "Attack";
    public static const DEFENSE : String = "Defense";
    public static const ANGER : String = "Anger";
}
