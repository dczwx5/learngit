//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import QFLib.Framework.CObject;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.character.CCharacterTransform;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterLyingState;
import kof.game.character.state.CCharacterState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.scene.ISceneFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Map.CharacterMoveResponse;
import kof.message.Map.CharacterMoveResponse;
import kof.util.CAssertUtils;

/**
 * A game handling for character moving.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMovementHandler extends CGameSystemHandler {

    /** @private */
    private var m_directionSpeedFactor : Point;
    /** @private */
    private var m_fMoveSpeedFactor : Number;
    /** @private */
    private var m_pSceneFacade : ISceneFacade;
    /** @private */
    private var m_bSkyWalk : Boolean;
    /** @private */
    private var m_pPlayHandler : CPlayHandler;
    /** @private */
    private var m_bMoved : Boolean;
    /** @private */
    private var m_fOffsetX : Number;
    /** @private */
    private var m_fOffsetY : Number;
    /** @private */
    private var m_iTickIdx : uint;
    /** @private */
    private var m_thePreviousPos : CVector3;

    /** @private */
    private var m_theLastNavPos : CVector3;

    public static const EVT_MOVE_DIR_CHANGE : int = 0;
    public static const EVT_MOVE_START : int = 1;
    public static const EVT_MOVE_STOP : int = 2;
    public static const EVT_MOVE_SCCHEDULE : int = 3;
    public static const EVT_RESEET_DIRECTION : int = 4;

    /**
     * Creates a new CMovementHandler.
     */
    public function CMovementHandler() {
        super( CMovement, CCharacterTransform );
        m_directionSpeedFactor = new Point( 1.0, 1.0 );
        m_fMoveSpeedFactor = 1.0;
        m_iTickIdx = 0;
        m_thePreviousPos = new CVector3();
    }

    final public function get skyWalk() : Boolean {
        return m_bSkyWalk;
    }

    final public function set skyWalk( value : Boolean ) : void {
        m_bSkyWalk = value;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
            CAssertUtils.assertNotNull( networking, "INetworking required in CMovementHandler." );
            if ( networking ) {
                networking.bind( CharacterMoveResponse ).toHandler( onCharacterMoveMessageHandler );
            }
        }
        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
            CAssertUtils.assertNotNull( networking, "INetworking required in CMovementHandler." );
            if ( networking ) {
                networking.unbind( CharacterMoveResponse );
            }
        }

        return ret;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
        m_pSceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;

        var pGameSystem : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        CAssertUtils.assertNotNull( pGameSystem );
        m_pPlayHandler = pGameSystem.getBean( CPlayHandler ) as CPlayHandler;

        CAssertUtils.assertNotNull( m_pSceneFacade, "Required ISceneFacade interface in CMovementHandler." );
    }

    override protected function exitSystem( system : CAppSystem ) : void {
        super.exitSystem( system );

        m_pSceneFacade = null;
        m_pPlayHandler = null;
    }

    final private function isInputMovable( obj : CGameObject ) : Boolean {
        if ( !obj )
            return false;
        var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( !pStateBoard || (pStateBoard && pStateBoard.getValue( CCharacterStateBoard.MOVABLE )) )
            return true;
        return false;
    }

    protected function isOnTerrain( obj : CGameObject ) : Boolean {
        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation ) {
            return !pAnimation.modelDisplay.inAir;
        }
        return true;
    }

    protected function tickNavigation( delta : Number, obj : CGameObject ) : Boolean {
        var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var pNavigation : CNavigation = obj.getComponentByClass( CNavigation, true ) as CNavigation;
        var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;

        if ( null == pNavigation )
            return false;

        var bRunnable : Boolean = pNavigation.enabled;

        if ( pStateBoard && !pStateBoard.getValue( CCharacterStateBoard.MOVABLE ) )
            bRunnable = false;

        if ( !bRunnable ) {
            if ( pNavigation && !isNaN( pNavigation.m_fCurrentDistance ) ) {
                pNavigation.m_fCurrentDistance = NaN;
            }
            return false;
        }

        if ( pNavigation ) {
            if ( pNavigation.targetPoint ) {
                if ( pNavigation.isPathListDirty ) {
                    pNavigation.clearDirty();
                    // notify the navigation begin.
                    pNavigation.notifyBegin();
                }

                // 当前存在向目标点移动
                // 检测和计算当前点于目标点的方向和剩余距离
                if ( !isNaN( pNavigation.m_fCurrentDistance ) &&
                        pNavigation.m_fCurrentDistance == 0.0 ) {
                    pNavigation.m_fCurrentDistance = NaN;
                    pNavigation.notifyCheckPoint();

                    pNavigation.advancedNext();

                    if ( pNavigation.targetPoint ) { // need continue.
                        // NOOP.
                    } else { // no next point instead.
                        if ( pInput )
                            pInput.wheel = new Point();

                        pNavigation.clearPath();
                        pNavigation.notifyEnd();
                        CONFIG::debug{
                            var pNavigationDebug : CNavigationViewDebug = obj.getComponentByClass( CNavigationViewDebug, true ) as CNavigationViewDebug;
                            pNavigationDebug.clearPath();
                        }
                    }

                }

                if ( pNavigation.targetPoint && isNaN( pNavigation.m_fCurrentDistance ) ) {
                    var targetDirectionX : Number = pNavigation.targetPoint.x - obj.transform.x;
                    var targetDirectionY : Number = pNavigation.targetPoint.y - obj.transform.y;
                    pNavigation.m_fCurrentDistance = CMath.lengthVector2( pNavigation.targetPoint.x, pNavigation.targetPoint.y, obj.transform.x, obj.transform.y );

                    var fXYMax : Number = Math.max( Math.abs( targetDirectionX ), Math.abs( targetDirectionY ) );
                    targetDirectionX /= fXYMax;
                    targetDirectionY /= fXYMax;

                    CAssertUtils.assertFalse( isNaN( fXYMax ) );

                    if ( pInput )
                        pInput.wheel = new Point( targetDirectionX, targetDirectionY );
                }

                return true;
            }
        }

        return false;
    }

    /**
     * Motion actions execution.
     */
    protected function tickMotion( delta : Number, obj : CGameObject ) : void {
        var pCharacterTransform : CCharacterTransform = obj.getComponentByClass( CCharacterTransform, true ) as CCharacterTransform;

        var pMovement : CMovement = obj.getComponentByClass( CMovement, true ) as CMovement;
        if ( !pMovement || !pMovement.enabled || !pMovement.movable )
            return;

        var pActions : Vector.<CMotionAction> = pMovement.motionActions;
        if ( !pActions || !pActions.length )
            return;

        var bWalkable : Boolean = false;

        for each ( var pAction : CMotionAction in pActions ) {
            if ( pAction.direction.length > 0 ) {
                var offsetX : Number = pAction.direction.x * pAction.getOffsetByDelta( m_directionSpeedFactor.x * m_fMoveSpeedFactor * delta );
                var offsetY : Number = pAction.direction.y * pAction.getOffsetByDelta( m_directionSpeedFactor.y * m_fMoveSpeedFactor * delta );

                offsetX *= 1.0;
                offsetY *= 1.0;

                offsetX /= 1.0;
                offsetY /= 1.0;

                bWalkable = pCharacterTransform.move( offsetX, 0, offsetY, pMovement.collisionEnabled && !skyWalk, true );

                if ( !bWalkable ) {
                    // TODO: Any handling when non move.
                } else {
                    m_fOffsetX += offsetX;
                    m_fOffsetY += offsetY;
                }

                m_bMoved = m_bMoved || bWalkable;
                pMovement.boBlockInScene = !bWalkable;
            }
        }
    }

    /**
     * @inheritDoc
     */
    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        /* delta = 0.06666667; // for debug */

        // Reset the offset variables.
        var bValidated : Boolean = super.tickValidate( delta, obj );
        if ( !bValidated )
            return bValidated;

        var pMovement : CMovement = obj.getComponentByClass( CMovement, true ) as CMovement;
        var pCharacterTransform : CCharacterTransform = obj.getComponentByClass( CCharacterTransform, true ) as CCharacterTransform;
        var pNav : CNavigation = obj.getComponentByClass( CNavigation, true ) as CNavigation;
        var bAmendTo : Boolean = false;

        this.tickInterpolation( delta, obj );

        while ( true ) {
            m_bMoved = false;
            m_fOffsetX = m_fOffsetY = 0;

            var bNavTickUpdated : Boolean = this.tickNavigation( delta, obj );

            if ( bNavTickUpdated && bAmendTo ) {
                var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
                if ( pInput ) {
                    pMovement.direction = pInput.normalizeWheel;
                }
            }

            if ( pMovement && pMovement.enabled && pMovement.movable ) {
                if ( pMovement.m_bSpeedDirty || pMovement.m_bSpeedFactorDirty ) {
                    if ( pMovement.m_bSpeedDirty ) {
                        // 速度值改变
                    }
                    if ( pMovement.m_bSpeedFactorDirty ) {
                        // 速度倍率改变
                    }
                }

                if ( pMovement.direction.length > 0 ) { // 方向驱动移动
                    var offsetX : Number = pMovement.direction.x * pMovement.getOffsetByDelta( m_directionSpeedFactor.x * m_fMoveSpeedFactor * delta );
                    var offsetY : Number = pMovement.direction.y * pMovement.getOffsetByDelta( m_directionSpeedFactor.y * m_fMoveSpeedFactor * delta );

//                    offsetX *= 1.0;
//                    offsetY *= 1.0;
//
//                    offsetX /= 1.0;
//                    offsetY /= 1.0;

                    var movementDir : Point = pMovement.direction.clone();
                    var lastMovementDir : Point = pMovement.m_pLastDirection;

//                    Foundation.Log.logMsg( "(" + m_iTickIdx + ") CharacterMoving 3dx: " + pCharacterTransform.x + " 3dy: " + pCharacterTransform.z + " 3dz: " + pCharacterTransform.y );
                    m_thePreviousPos.setValueXYZ( pCharacterTransform.x, pCharacterTransform.y, pCharacterTransform.z );

                    // due to 2d/3d transformation error, it is better we try to use move-x-then-y method to avoid the collision problem
                    var bWalkable : Boolean = false;
                    if ( offsetX != 0.0 || offsetY != 0.0 ) {
                        if ( offsetX != 0.0 ) bWalkable = pCharacterTransform.move( offsetX, 0, 0, pMovement.collisionEnabled && !skyWalk, true );
                        if ( bWalkable ) pCharacterTransform.move( 0, 0, offsetY, pMovement.collisionEnabled && !skyWalk, true );
                        else if ( offsetY != 0.0 ) bWalkable = pCharacterTransform.move( 0, 0, offsetY, pMovement.collisionEnabled && !skyWalk, true );
//                        Foundation.Log.logMsg( "(" + m_iTickIdx + ") CharacterMoved [" + (bWalkable ? "SUCCESS" : "FAILED") + ": offsetX(" + offsetX + "), offsetZ(" + offsetY + "), iSlideFactor: " + iSlideFactor );
//                        Foundation.Log.logMsg( "(" + m_iTickIdx + ") CharacterMoved 3dx: " + pCharacterTransform.x + " 3dy: " + pCharacterTransform.z + " 3dz: " + pCharacterTransform.y );
                    }

                    if ( bWalkable ) {
                        pMovement.direction = movementDir; // 这里这是修正方向
                        pMovement.m_pLastDirection = lastMovementDir; // pMovement.direction被更新会级联更新到m_bLastDirection，所以这里复原到正确值
                        // NOTE: 由于开启了移动滑步的功能，以上offsetX和offsetY不一定是真正移动成功的偏移量，所以必需重新计算
                        offsetX = pCharacterTransform.x - m_thePreviousPos.x;
                        offsetY = pCharacterTransform.y - m_thePreviousPos.y;

                        m_fOffsetX += offsetX;
                        m_fOffsetY += offsetY;
                    }

                    m_bMoved = m_bMoved || bWalkable;
                    pMovement.boBlockInScene = !bWalkable;
                }

                // update dirty flag
                pMovement.m_bSpeedDirty = false;
                pMovement.m_bSpeedFactorDirty = false;
                pMovement.m_bDirectionDirty = false;

                if ( !pNav || !pNav.enabled || !bNavTickUpdated )
                    break;

                var bForceAmendTo : Boolean = false;
                if ( !m_bMoved ) {
                    // assume the target position is reached if the remaining distance is smaller then this frame's offset
                    if ( pNav.m_fCurrentDistance * pNav.m_fCurrentDistance < CMath.lengthSqrVector2( 0.0, 0.0, offsetX, offsetY ) ) {
                        bForceAmendTo = true;
                    }
                    else break;
                }

                // m_bMoved must be true
                if ( !isNaN( pNav.m_fCurrentDistance ) ) {
                    var fDistance : Number = pNav.m_fCurrentDistance;
                    pNav.m_fCurrentDistance -= Math.sqrt( m_fOffsetX * m_fOffsetX + m_fOffsetY * m_fOffsetY );

                    if ( pNav.m_fCurrentDistance >= 0.0 && bForceAmendTo == false )
                        break;
                    else {
                        bAmendTo = true; // 标识当前进入修正逻辑
//                            Foundation.Log.logMsg( "Move overhead: [A] " + fDistance + ", [C] " + pNav.m_fCurrentDistance );
//                            Foundation.Log.logMsg( "Move overhead: [CP] " + pNav.targetPoint + ", [NP] " + pNav.nextPoint );
                        // XXX: 该方向移动过头啦
                        // 1. 设置对象到目标点位置重新计算路线
                        // 2. 计算出超出部分的位移比例从而得出超出的delta值
                        // 3. 再次循环使用余出的delta进行路线计算
                        var fRedundantDistance : Number = 0.0 - pNav.m_fCurrentDistance;
                        var bMovedTo : Boolean = pCharacterTransform.moveTo( pNav.targetPoint.x, pCharacterTransform.z, pNav.targetPoint.y, pMovement.collisionEnabled && !skyWalk, true );
//                            Foundation.Log.logMsg( "(" + m_iTickIdx + ") %%%-- Move overhead: moveTo => " + pNav.targetPoint );
//                            CAssertUtils.assertTrue( bMovedTo );
                        var fRedundantDeltaRatio : Number = fRedundantDistance / ( fDistance + fRedundantDistance ); // 多余出的参与计算的delta
                        delta *= fRedundantDeltaRatio;
                        pNav.m_fCurrentDistance = 0; // reset to zero for next begining

//                            Foundation.Log.logMsg("Move overhead: [RD] " + fRedundantDistance + ", [RT] " + delta);
                        if ( !pNav.nextPoint ) {
//                                Foundation.Log.logMsg( "Move overhead: END %%%" );
                        }
                    }
                }
            } else {
                break;
            }
        }

        this.tickMotion( delta, obj );

        m_iTickIdx++;

        return false;
    }

    private function tickInterpolation( delta : Number, obj : CGameObject ) : void {
        var pMotionInterpolation : CMoveInterpolation = obj.getComponentByClass( CMoveInterpolation, true ) as CMoveInterpolation;
        if ( pMotionInterpolation )
            pMotionInterpolation.update( delta );
    }

    /**
     * @inheritDoc
     */
    override public function tickUpdate( delta : Number, obj : CGameObject ) : void {
        super.tickUpdate( delta, obj );

    }

    /** @private */
    private function onCharacterMoveMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : CharacterMoveResponse = message as CharacterMoveResponse;
        if ( msg ) {
            var obj : CGameObject;

            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.id );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.id );
            } else {
                // Unknown, ignore now.
                LOG.logWarningMsg( "Unknown type of CharacterMoveResponse: " + msg.type );
            }

            if( obj == null )
                    return;

            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id && obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received CharacterMoveResponse self by self!!!)" );
                }
            }

            if ( msg.eventType != 0 && msg.eventType != 1 && msg.eventType != 2 && msg.eventType != 3 )
                LOG.logWarningMsg( "Unknown eventType of CharacterMoveResponse: " + msg.eventType );

            if ( obj && obj.isRunning ) {
                var movement : CMovement = obj.getComponentByClass( CMovement, true ) as CMovement;
                var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
                var moveInterpolation : CMoveInterpolation = obj.getComponentByClass( CMoveInterpolation, true ) as CMoveInterpolation;
                var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
                var bInControl : Boolean;

                //在非可控状态下释放键盘类型只会重置方向
                if (  msg.eventType == 4 ) {
                    pInput.wheel = new Point( msg.dirX, msg.dirY );
                    pInput.makeWheelDirty();
                    return;
                }

                var pStateMachine : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
                bInControl = pStateBoard.getValue( CCharacterStateBoard.IN_CONTROL );
                if( !bInControl )
                        return;

                if ( pStateMachine ) {
                    if ( pStateMachine.actionFSM.currentState is CCharacterLyingState ) {
                        var bRet : Boolean;
                        bRet = pStateMachine.actionFSM.on( CCharacterStateMachine.STARTUP );
                        if ( bRet ) {
                            var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
                            if ( pAnimation )
                                pAnimation.playAnimation( CAnimationStateConstants.IDLE, true );
                        }
                    }
                }

                var levelMediator : CLevelMediator = obj.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
                if ( moveInterpolation && !levelMediator.isMainCity ) {
                    moveInterpolation.setLastSyncTime( msg );
                    return;
                }


                if ( !pInput ) {
                    LOG.logWarningMsg( "Character[" + msg.id + ":" + msg.type + "] doesn't contains a CCharacterInput, but it's message supported." );
                } else {
                    pInput.wheel = new Point( msg.dirX, msg.dirY );
                }

                var screenAxis : CVector3;
                var pDisplay : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;
                if ( !pDisplay ) {
                    LOG.logWarningMsg( "Character[" + msg.id + ":" + msg.type + "] doesn't contains a CCharacterDisplay, but it's message supported." );
                    screenAxis = new CVector3( msg.posX, msg.posY, msg.posH );
                } else {
                    screenAxis = pDisplay.modelDisplay.get2DPosition();
                }

                // 同步坐标校验
                // FIXME: 需要校验像素坐标和格子坐标是否同步？
                var offsetX : Number = msg.posX - screenAxis.x;
                var offsetY : Number = msg.posY - screenAxis.y;
                var bRelocate : Boolean = true;

                if ( msg.eventType == 3 ) { // 移动中如果没有太大的位置偏移为表现更加流畅暂时不做强制重定位
                    var fDeltaDetect : Number = 1 / 30 * m_fMoveSpeedFactor;
                    if ( offsetX <= movement.getOffsetByDelta( fDeltaDetect * m_directionSpeedFactor.x ) &&
                            offsetY <= movement.getOffsetByDelta( fDeltaDetect * m_directionSpeedFactor.y ) ) {
                        bRelocate = false;
                    }
                }

                if ( bRelocate ) {
                    if ( pDisplay && pDisplay.modelDisplay ) {
                        var v3DPos : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, msg.posX, msg.posY, msg.posH );
                        pDisplay.modelDisplay.moveTo( v3DPos.x, v3DPos.y, v3DPos.z, true, msg.posH == 0.0 );
                    }
                }
            }
        }
    }

}
}
