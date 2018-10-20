//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/18.
 * Time: 18:22
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Framework.CObject;
    import QFLib.Framework.CScene;
    import QFLib.Math.CVector3;

    import flash.geom.Point;
import flash.geom.Vector3D;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.ai.paramsTypeEnum.ECampType;
import kof.game.character.display.IDisplay;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
    import kof.game.scene.CSceneRendering;
    import kof.game.scene.CSceneSystem;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/18
     * 查找通关目标
     */
    public class CFindPassTargetAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var isArrive : Boolean = false;

        private var m_entityObj : Object = null;
        private var entityX : Number = 0;
        private var entityY : Number = 0;//触发器位置

        private var portalX : int = 0;
        private var portalY : int = 0;//传送门位置

        public function CFindPassTargetAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
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
//            if ( m_pBT.cacheParamsDic[ name + ".skillIndex" ] ) {
//                skillIndex = m_pBT.cacheParamsDic[ name + ".skillIndex" ];
//            }
        }

        override public function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );

            var coolTime : Number = pAIComponent.delayTimeMap.find( m_index );
           if( !isNaN( coolTime ) && coolTime >0.0 ) {
               pAIComponent.addNodeCoolTime( m_index, coolTime );
               CAILog.logEnterSubNodeInfo( m_index + "-Next Cool Time", "执行成功 进入 -短短短短短- delayTime CD为：" + coolTime, pAIComponent.objId );
           }

            if ( !dataIO.isHero( owner ) ) {
                CAILog.logMsg( "非主控角色，无需判断通过trunk的目标条件，返回失败", pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }

            var obj : Object = dataIO.getLevelCurTrunkPass();
            var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
            var vec3 : CVector3 = null;
            var scene : CScene = ((dataIO.m_system.stage.getSystem( CSceneSystem ) as CSceneSystem).getBean( CSceneRendering ) as CSceneRendering).scene;

            if ( obj.targetType == 0 || obj.targetType == 1 ) { //杀死所有敌方
                if(dataIO.findAttackable( owner ,ECampType.ENEMY,"All","ShortDistance","Self","-1","-1" ) != null ){
                    var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator , true ) as CEventMediator;
                     if( pEventMediator )
                             pEventMediator.dispatchEvent( new CCharacterEvent(CCharacterEvent.STOP_MOVE , null ));
                    return CNodeRunningStatusEnum.FAIL;
                }
                dataIO.iTrunkTarget = 0;
//                if ( isArrive ) {
//                    isArrive = false;
//                    isMoving = false;
//                    return CNodeRunningStatusEnum.SUCCESS;
//                }
//                if ( !isMoving ) {
//                    m_entityObj = dataIO.getEntityRange();//{location:{x:111,y:111},size:{x:111,y:111}}
//                    entityX = m_entityObj.location.x;
//                    entityY = m_entityObj.location.y;
//                    var bool : Boolean = dataIO.move( owner, [ {
//                        x : entityX,
//                        y : entityY
//                    } ], 0, 0, function () : void {
//                        isArrive = true;
//                    } );
//                    if ( !bool ) {
//                        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
//                        var vec3 : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, entityX, entityY );
//                        var scene : CScene = ((dataIO.m_system.stage.getSystem( CSceneSystem ) as CSceneSystem).getBean( CSceneRendering ) as CSceneRendering).scene;
//                        vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3 );
////        var newTargetPoint:CVector2 = new CVector2(vec3.x,vec3.z);
//                        var nearX : Number = vec3.x;
//                        var nearY : Number = vec3.z;
//                        CAILog.logMsg( "找到传送门位置不能移动，再次查找，新位置x:" + nearX + ",y:" + nearY, pAIComponent.objId );
//                        bool = dataIO.moveToPos( owner, new Point( nearX, nearY ), function () : void {
//                            isArrive = true;
//                            isMoving = false;
//                        } );
//                    }
//                    if ( bool ) {
//                        isMoving = true;
////                    pAIComponent.resetMoveCallBakcFunc = _moveCompoleteCallBackFunc;
//                        return CNodeRunningStatusEnum.EXECUTING;
//                    } else {
//                        CAILog.logMsg( "不能移动到指定区域触发器,坐标:" + entityX + "，" + entityY, pAIComponent.objId );
//                    }
//                } else {
//                    return CNodeRunningStatusEnum.EXECUTING;
//                }
                //----------------------------------------
                if ( !pAIComponent.currentAttackable ) {
                 var arr : Array = dataIO.getLevelPortal();// [{"location" : {"x" : 1800.0,"y" : 600.0},"effect":"无","size": {"x" : 200.0,"y" : 200.0},"triggerTime":1.5}]
                 portalX = arr[ 0 ].location.x;
                 portalY = arr[ 0 ].location.y;
                 bool = dataIO.move( owner, [ {
                 x : portalX,
                 y : portalY
                 } ], 0, 0, null );
                 if ( !bool ) {
                     vec3=CObject.get3DPositionFrom2D( pDisplay.modelDisplay, portalX, portalY );
                 vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3 );
                 //        var newTargetPoint:CVector2 = new CVector2(vec3.x,vec3.z);
                 portalX = vec3.x;
                 portalY = vec3.z;
                 CAILog.logMsg( "找到传送门位置不能移动，再次查找，新位置x:" + portalX + ",y:" + portalY, pAIComponent.objId );
                 bool = dataIO.moveToPos( owner, new Point( portalX, portalY ), null );
                 }
                 if ( bool ) {
                     pAIComponent.isMovingPassTarget=true;
                 //                    pAIComponent.resetMoveCallBakcFunc = _moveCompoleteCallBackFunc;
                 CAILog.logMsg( "找到传送门位置，x:" + portalX + "y:" + portalY + "，即将移动", pAIComponent.objId );
                 return CNodeRunningStatusEnum.EXECUTING;
                 }
                 } else {
                 return CNodeRunningStatusEnum.SUCCESS;
                 }
            } else if ( obj.targetType == 1 ) {//击杀指定敌人

            } else if ( obj.targetType == 2 ) {//击杀任意敌人

            } else if ( obj.targetType == 3 ) {//完成指定触发器
                dataIO.iTrunkTarget = 3;
                if ( isArrive ) {
                    isArrive = false;
                    pAIComponent.isMovingPassTarget=false;
                    return CNodeRunningStatusEnum.SUCCESS;
                }
                if ( !pAIComponent.isMovingPassTarget || !dataIO.getCharacterState( owner, CCharacterStateBoard.MOVING )) {
                    m_entityObj = dataIO.getEntityRange();//{location:{x:111,y:111},size:{x:111,y:111}}
                    if(m_entityObj==null){
                        CAILog.warningMsg( "没有触发器,退出"+getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.FAIL;
                    }
                    entityX = m_entityObj.location.x;
                    entityY = m_entityObj.location.y;
                    var bool : Boolean = dataIO.move( owner, [ {
                        x : entityX,
                        y : entityY
                    } ], 0, 0, function () : void {
                        isArrive = true;
                    } );
                    if ( !bool ) {
                        vec3=CObject.get3DPositionFrom2D( pDisplay.modelDisplay, entityX, entityY );
                        vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3 );
//        var newTargetPoint:CVector2 = new CVector2(vec3.x,vec3.z);
                        var nearX : Number = vec3.x;
                        var nearY : Number = vec3.z;
                        CAILog.logMsg( "找到传送门位置不能移动，再次查找，新位置x:" + nearX + ",y:" + nearY, pAIComponent.objId );
                        bool = dataIO.moveToPos( owner, new Point( nearX, nearY ), function () : void {
                            isArrive = true;
                            pAIComponent.isMovingPassTarget = false;
                        } );
                    }
                    if ( bool ) {
                        pAIComponent.isMovingPassTarget = true;
//                    pAIComponent.resetMoveCallBakcFunc = _moveCompoleteCallBackFunc;
                        return CNodeRunningStatusEnum.EXECUTING;
                    } else {
                        CAILog.logMsg( "不能移动到指定区域触发器,坐标:" + entityX + "，" + entityY, pAIComponent.objId );
                    }
                } else {
                    return CNodeRunningStatusEnum.EXECUTING;
                }
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
