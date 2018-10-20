//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/22.
//----------------------------------------------------------------------
package kof.game.character.movement {

import QFLib.Foundation;
import QFLib.Framework.CObject;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.CKOFTransform;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skilleffect.CSkillCatchEffect;
import kof.game.character.state.CCharacterIdleState;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterRunState;
import kof.game.character.state.CCharacterState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameComponent;
import kof.message.Map.CharacterMoveResponse;

public class CMoveInterpolation extends CGameComponent implements IUpdatable {
    public function CMoveInterpolation() {
        super( "moveInterpolation" );
    }

    public function update( delta : Number ) : void {
        if ( movementComp && movementComp.movable )
            _updateDelayStopMove( delta );
//        _updateInterpolationMotion( delta );
    }

    private function _updateDelayStopMove( delta : Number ) : void {
        if ( !m_boNeedStopDelayMove )
            return;

        m_fLastSyncTime -= delta;
        if ( m_fLastSyncTime <= 0.0 ) {
            _stopMove();
            m_boNeedStopDelayMove = false;
            m_fLastSyncTime = NaN;
        }
    }

    private function _updateInterpolationMotion( delta : Number ) : void {
        if ( !m_boNeedInterpolateMove )
            return;

        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( pDisplay && pDisplay.modelDisplay && !m_boInRunningMotionInterpolation ) {
            var msg : CharacterMoveResponse = m_theLastMoveResponse;
            var v3DPos : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, msg.posX, msg.posY, msg.posH );
            var pTransform : CKOFTransform = theTransform;
            if ( null == m_theInterpolateMotion ) {
                m_theInterpolateMotion = new CMotionAction();
            }

            var dir : Point;
            var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            pStateBoard.setValue( CCharacterStateBoard.MOVABLE, true );
            dir = new Point( v3DPos.x - pTransform.position.x, v3DPos.z - pTransform.position.y );
            var maxXY : Number = Math.max( CMath.abs( dir.x ), CMath.abs( dir.y ) );
            pInput.wheel = new Point( dir.x / maxXY, dir.y / maxXY )
            m_theInterpolateMotion.direction = new Point( dir.x / dir.length, dir.y / dir.length );
            m_theInterpolateMotion.moveSpeedFactor = 1.0;
            m_theInterpolateMotion.moveSpeed = movementComp.moveSpeed;
            m_fInterpolateTime = CMath.abs( v3DPos.x - pTransform.position.x ) / (m_theInterpolateMotion.moveSpeed * m_theInterpolateMotion.moveSpeedFactor);
            movementComp.addMotionAction( m_theInterpolateMotion );
            movementComp.movable = true;
            m_boInRunningMotionInterpolation = true;
        }

        if ( m_boInRunningMotionInterpolation && m_theInterpolateMotion ) {
            m_fInterpolateTime -= delta;
            if ( m_fInterpolateTime <= 0 ) {
                _releaseInterpolationMotion();
            }
        }
    }

    private function _releaseInterpolationMotion() : void {
        movementComp.removeMotionAction( m_theInterpolateMotion );
        m_boReachLastSyncMotion = true;
        m_boInRunningMotionInterpolation = false;
    }

    override public function dispose() : void {

    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onExit() : void {

    }

    public function setLastSyncTime( msg : CharacterMoveResponse ) : void {
        m_theLastMoveResponse = msg;
        m_nLastMoveType = msg.eventType;
        _handleNormalMove( msg );
    }

    public function _handleNormalMove( msg : CharacterMoveResponse ) : void {



        if ( !pInput ) {
            Foundation.Log.logWarningMsg( "Character[" + msg.id + ":" + msg.type + "] doesn't contains a CCharacterInput, but it's message supported." );
        } else {
            m_lastDirX = msg.dirX;
            m_lastDirY = msg.dirY;
        }

        var screenAxis : CVector3;
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( !pDisplay ) {
            Foundation.Log.logWarningMsg( "Character[" + msg.id + ":" + msg.type + "] doesn't contains a CCharacterDisplay, but it's message supported." );
            screenAxis = new CVector3( msg.posX, msg.posY, msg.posH );
        } else {
            screenAxis = pDisplay.modelDisplay.get2DPosition();
        }

        // 同步坐标校验
        // FIXME: 需要校验像素坐标和格子坐标是否同步？
        var offsetX : Number = msg.posX - screenAxis.x;
        var offsetY : Number = msg.posY - screenAxis.y;

        switch ( msg.eventType ) {
            case CMovementHandler.EVT_MOVE_STOP :
            case CMovementHandler.EVT_MOVE_START:
                setDelayFlag( false );
                break;
            case CMovementHandler.EVT_MOVE_DIR_CHANGE:
            case CMovementHandler.EVT_MOVE_SCCHEDULE:
                if ( msg.dirX != 0 || msg.dirY != 0 ) {
                    setDelayFlag( true );
                } else {
                    setDelayFlag( false );
                }
                break;
            default:
                setDelayFlag( false );
        }

        var bRelocate : Boolean = true;
        {
            var fDeltaDetect : Number = 1 / 30 * 2;
            if ( CMath.abs( offsetX ) >= movementComp.getOffsetByDelta( fDeltaDetect * 1.0 ) ||
                    CMath.abs( offsetY ) >= movementComp.getOffsetByDelta( fDeltaDetect * 1.0 ) ) {
                m_boNeedInterpolateMove = true;
                m_boInRunningMotionInterpolation = false;
            } else {
                bRelocate = false;
                _releaseInterpolationMotion();
                m_boNeedInterpolateMove = false;
            }
        }

        pInput.wheel = new Point( msg.dirX, msg.dirY );
        _syncDirectionImediately();
        movementComp.movable = true;

        if ( bRelocate ) {
            if ( pDisplay && pDisplay.modelDisplay ) {
                var v3DPos : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, msg.posX, msg.posY, msg.posH );
                pDisplay.modelDisplay.moveTo( v3DPos.x, v3DPos.y, v3DPos.z, true, msg.posH == 0.0 );
            }
        }
    }

    public function setDelayFlag( flag : Boolean ) : void {
        m_boNeedStopDelayMove = flag;
        m_fLastSyncTime = DELAY_STOP_INTERVAL;
    }

    private function _syncDirectionImediately() : void {
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( pInput.normalizeWheel.length > 0 ) {
            if ( pStateBoard ) {
                var displayDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                displayDir.setTo( pInput.normalizeWheel.x < 0 ? -1 : 1, 0 );
                if ( pDisplay ) {
                    if ( displayDir.x != 0 ) {
                        pDisplay.direction = displayDir.x > 0 ? 1 : -1;
                    }
                }
            }
        }
    }

    private function _removeCurrentInterpolationMotion() : void {
        if ( m_theInterpolateMotion )
            movementComp.removeMotionAction( m_theInterpolateMotion );
        m_theInterpolateMotion = null;
    }

    private function _stopMove() : void {
        var currentState : CCharacterState ;
        var boInMovingState : Boolean;
        currentState = pStateMechine.actionFSM.currentState as CCharacterState;
        boInMovingState = currentState is CCharacterRunState;

        if( boInMovingState )
            movementComp.movable = false;
    }

    final private function get pStateMechine() : CCharacterStateMachine{
        return owner.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
    }

    final private function get theTransform() : CKOFTransform {
        return owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    private function get movementComp() : CMovement {
        return owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    private function get pInput() : CCharacterInput {
        return owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
    }

    private function get pSkillCaster() : CSkillCaster {
        return owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    private function get pStateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    private var m_fLastSyncTime : Number = 0.0;
    private var m_nLastMoveType : int = 0;
    private var m_theLastMoveResponse : CharacterMoveResponse;
    private var m_boNeedStopDelayMove : Boolean;
    private var m_boNeedInterpolateMove : Boolean;
    private var m_theInterpolateMotion : CMotionAction;
    private var m_fInterpolateTime : Number;
    private var m_boReachLastSyncMotion : Boolean;
    private var m_boInRunningMotionInterpolation : Boolean;
    private var m_lastDirX : Number = 0;
    private var m_lastDirY : Number = 0;
    private const DELAY_STOP_INTERVAL : Number = 0.4;

}
}
