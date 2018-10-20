//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/3.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.CKOFTransform;
import kof.game.character.animation.CBaseAnimationDisplay;

import kof.game.character.fight.CTargetCriteriaComponet;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.movement.CMotionAction;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameObject;
import kof.table.Motion;
import kof.table.SkillRush;
import kof.table.SkillRush.ERUSHTYPE;
import kof.util.CAssertUtils;

public class CSkillRushEffect extends CAbstractSkillEffect implements IUpdatable {
    public function CSkillRushEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        _releaseMotion();
        m_theMotionDuration = NaN;
        super.dispose();
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_boEndRush ) return;

        if ( !isNaN( m_theMotionDuration ) ) {
            m_theMotionDuration -= delta;

            if ( m_theMotionDuration <= 0.0 )
                _releaseMotion();
        }
        if ( m_boRushToTarget ) return;

        if ( !m_theRushTargets || m_theRushTargets.length == 0 )
            m_theRushTargets = m_pCriterialComp.getTargetByCollision( hitEventSignal, m_theRushData.TargetFilter );

        if ( !m_theInitialTarget && m_theRushTargets && m_theRushTargets.length != 0 ) {
            var targetIndex : int = 0;
            m_theInitialTarget = m_theRushTargets[ targetIndex ];
        }

        if ( m_theInitialTarget )
            _doRushToTarget();

    }

    override public function initData( ... arg ) : void {
        super.initData( null );
        m_theRushData = CSkillCaster.skillDB.getSkillRushEffectByID( effectID );
        m_theDefaultMotion = CSkillCaster.skillDB.getMotionDataByID( m_theRushData.DefaultMotionID );
        m_pCriterialComp = owner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
        m_effectDuarationFrame = m_theRushData.Duration - int( ( m_effectStartFrame ) / CSkillDataBase.TIME_IN_ONEFRAME );
    }

    override public function doEnd() : void {
        super.doEnd();
        if ( m_boRushToTarget )
            return;

        var motionID : int;
        motionID = m_theRushData.DefaultMotionID;
        if ( motionID <= 0 )
            return;

        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( pSkillCaster )
            pSkillCaster.castMotionEffect( motionID );

        _releaseMotion();
    }

    private function _doRushToTarget() : void {
        m_boRushToTarget = true;
        var target : CGameObject = m_theInitialTarget;
        if ( target ) {
            var pTargetTransform : CKOFTransform = target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            var pTargetDirection : Point;
            var pTargetStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            pTargetDirection = pTargetStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;
            var targetPosition : CVector3;
            var heightOffset : Number;
            heightOffset = pTargetTransform.position.z + m_theRushData.OffsetY;
            var stateDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;
            targetPosition = new CVector3( pTargetTransform.position.x + m_theRushData.OffsetX * pTargetDirection.x,
                    pTargetTransform.position.y + m_theRushData.OffsetZ, heightOffset < 0 ? 0 : heightOffset );

            if ( !targetPosition || isNaN( targetPosition.x ) || isNaN( targetPosition.y ) ) {
                CSkillDebugLog.logTraceMsg( "Rush Target Position is not exist" )
                return;
            }

            var dir : Point;
            dir = new Point( targetPosition.x - pTransform.position.x, targetPosition.y - pTransform.position.y );

            stateDir.x = pTransform.x > targetPosition.x ? -1 : 1;

            this._doRushMotionToTarget( targetPosition, dir );
        }
    }

    private function _doRushMotionToTarget( position : CVector3, dir : Point ) : void {
        var type : int = m_theRushData.Type;
        var moveDir : Point = dir;
        switch ( type ) {
            case ERUSHTYPE.E_LINE:
                _moveIgnoreHeightByTime( position, moveDir );
                break;
            case ERUSHTYPE.E_PHYSIC:
                _moveToHeightByTime( position, moveDir );
                break;
            case ERUSHTYPE.E_TIME:
                _moveToHeightDirectlyByTime( position, moveDir );
                break;
        }

//        var boJump : Boolean = m_theRushData.Height > 0;
//        if ( !boJump )
//            _moveTargetPosOnGround( position );
//        else if ( boJump )
//            _jumpToTargetInTime( position );
//                _jumpToTarget( position );
    }

    private function _releaseMotion() : void {
        m_boEndRush = true;
        m_theMotionDuration = NaN;
        if ( pMovment && m_theMotionAction ) {
            pMovment.removeMotionAction( m_theMotionAction );
        }
        if ( pAnimation )
            pAnimation.resetCharacterGravityAcc();

        m_theMotionAction = null;
    }

    private function _moveToHeightByTime( targetPosition : CVector3, dir : Point ) : void {
        var xSpeed : Number;
        var moveTime : Number = m_theRushData.RushTime * CSkillDataBase.TIME_IN_ONEFRAME;
        var rushHeight : Number = m_theRushData.Height
        var deltaHeight : Number = -pTransform.position.z + targetPosition.z;
        var bDirectly : Boolean;
        xSpeed = ( -pTransform.position.x + targetPosition.x ) / moveTime;

        var xVel : Number;
        var yVel : Number;
        var zVel : Number;
        var fGravity : Number;
        var fCurrentHeight : Number;
        var fActualJumpHeight : Number;
        fCurrentHeight = pTransform.position.z;
        bDirectly = fCurrentHeight > rushHeight;

        if ( !bDirectly ) {
            if ( fCurrentHeight > 0 ) {
                fActualJumpHeight = rushHeight - fCurrentHeight;
                var divideHeight : Number = CMath.sqrt( rushHeight / fActualJumpHeight );
                //the Time of moving from current position to top;
                var t1 : Number = moveTime / ( 1 + divideHeight );
                //the time of moving from top to the target
                var t0 : Number = moveTime - t1;
                fGravity = -2 * rushHeight / ( t0 * t0 );
                yVel = -fGravity * t1;

            } else {
                fActualJumpHeight = rushHeight - fCurrentHeight;
                fGravity = -8 * CMath.abs( fActualJumpHeight ) / ( moveTime * moveTime );
                yVel = -fGravity * moveTime / 2;
            }
        } else {
            fActualJumpHeight = fCurrentHeight;
            fGravity = -2 * fActualJumpHeight / ( moveTime * moveTime );
            yVel = 0.0;
        }

        xVel = xSpeed;
        zVel = (-pTransform.position.y + targetPosition.y) / moveTime;

        if ( pAnimation ) {
            pAnimation.setCharacterGravityAcc( fGravity );
            pAnimation.emitWithVelocityXYZ( xVel, yVel, zVel );
        }
    }

    private function _moveToHeightDirectlyByTime( targetPosition : CVector3, dir : Point ) : void {
        var xSpeed : Number;
        var moveTime : Number = m_theRushData.RushTime * CSkillDataBase.TIME_IN_ONEFRAME;
        var deltaHeight : Number = -pTransform.position.z + targetPosition.z;
        xSpeed = ( -pTransform.position.x + targetPosition.x ) / moveTime;

        var xVel : Number;
        var yVel : Number;
        var zVel : Number;
        var fActualJumpHeight : Number;
        fActualJumpHeight = deltaHeight;
        yVel = fActualJumpHeight / moveTime;
        xVel = xSpeed;
        zVel = (-pTransform.position.y + targetPosition.y) / moveTime;

        if ( pAnimation ) {
            if( yVel != 0.0 )
                pAnimation.setCharacterGravityAcc( 0 );

            pAnimation.emitWithVelocityXYZ( xVel, yVel, zVel );
        }
    }

    private function _addOnGroundMotionWithData( moveDir : Point, speed : Number ) : void {
        var motionAction : CMotionAction;
        motionAction = new CMotionAction();
        motionAction.moveSpeedFactor = 1.0;

        if ( moveDir.length != 0 )
            motionAction.direction = new Point( moveDir.x / moveDir.length, moveDir.y / moveDir.length );
        else
            motionAction.direction = new Point( moveDir.x, moveDir.y );

        motionAction.moveSpeed = speed;
        m_theMotionAction = motionAction;
        pMovment.addMotionAction( m_theMotionAction );
    }

    private function _moveIgnoreHeightByTime( tPos : CVector3, dir : Point ) : void {
        var moveDir : Point;
        moveDir = dir;
        var deltaHeight : Number = -pTransform.position.z + tPos.z;
        var bOnGround : Boolean = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
        var motionTime : Number = m_theRushData.RushTime * CSkillDataBase.TIME_IN_ONEFRAME;
        var dirX : Number = moveDir.length != 0 ? moveDir.x / moveDir.length : moveDir.x;
        var xSpeed : Number = m_theRushData.xSpeed;
        if( pTransform.position.z < 0.0 )
                CSkillDebugLog.logTraceMsg("你妹的  你特喵跑到地底了！还冲锋个毛线");

        if ( !bOnGround || (deltaHeight > CMath.BIG_EPSILON && pTransform.position.z >= 0.0 ) ) {
            var vY : Number;
            var vZ : Number;
            var fGravity : Number;

            if ( pAnimation ) {
                var offset : CVector3 = new CVector3( dir.x, deltaHeight, dir.y );
                offset.normalize();
                xSpeed = m_theRushData.xSpeed * offset.x;
                vY = m_theRushData.xSpeed * offset.y;
                vZ = m_theRushData.xSpeed * offset.z;
                fGravity = -200.0 * m_theRushData.yDamping;
                pAnimation.setCharacterGravityAcc( fGravity );

                pAnimation.emitWithVelocityXYZ( xSpeed, vY, vZ );
            }
        } else if ( bOnGround ) {
            var moveSpeed : Number = m_theRushData.xSpeed / CMath.abs( dirX );
            m_theMotionDuration = motionTime;
            _addOnGroundMotionWithData( moveDir, moveSpeed );
        }
    }

    private function _moveTargetPosOnGround( tPos : CVector3 ) : void {
        var dir : Point;
        var motionAction : CMotionAction;
        var isLineMove : Boolean = this.isLineMove;
        if ( !tPos || isNaN( tPos.x ) || isNaN( tPos.y ) ) return;

        motionAction = new CMotionAction();
        motionAction.moveSpeedFactor = 1.0;
        dir = new Point( tPos.x - pTransform.position.x, tPos.y - pTransform.position.y );

        CAssertUtils.assertTrue( dir.length, " Can not submit moveAction without direction " );
        if ( dir.length != 0 )
            motionAction.direction = new Point( dir.x / dir.length, dir.y / dir.length );
        else
            motionAction.direction = new Point( dir.x, dir.y );

        motionAction.moveSpeed = m_theRushData.xSpeed / CMath.abs( motionAction.direction.x );
        m_theMotionDuration = m_theRushData.RushTime * CSkillDataBase.TIME_IN_ONEFRAME;//CMath.abs( tPos.x - pTransform.x ) / m_theRushData.xSpeed;
        var deltaHeight : Number = -pTransform.position.z + tPos.z;

        var boOnground : Boolean = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
        var vZ : Number = (-pTransform.position.y + tPos.y) / m_theMotionDuration;
        var vY : Number;
        vY = deltaHeight / m_theMotionDuration;
        if ( isLineMove ) {
            pAnimation.setCharacterGravityAcc( 0 );
        }
        if ( !boOnground || deltaHeight != 0 ) {
            var landTime : Number = CMath.abs( tPos.x - pTransform.x ) / m_theRushData.xSpeed;
            if ( isLineMove )
                vY = deltaHeight / landTime;
            else
                vY = (deltaHeight > 0 ? 1 : -1 ) * 9.8 * 200 * landTime;
            vZ = (-pTransform.position.y + tPos.y) / landTime;
            pAnimation.emitWithVelocityXYZ( m_theRushData.xSpeed * motionAction.direction.x, vY, vZ );
        } else if ( boOnground ) {
            m_theMotionAction = motionAction;
            pMovment.addMotionAction( m_theMotionAction );
        }
    }

    private function _jumpToTarget( tPos : CVector3 ) : void {
        var totalReachTime : Number;
        var iDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;
        totalReachTime = CMath.abs( tPos.x - pTransform.position.x ) / m_theRushData.xSpeed;
        var height : Number = m_theRushData.Height;
        var vY : Number;
        var vZ : Number;

        if ( totalReachTime > 0 )
            vY = 9.8 * 200 * totalReachTime;

        vZ = (tPos.y - pTransform.position.y) / totalReachTime;

        if ( pAnimation )
            pAnimation.emitWithVelocityXYZ( m_theRushData.xSpeed * iDir.x, vY, vZ );
    }

    private function _jumpToTargetInTime( tPos : CVector3 ) : void {
        var landTime : Number = m_theRushData.RushTime * CSkillDataBase.TIME_IN_ONEFRAME;
        var iDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;
        var vY : Number = landTime * 9.8 * 200 * landTime / 2;
        var vZ : Number = ( tPos.y - pTransform.position.y ) / landTime;
        if ( pAnimation )
            pAnimation.emitWithVelocityXYZ( m_theRushData.xSpeed * iDir.x, vY, vZ );
    }

    final private function get isLineMove() : Boolean {
        return m_theRushData.Type == ERUSHTYPE.E_LINE;
    }

    final private function get isPhysicMove() : Boolean {
        return m_theRushData.Type == ERUSHTYPE.E_PHYSIC;
    }

    final private function get isTimeMove() : Boolean {
        return m_theRushData.Type == ERUSHTYPE.E_TIME;
    }

    final private function get pAnimation() : CBaseAnimationDisplay {
        return owner.getComponentByClass( CBaseAnimationDisplay, false ) as CBaseAnimationDisplay;
    }

    final private function get pMovment() : CMovement {
        return owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    final private function get pTransform() : CKOFTransform {
        return owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    final private function get pStateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    private var m_pCriterialComp : CTargetCriteriaComponet;
    private var m_theRushTargets : Array;
    private var m_theRushData : SkillRush;
    private var m_theInitialTarget : CGameObject;
    private var m_theDefaultMotion : Motion;
    private var m_boRushToTarget : Boolean;
    private var m_theMotionAction : CMotionAction;
    private var m_theMotionDuration : Number;
    private var m_boEndRush : Boolean;
}
}
