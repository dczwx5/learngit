//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/18.
 * Time: 15:28
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Framework.CObject;
    import QFLib.Math.CVector3;

    import flash.geom.Point;

    import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/18
     */
    public class CAttractMonsterMoveAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var _isArrive : Boolean = false;
        private var _owner : CGameObject = null;
        private var _isAttracting : Boolean = false;

        private var _ownerPos2D : CVector3 = null;

        public function CAttractMonsterMoveAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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

        }

        override public final function _doExecute( inputData : Object ) : int {
            var handler : IAIHandler = inputData.handler;
            if ( handler == null )return CNodeRunningStatusEnum.FAIL;
            var owner : CGameObject = inputData.owner;
            _owner = owner;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if ( !_isArrive ) {
                if ( !_isAttracting ) {
                    var enemyObj : Vector.<CGameObject> = handler.findAllEnemyObj( owner );
                    enemyObj.sort( _sortDistanceForEnemy );
                    var len : int = enemyObj.length;
                    var pathArr : Array = [];
                    var obj : Object = null;

                    if ( !_ownerPos2D )
                        _ownerPos2D = new CVector3();
                    for ( var i : int = 0; i < len; i++ ) {
                        obj = new Object();
                        CObject.get2DPositionFrom3D( enemyObj[ i ].transform.x, enemyObj[ i ].transform.z, enemyObj[ i ].transform.y, _ownerPos2D );
                        obj.x = _ownerPos2D.x;
                        obj.y = _ownerPos2D.y;
                        pathArr.push( obj );
                    }
                    obj = new Object();
                    CObject.get2DPositionFrom3D( owner.transform.x, owner.transform.z, owner.transform.y, _ownerPos2D );
                    obj.x = _ownerPos2D.x;
                    obj.y = _ownerPos2D.y;
                    pathArr.push( obj );
                }
                //注释后中途被攻击，不会中断这个行为 霸体的问题还没解决，技能和AI交叉设置，所以不能注释
                pAIComponent.resetMoveCallBakcFunc = _callbackFunc;
                var bool : Boolean = handler.moveAttractMonster( owner, pathArr, 0, 0, _callbackFunc );
                if ( !bool ) {
                    _callbackFunc();
                    CAILog.logMsg( "引怪失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.FAIL;
                }
            } else {
                _isArrive = false;
                CAILog.logMsg( "引怪完成，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logMsg( "正在引怪，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }

        private function _callbackFunc() : void {
            _isArrive = true;
        }

        private function _sortDistanceForEnemy( a : CGameObject, b : CGameObject ) : int {
            var dis1 : Number = Point.distance( new Point( _owner.transform.x, _owner.transform.y ), new Point( a.transform.x, a.transform.y ) );
            var dis2 : Number = Point.distance( new Point( _owner.transform.x, _owner.transform.y ), new Point( b.transform.x, b.transform.y ) );
            if ( dis1 < dis2 ) {
                return -1;
            }
            else if ( dis1 == dis2 ) {
                return 0;
            } else {
                return 1;
            }
        }
    }
}
