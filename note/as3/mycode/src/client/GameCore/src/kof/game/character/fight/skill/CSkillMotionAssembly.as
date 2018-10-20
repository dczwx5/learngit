//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/1.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.utils.Dictionary;

import kof.game.character.CCharacterEvent;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.CKOFTransform;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.movement.CMotionAction;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Motion;
import kof.table.Motion.ETransWay;
import kof.util.CAssertUtils;

public class CSkillMotionAssembly implements IUpdatable {

    public function CSkillMotionAssembly( owner : CGameObject, boUseInSkillEffect : Boolean = false ) {
        m_owner = owner;
        m_moveEndCallBack = new Dictionary();
        m_boUseInSkillEffect = boUseInSkillEffect;
    }

    public function dispose() : void {
        unSubscribeDoMotion();
        for ( var func : Function in m_moveEndCallBack ) {
            delete m_moveEndCallBack[ func ];
        }
        m_moveEndCallBack = null;
    }

    public function update( delta : Number ) : void {
        if ( null == motionData )
            return;

        //如果开始tick并且不在移动中，开始设置移动状态数据
        if ( m_isReady && !m_isMoving ) {
            m_isMoving = true;
            doMotion();
        }

        if ( m_isReady && m_isMoving )
            m_tickTime = m_tickTime + delta;

        if ( m_tickTime >= motionData.Duration ) {
            exitMotion();
        }

    }

    public function firstUpdate( delta : Number ) : void {
        if ( null == motionData )
            return;

        //如果开始tick并且不在移动中，开始设置移动状态数据
        if ( m_isReady && !m_isMoving ) {
            doMotion();
            m_isMoving = true;
        }

        if ( m_isReady && m_isMoving )
            m_tickTime = m_tickTime + delta;
    }

    public function lastUpdate( delta : Number ) : void {

        if ( !motionData || m_tickTime >= motionData.Duration )
            exitMotion();
    }

    final public function get isRunning() : Boolean {
        return m_isReady && m_isMoving;
    }

    /**
     *
     * @param mData
     * @param aliasPos
     * @param moveEndCallback
     * @param args 0 为是否击飞借宿标志，2位被打时的碰撞
     */
    public function subscribeDoMotion( mData : Motion, aliasPos : CVector3 = null, moveEndCallback : Function = null, ... args ) : void {


        if ( null != moveEndCallback )
            this.m_moveEndCallBack[ moveEndCallback ] = args || null;

        motionData = mData;
        m_aliasTargetPosition = aliasPos;
        m_isReady = true;
        m_isMoving = false;
        m_tickTime = 0.0;

        m_boKnockUpFlyMotion = args == null ? false : args[ 0 ];
        m_fDistanceRadio = args != null && args.length > 1 ? (args[ 1 ] < 0 ? 0 : args[ 1 ]) : 0.0;

        m_pMotionAction = m_pMotionAction || new CMotionAction();
        var pMoveCmp : CMovement = this.movementCmp;
        if ( pMoveCmp ) {
            m_pMotionAction.moveSpeed = pMoveCmp.moveSpeed;
            m_pMotionAction.moveSpeedFactor = 1.0;
        }
    }

    //外部强制停止动作
    public function unSubscribeDoMotion() : void {
        exitMotion();
    }

    private function coverMotion() : void {
        //TODO when anthor motion effect coming during doing a motion ,break the doing one and  play the new coming motio
    }

    public function doMotion() : void {
        //TODO USE THE CURRENT MOTION INFO TO SET THE STATUS OF m_pMovement AND m_pAnimation
        handleMovement();
        handleAnimation();
    }

    private function enterMotion() : Boolean {
        //TODO this return true if the owner can process motion (always doing motion after frozen status)
        return false;
    }

    private function popMoveEndCallBack() : void {
        if ( m_moveEndCallBack ) {
            for ( var endFunc : Function in m_moveEndCallBack ) {
                if ( endFunc == null )
                    continue;
                var callFunc : Function = endFunc;
                var args : Array = m_moveEndCallBack[ callFunc ];
                delete m_moveEndCallBack[ callFunc ];
                callFunc.apply( null, args );
            }
        }
    }

    public function exitMotion() : void {
        popMoveEndCallBack();
        resumeMovement();
        resumeAnimation();

        m_tickTime = 0.0;
        m_motionData = null;
        m_aliasTargetPosition = null;
        m_isReady = false;
        m_isMoving = false;
        m_pMotionAction = null;
    }

    private function handleMovement() : void {
        var moveCmp : CMovement = movementCmp;
        var moveDir : Point;

        var discresRadio : Number = isNaN( motionData.DiscreseRadio ) ? 0.0 : motionData.DiscreseRadio;
        var distanceRadio : Number = m_fDistanceRadio;
        var fZDirection : Number;
        fZDirection = motionData.xSpeed == 0 ? 1.0 : motionData.zSpeed / motionData.xSpeed;
        //处理位移方式 暂时支持拉近，退远
        if ( motionData.TransWay == ETransWay.TO_SELF || motionData.TransWay == ETransWay.TO_SPELLER ) {
            moveDir = new Point( -transformCmp.position.x + m_aliasTargetPosition.x,
                    -transformCmp.position.y + m_aliasTargetPosition.y );
            distanceRadio = 1.0 - distanceRadio;
        }
        else if ( motionData.TransWay == ETransWay.AWAY_SELF || motionData.TransWay == ETransWay.AWAY_SPELLER ) {
            moveDir = new Point( transformCmp.position.x - m_aliasTargetPosition.x,
                    transformCmp.position.y - m_aliasTargetPosition.y );
        }
        else if ( motionData.TransWay == ETransWay.BACKWARD ) {
            m_iDirectionX = m_iDirectionX || 1;
            moveDir = new Point( -m_iDirectionX, -fZDirection );
            // transformCmp.position.y - m_aliasTargetPosition.y);
        } else if ( motionData.TransWay == ETransWay.FORWARD ) {
            m_iDirectionX = m_iDirectionX || 1;
            moveDir = new Point( m_iDirectionX, fZDirection );
        } else if ( motionData.TransWay == 7 ) {
            moveDir = new Point( m_iDirectionX, 0 );
        }

        if ( motionData.Duration != 0 ) {
            m_pMotionAction.moveSpeed = motionData.xSpeed * ( 1 - distanceRadio * discresRadio);
            CSkillDebugLog.logTraceMsg( "位移ID : " + motionData.ID + " speed :" + m_pMotionAction.moveSpeed +
                    " 当前坐标 : " + "x: "+transformCmp.position.x + " y : " + transformCmp.position.y + " z : " + transformCmp.position.z );
        }

        if ( moveDir.length != 0 )
        // moveCmp.direction = new Point( moveDir.x / moveDir.length, moveDir.y / moveDir.length );
            m_pMotionAction.direction = new Point( moveDir.x / moveDir.length, moveDir.y / moveDir.length );
        else
        // moveCmp.direction = new Point( moveDir.x, moveDir.y );
            m_pMotionAction.direction = new Point( moveDir.x, moveDir.y );

//        CAssertUtils.assertTrue( m_pMotionAction.direction.length, "Can't submit a Motion with no direction." );
        if ( m_pMotionAction.direction.length == 0 )
            CSkillDebugLog.logErrorMsg( "Can't submit a Motion with no direction." );

        var pAnimation : IAnimation = m_owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( m_motionData ) {
            if ( pAnimation )
                pAnimation.setCharacterGravityAcc( -m_motionData.yDamping * 100.0 * 2.0 );
        }

        var pEventMediator : CEventMediator = m_owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( m_motionData && m_motionData.ySpeed != 0 ) {
            if ( pAnimation ) {
                pAnimation.emitWithVelocityXYZ( m_motionData.xSpeed * m_pMotionAction.direction.x * ( 1 - distanceRadio * discresRadio), m_motionData.ySpeed, m_motionData.xSpeed * m_pMotionAction.direction.y );//m_motionData.zSpeed );
                stateBoard.setValue( CCharacterStateBoard.ON_GROUND, false );
                if ( pEventMediator )
                    pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.STATE_VALUE_UPDATE, m_owner ) );
            }
        }
        else {
            moveCmp.addMotionAction( m_pMotionAction );
        }
    }

    private function resumeMovement() : void {
        var moveCmp : CMovement = movementCmp;
        if ( moveCmp && m_pMotionAction ) {
            moveCmp.removeMotionAction( m_pMotionAction );
        }

        //停止x，z方向速度
//        var pAnimation : IAnimation =m_owner.getComponentByClass( IAnimation, true ) as IAnimation;
//        if ( pAnimation ) {
//            pAnimation.modelDisplay.velocity.x = 0;
//            pAnimation.modelDisplay.velocity.z = 0;
//        }

        var pAnimation : IAnimation = m_owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation && m_motionData && !m_boUseInSkillEffect ) {
            pAnimation.resetCharacterGravityAcc();
        }

        if (_transform && _transform.z < 0 ) {
            Foundation.Log.logTraceMsg( "block now : z ->" + _transform.z + " motionID : " + (motionData != null ? motionData.ID : 0) );
            _transform.move( 0, 0, 0, false, true );
        }
//
    }

    final private function get spellerTransform() : ITransform {
        var masterComponet : CMasterCompomnent = m_owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        var masterTransform : ITransform;
        var speller : CGameObject;
        if ( masterComponet ) {
            speller = masterComponet.master;
            if ( speller )
                masterTransform = speller.getComponentByClass( ITransform, true ) as ITransform;
        }
        return masterTransform;
    }

    /** in fact ,the status of animation handle by battle stats component */
    private function handleAnimation() : void {
        //TODO change the status of the animation

    }

    private function resumeAnimation() : void {
        //TODO HANDLE ANMIMATION

    }

    final public function get motionData() : Motion {
        return m_motionData;
    }

    final private function get movementCmp() : CMovement {
        return m_owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    final private function get transformCmp() : ITransform {
        return m_owner.getComponentByClass( ITransform, true ) as ITransform;
    }

    final public function set motionData( mData : Motion ) : void {
        m_motionData = mData;
    }

    final public function get iDirectionX() : int {
        return m_iDirectionX;
    }

    final public function set iDirectionX( value : int ) : void {
        m_iDirectionX = value;
    }

    final private function get stateBoard() : CCharacterStateBoard {
        return m_owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final private function get _transform() : CKOFTransform {
        return m_owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    private var m_tickTime : Number = 0.0;
    private var m_motionData : Motion;
    private var m_owner : CGameObject;

    private var m_moveEndCallBack : Dictionary;
    private var m_isReady : Boolean;
    private var m_isMoving : Boolean;
    private var m_pMotionAction : CMotionAction;

    private var m_aliasTargetPosition : CVector3;
    private var m_iDirectionX : int;
    //使用在技能效果里面的话不能重置重力
    private var m_boUseInSkillEffect : Boolean;

    //回调来控制结束了
    private var m_boKnockUpFlyMotion : Boolean;

    private var m_fDistanceRadio : Number;


}
}

