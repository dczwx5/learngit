//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/5.
 * Time: 12:29
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;
import QFLib.Foundation.CTimeDog;
import QFLib.Framework.CObject;
import QFLib.Math.CAABBox2;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.display.IDisplay;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/5
     */
    public class CRandomMoveAction extends CBaseNodeAction {
        /**相对自己前方的X范围*/
        private var rmRangeX : int = 0;
        /**相对自己前面的Y范围*/
        private var rmRangeY : int = 0;
        private var brmWander : Boolean;

        private var isArrive : Boolean = false;

        private var pBT : CAIObject = null;
        private var _moving : Boolean = false;
        private var _rndx : Number = 0;
        private var _rndy : Number = 0;
        private var _trunk : Rectangle = null;
        private var _ownerPos2D : CVector3 = null;

        public function CRandomMoveAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( pBT.cacheParamsDic[ name + ".rmRangeX" ] ) {
                rmRangeX = pBT.cacheParamsDic[ name + ".rmRangeX" ];
            }
            if ( pBT.cacheParamsDic[ name + ".rmRangeY" ] ) {
                rmRangeY = pBT.cacheParamsDic[ name + ".rmRangeY" ];
            }
            if ( pBT.cacheParamsDic[ name + ".brmWander" ] ) {
                brmWander = pBT.cacheParamsDic[name + ".brmWander"];
            }
        }

        override final public function _doExecute( data : Object ) : int {
            var dataIO : IAIHandler = data.handler as IAIHandler;
            var owner : CGameObject = data.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;

            if( brmWander ){
                if( pAIComponent.currentAttackable )
                    return CNodeRunningStatusEnum.FAIL;
            }else {

                if ( !pAIComponent.currentAttackable ) {
                    CAILog.logMsg( "当前攻击目标不存在，返回失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.FAIL;
                }
                if ( dataIO.isDead( pAIComponent.currentAttackable ) ) {
                    CAILog.logMsg( "当前攻击目标已死亡，返回失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.FAIL;
                }
                if ( !dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
                    CAILog.logMsg( "角色处于不可控状态，返回失败，退出" + getName(), pAIComponent.objId );
                    movetoEndCallBack();
                    return CNodeRunningStatusEnum.FAIL;
                }
            }

            var elapseMoveTime : Number = pAIComponent.fRandomMoveTime;
            if ( isArrive || (!isNaN(elapseMoveTime) && elapseMoveTime >= 2.0)) {
                pAIComponent.m_bNeedCoolDown = true;
                isArrive = false;
                _moving = false;
                pAIComponent.fRandomMoveTime = NaN;
                return CNodeRunningStatusEnum.SUCCESS;
            }

            if ( !_moving ) {
                var w : int = rmRangeX;
                var h : int = rmRangeY * 0.4;
                _rndx = 0;
                _rndy = 0;
                var direction : Point = (owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard).getValue( CCharacterStateBoard.DIRECTION );
                var offsetWidth : Number = 0.0;
                var pDisplay : IDisplay = owner.getComponentByClass( IDisplay ,false) as IDisplay;
                if( pDisplay) {
                    var boundBox : CAABBox2= pDisplay.defaultBound;
                    if( boundBox )
                            offsetWidth = boundBox.width;
                }

                if ( direction.x < 0 ) { //面向左方
                    _rndx = owner.transform.x - Math.random() * w + offsetWidth;
                    _rndy = (Math.random() * 2 * h - h) + owner.transform.y;
                } else if ( direction.x > 0 ) { //面向右方
                    _rndx = owner.transform.x + Math.random() * w - offsetWidth;
                    _rndy = (Math.random() * 2 * h - h) + owner.transform.y;
                }

                var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;
                var canMove : Boolean;

                dataIO.clearMoveFinishCallBackFunction(owner);
                if( pFacadeMediator ) {
                   canMove = pFacadeMediator.moveTo( new CVector2( _rndx , _rndy  ) , movetoEndCallBack );
                }
                if( !canMove ){
                    CAILog.logMsg( "随机点超出trunk范围，不移动，返回成功，退出" + getName(), pAIComponent.objId );
                    _moving = false;
                    return CNodeRunningStatusEnum.SUCCESS;
                }

                _moving = true;
                pAIComponent.fRandomMoveTime = 0.0;
                pAIComponent.resetMoveCallBakcFunc = movetoEndCallBack;
            }
            CAILog.logMsg( "随机移动正在执行，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }

        private function movetoEndCallBack() : void {
            isArrive = true;

        }
    }
}
