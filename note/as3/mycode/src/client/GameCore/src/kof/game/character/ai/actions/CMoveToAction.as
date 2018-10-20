//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/9.
 * Time: 15:00
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Foundation;

    import flash.geom.Point;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.core.CGameObject;

    public class CMoveToAction extends CBaseNodeAction {
        private var moveToDistance : Number = 0;
        private var moveToType : String = TO_ATTACK;
        private var moveToAxes : String = "Z";
        private var moveToOffsetX : Number = 0;
        private var moveToOffsetY : Number = 0;
        private var moveToFlee : String = RANDOM;
        private var moveToDuration : String = MovetoDuration.XIAOYU_DENGYU_0;
        private var moveToLimitTime : Number = 0;

        public static const TO_OFFSET : String = "ToOffset";
        public static const TO_ATTACK : String = "ToAttack";
        public static const TO_BACK : String = "ToBack";
        public static const TO_FLEE : String = "ToFlee";
        public static const TO_AXES : String = "ToAxes";

        public static const RANDOM : String = "Random";
        /**足够远*/
        public static const FARAWAY : String = "FarAway";
        public static const DISTANCE : String = "Distance";

        private var m_moveBack : Boolean = false;
        private var m_moveFlee : Boolean = false;
        private var m_moveAxes : Boolean = false;

        private var m_pBT : CAIObject = null;
        private var m_pAIComponent : CAIComponent = null;
        private var m_pHandler : IAIHandler = null;

        public function CMoveToAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            this.m_pBT = pBt;
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            try {
                if ( m_pBT.cacheParamsDic[ name + ".moveToDistance" ] ) {
                    moveToDistance = m_pBT.cacheParamsDic[ name + ".moveToDistance" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToType" ] ) {
                    moveToType = m_pBT.cacheParamsDic[ name + ".moveToType" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToAxes" ] ) {
                    moveToAxes = m_pBT.cacheParamsDic[ name + ".moveToAxes" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToOffsetX" ] ) {
                    moveToOffsetX = m_pBT.cacheParamsDic[ name + ".moveToOffsetX" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToOffsetY" ] ) {
                    moveToOffsetY = m_pBT.cacheParamsDic[ name + ".moveToOffsetY" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToFlee" ] ) {
                    moveToFlee = m_pBT.cacheParamsDic[ name + ".moveToFlee" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToDuration" ] ) {
                    moveToDuration = m_pBT.cacheParamsDic[ name + ".moveToDuration" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".moveToLimitTime" ] ) {
                    moveToLimitTime = m_pBT.cacheParamsDic[ name + ".moveToLimitTime" ];
                }
            }
            catch ( e : Error ) {
                throw e.message;
            }

        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler;
//        m_pHandler =
            if ( dataIO == null )return CNodeRunningStatusEnum.FAIL;
            var owner : CGameObject = inputData.owner;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if(pAIComponent.excutingSkill){
                CAILog.logMsg( "当前有技能在释放中，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( !pAIComponent.currentAttackable ) {
                CAILog.logMsg( "当前攻击目标不存在，返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( dataIO.isDead( pAIComponent.currentAttackable ) ) {
                CAILog.logMsg( "当前攻击目标已死亡，返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }
            m_pAIComponent = pAIComponent;
            if ( !dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
                CAILog.logMsg( "角色处于不可控状态，返回失败，退出" + getName(), pAIComponent.objId );
                movetoEndCallBack();
                return CNodeRunningStatusEnum.FAIL;
            } else if ( isArrive ) {
                CAILog.logMsg( "到达指定位置，返回成功，退出" + getName(), pAIComponent.objId );
                isArrive = false;
                return CNodeRunningStatusEnum.SUCCESS;
            } else {
                var bool : Boolean;
                if ( moveToType == TO_BACK && !m_moveBack ) {
                    CAILog.logMsg( "开始移动，移动类型" + moveToType, pAIComponent.objId );
                    m_moveBack = true;
                    bool = dataIO.moveTo( owner, moveToDistance, 0, new Point( 0, 0 ), movetoEndCallBack, moveToType );
                }
                else if ( moveToType == TO_ATTACK ) {
                    CAILog.logMsg( "开始移动，移动类型" + moveToType, pAIComponent.objId );
                    bool = dataIO.moveTo( owner, moveToDistance, 0, new Point( moveToOffsetX, moveToOffsetY ), movetoEndCallBack, moveToType );
                }
                else if ( moveToType == TO_FLEE ) {
                    if ( m_moveFlee ) {
                        CAILog.logMsg( "正在远离，返回正在执行，退出" + getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.EXECUTING;
                    }
                    CAILog.logMsg( "开始移动，移动类型" + moveToType, pAIComponent.objId );
                    bool = dataIO.moveTo( owner, moveToDistance , 0, new Point( 0, 0 ), movetoEndCallBack, moveToType, false , moveToFlee );
                    if ( bool ) {
                        m_moveFlee = true;
                    }
                }
                else if ( moveToType == TO_AXES ) {
                    CAILog.logMsg( "开始移动，移动类型" + moveToType, pAIComponent.objId );
                    bool = dataIO.moveTo( owner, moveToDistance, 0, new Point( 0, 0 ), movetoEndCallBack, moveToType );
                }
                else if ( moveToType == TO_OFFSET ) {
                    CAILog.logMsg( "开始移动，移动类型" + moveToType, pAIComponent.objId );
                    if ( pAIComponent.currentAttackable ) {
                        var targetX : Number = pAIComponent.currentAttackable.transform.x;
                        var targeetY : Number = pAIComponent.currentAttackable.transform.y;
                        var directX : Number = owner.transform.x - pAIComponent.currentAttackable.transform.x;
                        if ( directX > 0 ) {
                            bool = dataIO.moveTo( owner, moveToDistance, 0, new Point( targetX + moveToOffsetX, targeetY ), movetoEndCallBack, moveToType );
                        } else {
                            bool = dataIO.moveTo( owner, moveToDistance, 0, new Point( targetX - moveToOffsetX, targeetY ), movetoEndCallBack, moveToType );
                        }

                    }

                }
                if ( bool == false ) {
                    CAILog.logMsg( "到达指定位置，返回成功，退出" + getName(), pAIComponent.objId );
                    pAIComponent.resetMoveCallBakcFunc = null;
                    movetoEndCallBack();
                    return CNodeRunningStatusEnum.SUCCESS;
                }
                pAIComponent.resetMoveCallBakcFunc = movetoEndCallBack;
            }
            pAIComponent.isBeAttacked = false;
            CAILog.logMsg( "正在移动，返回正在执行，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }

        //重置移动状态
        private function movetoEndCallBack() : void {

            isArrive = true;
            m_moveFlee = false;
            if ( m_pAIComponent ) {
                m_pAIComponent.useSkillEnd = false;
            }
            CAILog.logMsg( "移动结束重置移动状态", m_pAIComponent.objId );
        }

        private function getTargetPos( inputData : Object ) : void {
            var posx : Number = int( Math.random() * 3 ) - 1;
            var posy : Number = int( Math.random() * 3 ) - 1;
            inputData.targetPosition = new Point( posx, posy );
        }

        private var isArrive : Boolean = false;
    }
}

class MovetoDuration {
    public static const XIAOYU_DENGYU_0 : String = "小于等于0";
    public static const DAYU_0 : String = "大于0";
}
