//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/18.
 * Time: 18:23
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

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.CTarget;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;

import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.ai.paramsTypeEnum.ECampType;
import kof.game.character.display.IDisplay;
import kof.game.character.scene.CBubblesMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/9/18
 * 查找通关方式
 */
public class CFindPassWayAction extends CBaseNodeAction {
    private var m_pBT : CAIObject = null;
    private var isArrive : Boolean = false;

    private var m_pAiHandler : IAIHandler = null;
    private var m_counter : int = 0;
    private var portalX : int = 0;
    private var portalY : int = 0;

    public function CFindPassWayAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
        m_pAiHandler = inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        CAILog.logMsg( "进入" + getName(), pAIComponent.objId );


        var passWayType : int = m_pAiHandler.currentTrunkPassWay();//0向传送门走，1原地停留
        if ( passWayType == 0 ) {//击杀所有
            var bool : Boolean;
            if ( !pAIComponent.isMovingPassWay ) {

                var arr : Array = m_pAiHandler.getLevelPortal();// [{"location" : {"x" : 1800.0,"y" : 600.0},"effect":"无","size": {"x" : 200.0,"y" : 200.0},"triggerTime":1.5}]
                portalX = arr[ 0 ].location.x;
                portalY = arr[ 0 ].location.y;
                bool = m_pAiHandler.move( owner, [ {
                    x : portalX,
                    y : portalY
                } ], 0, 0, _moveCompoleteCallBackFunc );

                if ( !bool ) {
                    var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
                    var vec3 : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, portalX, portalY );
                    var scene : CScene = ((m_pAiHandler.m_system.stage.getSystem( CSceneSystem ) as CSceneSystem).getBean( CSceneRendering ) as CSceneRendering).scene;
                    vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3 );
//        var newTargetPoint:CVector2 = new CVector2(vec3.x,vec3.z);
                    var nearX : Number = vec3.x;
                    var nearY : Number = vec3.z;
                    CAILog.logMsg( "找到传送门位置不能移动，再次查找，新位置x:" + portalX + ",y:" + portalY, pAIComponent.objId );
                    bool = m_pAiHandler.moveToPos( owner, new Point( nearX, nearY ), _moveCompoleteCallBackFunc );
                }
                if ( bool ) {
                    pAIComponent.isMovingPassWay = true;
//                    pAIComponent.resetMoveCallBakcFunc = _moveCompoleteCallBackFunc;
                    CAILog.logMsg( "找到传送门位置，x:" + nearX + "y:" + nearY + "，即将移动", pAIComponent.objId );
                    return CNodeRunningStatusEnum.EXECUTING;
                }
            } else {
                 if ( pAIComponent.isMovingPassWay &&
                        m_pAiHandler.findAttackable( owner, ECampType.ENEMY, "All", "ShortDistance", "Self", "-1", "-1" ) != null ) {
                    m_counter = 0;
                    pAIComponent.isMovingPassWay = false;
                     var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator , true ) as CEventMediator;
                     if( pEventMediator )
                             pEventMediator.dispatchEvent( new CCharacterEvent(CCharacterEvent.STOP_MOVE , null ));
                    return CNodeRunningStatusEnum.SUCCESS;
                }
                if ( !pAIComponent.currentAttackable ) {

                    m_counter++;//计数是为了解决，有时跑到下一个trunk的版变了，结果怪物没有刷出来，然后就一直在那里跑；这时超过80次（次数可以随便调整），则让AI往回跑，这样来回跑，为了把怪物刷出来，早起关卡那边有一些bug，所以AI这里曲线解决
                    CAILog.logMsg( "正在向传送门移动", pAIComponent.objId );
                    if ( m_counter > 80 ) {
                        var direction : Point = (owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard).getValue( CCharacterStateBoard.DIRECTION );
                        var randX : Number = Math.random() * (m_pAiHandler.getLevelCurTrunk().width - 200) + 200;
                        if ( direction.x < 0 ) { //面向左方
                            bool = m_pAiHandler.moveToPos( owner, new Point( owner.transform.x + randX, owner.transform.y ), function () : void {
                                m_counter = 200
                            } );
                            if ( bool ) {
                                m_counter = 0;
                                CAILog.logMsg( "移向传送门超时，向右方移动", pAIComponent.objId );
                            }
                        } else {  //面向右方
                            bool = m_pAiHandler.moveToPos( owner, new Point( owner.transform.x - randX, owner.transform.y ), function () : void {
                                m_counter = 200;
                            } );
                            if ( bool ) {
                                m_counter = 0;
                                CAILog.logMsg( "移向传送门超时，向左方移动", pAIComponent.objId );
                            }
                        }
                    }
                    return CNodeRunningStatusEnum.EXECUTING;
                } else {
                    m_counter = 0;
                    pAIComponent.isMovingPassWay = false;
                }
            }
        } else if ( passWayType == 1 ) {  //原地停留

        }
        CAILog.logMsg( "向传送门移动成功", pAIComponent.objId );
        return CNodeRunningStatusEnum.SUCCESS;
    }

    private function _moveCompoleteCallBackFunc() : void {
//            isMovingPassWay = false;
//            m_counter = 0;
    }
}
}
