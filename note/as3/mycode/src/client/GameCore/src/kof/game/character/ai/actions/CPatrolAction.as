//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/18.
 * Time: 16:59
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

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/18
     */
    public class CPatrolAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;
        private var _isArrive : Boolean = false;
        private var _ptx : Number = 0;
        private var _pty : Number = 0;
        /**巡逻范围*/
        private var patrolRange : Number = 0;
        /**巡逻指定点*/
        private var patrolPoint : String = "";

        public function CPatrolAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( m_pBT.cacheParamsDic[ name + ".patrolRange" ] ) {
                patrolRange = m_pBT.cacheParamsDic[ name + ".patrolRange" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".patrolPoint" ] ) {
                patrolPoint = m_pBT.cacheParamsDic[ name + ".patrolPoint" ];
            }
            if ( patrolPoint != "" ) {
                _ptx = patrolPoint.split( "," )[ 0 ];
                _pty = patrolPoint.split( "," )[ 1 ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var handler : IAIHandler = inputData.handler;
            if ( handler == null )return CNodeRunningStatusEnum.FAIL;
            var owner : CGameObject = inputData.owner;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if ( !_isArrive ) {
                var xMax : Number = 0;
                var xMin : Number = 0;
                var zrange : Number = patrolRange * 0.4;
                var yMax : Number = 0;
                var yMin : Number = 0;
                if ( patrolPoint != "" ) {
                    xMax = _ptx + patrolRange;
                    xMin = _ptx - patrolRange;
                    yMax = _pty + zrange;
                    yMin = _pty + zrange;
                    if ( owner.transform.x > xMax || owner.transform.x < xMin || owner.transform.y > yMax || owner.transform.y < yMin ) {
                        var bool : Boolean = handler.move( owner, [ {x : _ptx, y : _pty} ], 0, 0, _callbackFunc );
                        if ( !bool ) {
                            _callbackFunc();
                            CAILog.logMsg( "返回指定点失败，退出" + getName(), pAIComponent.objId );
                            return CNodeRunningStatusEnum.FAIL;
                        }
                    }
                    else{
                        return CNodeRunningStatusEnum.FAIL;
                    }
                } else {
                    xMax = handler.getPlayer( owner ).transform.x + patrolRange;
                    xMin = handler.getPlayer( owner ).transform.x - patrolRange;
                    yMax = handler.getPlayer( owner ).transform.y + zrange;
                    yMin = handler.getPlayer( owner ).transform.y + zrange;
                    var randX : Number = Math.random() * xMax + xMin;
                    var randY : Number = Math.random() * yMax + yMin;
                    pAIComponent.resetMoveCallBakcFunc = _callbackFunc;
                    var bool1 : Boolean = handler.move( owner, [ {x : randX, y : randY} ], 0, 0, _callbackFunc );
                    if ( !bool1 ) {
                        _callbackFunc();
                        CAILog.logMsg( "巡逻失败，退出" + getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
            }
            else {
                CAILog.logMsg( "巡逻成功，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logMsg( "正在巡逻，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }

        private function _callbackFunc() : void {
            _isArrive = true;
        }
    }
}
