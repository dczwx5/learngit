//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/6/15.
 * Time: 15:40
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import flash.geom.Point;

    import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    public class CFollowAction extends CBaseNodeAction {
        private var _isArrive : Boolean = false;
        //节点参数，可在怪物表里边配置(超过多少距离后返回)
        private var followDistance : Number = 0;
        //是否返回的开关
        private var followBoolDistance : Boolean = false;
        //跟随目标
        private var followTarget : String = RoleType.PLAYER;
        private var followOffsetX : Number = 100;
        private var followOffsetY : Number = 20;

        private var _isExcuting : Boolean = false;

        private var pBT : CAIObject = null;
        private var _pAIComponent : CAIComponent = null;

        public function CFollowAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            this.pBT = pBt as CAIObject;
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( pBT.cacheParamsDic[ name + ".followDistance" ] ) {
                followDistance = pBT.cacheParamsDic[ name + ".followDistance" ];
            }
            if ( pBT.cacheParamsDic[ name + ".followTarget" ] ) {
                followTarget = pBT.cacheParamsDic[ name + ".followTarget" ];
            }
            if ( pBT.cacheParamsDic[ name + ".followOffsetX" ] ) {
                followOffsetX = pBT.cacheParamsDic[ name + ".followOffsetX" ];
            }
            if ( pBT.cacheParamsDic[ name + ".followOffsetY" ] ) {
                followOffsetY = pBT.cacheParamsDic[ name + ".followOffsetY" ];
            }
            if ( pBT.cacheParamsDic[ name + ".followBoolDistance" ] ) {
                followBoolDistance = pBT.cacheParamsDic[ name + ".followBoolDistance" ];
            }
        }

        override final public function _doEnter( data : Object ) : void {

        }

        override final public function _doExit( data : Object ) : void {

        }

        override final public function _doExecute( data : Object ) : int {
            var dataIO : IAIHandler = data.handler as IAIHandler;
            var owner : CGameObject = data.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            this._pAIComponent = pAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            var bool : Boolean;
//            if ( pAIComponent.isBackIngToMaster && pAIComponent.isBeAttacked ) {
//                pAIComponent.isBackIngToMaster = false;
//                return CNodeRunningStatusEnum.FAIL;
//            }
            if(followBoolDistance){//返回玩家身边、跟随，在自动战斗时不生效
                if(CAIHandler(dataIO).bAutoFight){
                    return CNodeRunningStatusEnum.FAIL;
                }
            }
            if ( _isArrive  ) {
                if(followBoolDistance)
                {
                    if(Point.distance( new Point( owner.transform.x, owner.transform.y ), new Point( pAIComponent.currentMaster.transform.x, pAIComponent.currentMaster.transform.y ) ) > followDistance/2)
                    {
                        CAILog.logMsg( "没有到达指定位置，返回失败，退出" + getName(), pAIComponent.objId );
                        _isArrive = false;
                        return CNodeRunningStatusEnum.FAIL;
                    }
                    else
                    {
                        CAILog.logMsg( "到达指定位置，返回成功，退出" + getName(), pAIComponent.objId );
                        _isArrive = false;
                        pAIComponent.resetMoveCallBakcFunc = null;
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                }
                else
                {
                    CAILog.logMsg( "到达指定位置，返回成功，退出" + getName(), pAIComponent.objId );
                    _isArrive = false;
                    pAIComponent.resetMoveCallBakcFunc = null;
                    return CNodeRunningStatusEnum.SUCCESS;
                }

            }
            if(_isExcuting&&followBoolDistance){//正在执行，又属于返回玩家的行为
                bool = dataIO.follow( owner, movetoEndCallBack, followOffsetX, followOffsetY, followDistance, followTarget, followBoolDistance );
                if ( bool == false ) {
                    if ( followDistance ) {
                        CAILog.logMsg( "没有超出执行返回玩家的距离，返回失败，退出" + getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.FAIL;
                    }
                    else {
                        CAILog.logMsg( "跟随结束，返回成功，退出" + getName(), pAIComponent.objId );
                        movetoEndCallBack();
                        return CNodeRunningStatusEnum.SUCCESS;
                    }

                }
                return CNodeRunningStatusEnum.EXECUTING;
            }
            var canExcute:Boolean;
            if(followBoolDistance&&pAIComponent.currentMaster){
                canExcute = Point.distance( new Point( owner.transform.x, owner.transform.y ), new Point( pAIComponent.currentMaster.transform.x, pAIComponent.currentMaster.transform.y ) ) <= followDistance;
                if(canExcute){
                    if ( followDistance ) {
                        CAILog.logMsg( "没有超出执行返回玩家的距离，返回失败，退出" + getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.FAIL;
                    }
                    else {
                        CAILog.logMsg( "跟随结束，返回成功，退出" + getName(), pAIComponent.objId );
                        movetoEndCallBack();
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                }
            }

            CAILog.logMsg( "调用跟随方法,跟随距离followDistance=" + followDistance + "跟随目标：" + followTarget, pAIComponent.objId );
            bool = dataIO.follow( owner, movetoEndCallBack, followOffsetX, followOffsetY, followDistance, followTarget, followBoolDistance );
            if ( bool == false ) {
                if ( followDistance ) {
                    CAILog.logMsg( "没有超出执行返回玩家的距离，返回失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.FAIL;
                }
                else {
                    CAILog.logMsg( "跟随结束，返回成功，退出" + getName(), pAIComponent.objId );
                    movetoEndCallBack();
                    return CNodeRunningStatusEnum.SUCCESS;
                }

            }
            _isExcuting = true;
            CAILog.logMsg( "正在执行跟随，返回正在执行，退出" + getName(), pAIComponent.objId );
            pAIComponent.isBackIngToMaster = true;
            pAIComponent.resetMoveCallBakcFunc = movetoEndCallBack;
            return CNodeRunningStatusEnum.EXECUTING;
        }

        private function movetoEndCallBack() : void {
            _isExcuting = false;
            _isArrive = true;
            this._pAIComponent.isBackIngToMaster = false;
        }
    }
}

class RoleType {
    public static const SOLDIER : String = "Soldier";
    public static const ELITE : String = "Elite";
    public static const BOSS : String = "Boss";
    public static const PLAYER : String = "Player";
}
