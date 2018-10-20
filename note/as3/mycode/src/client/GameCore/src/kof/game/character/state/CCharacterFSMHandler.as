//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.geom.Point;

import kof.framework.fsm.CFiniteStateMachine;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.CSkillList;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.ILastUpdatable;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skillchain.CSkillKeyMgr;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CBaseStrategy;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.movement.CMovement;
import kof.game.character.movement.CNavigation;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.info.CSkillInputRequest;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;

/**
 * 角色状态机逻辑控制
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterFSMHandler extends CGameSystemHandler {

    private var m_pFightHandler : CFightHandler;
    private var m_pPlayHandler : CPlayHandler;

    /** Creates a new CCharacterFSMHandler */
    public function CCharacterFSMHandler() {
        super( CBaseStateMachine, CCharacterInput );
    }

    public function get fightHandler() : CFightHandler {
        if ( !m_pFightHandler ) {
            m_pFightHandler = system.getBean( CFightHandler );
        }
        return m_pFightHandler;
    }

    public function get playHandler() : CPlayHandler {
        if ( !m_pPlayHandler )
            m_pPlayHandler = system.getBean( CPlayHandler );
        return m_pPlayHandler;
    }

    /** @inheritDoc */
    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var bValidated : Boolean = super.tickValidate( delta, obj );
        if ( bValidated ) {
            var pMovement : CMovement = obj.getComponentByClass( CMovement, true ) as CMovement;
            var pStateMachine : CBaseStateMachine = obj.getComponentByClass( CBaseStateMachine, true ) as CBaseStateMachine;
            var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
            var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            var pNavigation : CNavigation = obj.getComponentByClass( CNavigation, true ) as CNavigation;

            if ( !pInput || !pStateMachine )
                return false;

            var bRunnable : Boolean = false;

            if ( !pStateBoard || (pStateBoard && pStateBoard.getValue( CCharacterStateBoard.MOVABLE ) ) )
                bRunnable = true;

            var iFSMRet : int;
            var bTemp : Boolean = true;
            var iMovingStatus : int = -1; // -1, 0, 1, 2
            var pCurrentState : CCharacterState = pStateMachine.actionFSM.currentState as CCharacterState;
            var bSyncForced : Boolean = pCurrentState && pCurrentState.dirSync;


            var pEventMediator : CEventMediator = obj.getComponentByClass( CEventMediator, true ) as CEventMediator;
            if ( bRunnable && !CCharacterDataDescriptor.isMissile( obj.data ) ) {
//            LOG.logMsg( "Wheel dir: " + pInput.wheel.x + ", " + pInput.wheel.y );

                if ( pInput.normalizeWheel.length ) {
                    if ( pStateBoard && pStateBoard.getValue( CCharacterStateBoard.DIRECTION_PERMIT ) && pInput.normalizeWheel.x != 0 ) {
                        var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
//                        dir.setTo( pInput.normalizeWheel.x, pInput.normalizeWheel.y );
                        dir.setTo( pInput.normalizeWheel.x < 0 ? -1 : 1, 0 );
                    }

                    iFSMRet = pStateMachine.actionFSM.on( CCharacterActionStateConstants.EVENT_RUN );

                    bTemp = bTemp && ( iFSMRet == CFiniteStateMachine.Result.SUCCEEDED || iFSMRet == CFiniteStateMachine.Result.NO_TRANSITION );

                    if ( bTemp )
                        iMovingStatus = 1;

                    bTemp = bTemp && (!pStateBoard || (pStateBoard && pStateBoard.getValue( CCharacterStateBoard.MOVABLE )));

                    if ( bTemp || pInput.isWheelDirty ) {
                        if ( pMovement ) {
                            pMovement.direction = pInput.normalizeWheel;
                        }
                    }

                    if ( pStateBoard && pStateBoard.getValue( CCharacterStateBoard.MOVABLE ) && bSyncForced ) {
                        var fightTriggel : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                        fightTriggel.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_JUMP, null ) );
//                        iMovingStatus = 4;
                    }
                } else {
                    iFSMRet = pStateMachine.actionFSM.on( CCharacterActionStateConstants.EVENT_STOP );

                    if ( iFSMRet == CFiniteStateMachine.Result.SUCCEEDED ) {
                        iMovingStatus = 2;

                        if ( pMovement ) {
                            pMovement.direction = new Point( 0, 0 );
                        }
                    }

                }

                if ( iMovingStatus == -1 ) {
                    if ( pInput.isWheelDirty && (!pStateBoard || (pStateBoard && pStateBoard.getValue( CCharacterStateBoard.MOVING ))) ) {
                        iMovingStatus = 0;
                    }

//                    if ( pInput.isWheelDirty && bSyncForced ) {
//                        iMovingStatus = 4;
//                    }
                }


                if ( iMovingStatus != -1 ) {
                    if ( pEventMediator ) {
                        switch ( iMovingStatus ) {
                            case 0:
//                        Foundation.Log.logMsg( "direction changed." );
                                pEventMediator.dispatchEvent( new Event( CCharacterEvent.DIRECTION_CHANGED, false, false ) );
                                break;
                            case 1:
//                        Foundation.Log.logMsg( "Start moved." );
                                pEventMediator.dispatchEvent( new Event( CCharacterEvent.START_MOVE, false, false ) );
                                break;
                            case 2:
//                        Foundation.Log.logMsg( "Stop moved." );
                                pEventMediator.dispatchEvent( new Event( CCharacterEvent.STOP_MOVE, false, false ) );
                                break;
                            case 4:
                            {
                                fightTriggel = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                                fightTriggel.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_JUMP, null ) );
                                break;
                            }

                        }
                    }
                }

                pInput.clearWheelDirty();
            }

            if ( !bRunnable && pInput.isWheelDirty ) {
                if ( pEventMediator && pInput.normalizeWheel.length == 0 ) {
                    pEventMediator.dispatchEvent( new Event( CCharacterEvent.FORCE_RESET_DIRECTEION, false, false ) );
                    pInput.clearWheelDirty();
                }
            }
        }

        this._tickActionFsm( delta, obj );
        this._tickStateBoard( delta, obj );

        this._tickNetworkInput( delta, obj );
        this.tickActionInput( delta, obj );
        this.tickSkillInput( delta, obj );

        return bValidated;
    }

    private function tickSkillInput( delta : Number, obj : CGameObject ) : void {
        var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( !pInput )
            return;

//        var pPlayHandler : CPlayHandler = this.playHandler;
//        if ( !pPlayHandler || !pPlayHandler.enabled )
//            return;

        var pFightHandler : CFightHandler = this.fightHandler;
        if ( !pFightHandler || !pFightHandler.enabled ) {
            pInput.truncateSkillRequests();
            return;
        }

        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation && pAnimation.isFrameFrozen )
            return;

        var pCharacterP : ICharacterProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        var pFacadeMediator : CFacadeMediator = obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        var fightTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var skillList : CSkillList = obj.getComponentByClass( CSkillList, true ) as CSkillList;
        var pSimulateCaster : CSimulateSkillCaster = obj.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;

        var pUniqueSkillIndexes : Vector.<CSkillInputRequest> = pInput.getUniqueSkillIndexList();

        if ( pUniqueSkillIndexes && pUniqueSkillIndexes.length ) {
            if ( pFacadeMediator ) {

                var pInputRequest : CSkillInputRequest = pUniqueSkillIndexes[ 0 ];
                var keyCode : int = pInputRequest.skillIndex;
//                var keyCode : int = pUniqueSkillIndexes[ 0 ];

                if ( fightTrigger ) {
                    //this step may clear the skillIndexPool
                    fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.CONTINUE_KEY_DOWN, null, [ keyCode ] ) );
                }

                if ( pCharacterP ) {
                    CSkillKeyMgr.instance.registSkillKey( pCharacterP.profession, skillList.getSkillIDByIndex( keyCode ), keyCode );// pUniqueSkillIndexes[ 0 ] ), keyCode );
                }

                pUniqueSkillIndexes = pInput.getUniqueSkillIndexList();

                if ( pUniqueSkillIndexes && pUniqueSkillIndexes.length ) {
                    pInputRequest = pUniqueSkillIndexes[ 0 ];
                    if ( pSimulateCaster )
                        pSimulateCaster.ignoreConditions = pInputRequest.args;

                    pFacadeMediator.attackWithSkillIndex( pInputRequest.skillIndex );//pUniqueSkillIndexes[ 0 ] ); // 目前不支持同时释放多个技能(应该是最后一次有效)
                }
            }
        }

        pInput.truncateSkillRequests();

        //skill key up
        var pUniqueSkillUpIndexes : Vector.<CSkillInputRequest> = pInput.getUniqueSkillUpIndexList();
          if ( pUniqueSkillUpIndexes && pUniqueSkillUpIndexes.length ) {
            if ( pFacadeMediator ) {

                var pInputReq : CSkillInputRequest = pUniqueSkillUpIndexes[ 0 ];
                var kCode : int = pInputReq.skillIndex;

                if ( fightTrigger ) {
                    fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.CONTINUE_KEY_UP, null, [ kCode ] ) );
                }
            }
          }

        pInput.truncateSkillUpRequests();
    }

    protected function tickActionInput( delta : Number, obj : CGameObject ) : void {
        var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( !pInput )
            return;

//        var pPlayHandler : CPlayHandler = this.playHandler;
//        if ( !pPlayHandler || !pPlayHandler.enabled )
//            return;

        var pFightHandler : CFightHandler = this.fightHandler;
        if ( !pFightHandler || !pFightHandler.enabled ) {
            pInput.truncateActionRequests();
            return;
        }

        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation && pAnimation.isFrameFrozen )
            return;

        var calls : Vector.<Object> = pInput.getUniqueActionCalls();
        if ( calls ) {
            for each ( var pEntry : Object in calls ) {
                var pCallback : Function = pEntry.callback as Function;
                if ( null != pCallback ) {
                    pCallback.apply( null, pEntry.hasOwnProperty( 'args' ) ? pEntry.args : [] );
                }

            }
        }
        pInput.truncateActionRequests();
    }

    protected function _tickActionFsm( delta : Number, obj : CGameObject ) : void {
        var pStateMachine : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( pStateMachine ) {
            if ( pStateMachine.actionFSM.currentState is IUpdatable ) {
                IUpdatable( pStateMachine.actionFSM.currentState ).update( delta );
            }
        }
    }

    protected function _tickNetworkInput( delta : Number, obj : CGameObject ) : void {
        var pNetworkInput : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
        if ( !pNetworkInput ) return;
        var pFightHandler : CFightHandler = this.fightHandler;
        if ( !pFightHandler || !pFightHandler.enabled ) {
            pNetworkInput.clearStrategyQueue();
            return;
        }

        var strategyList : Vector.<CBaseStrategy> = pNetworkInput.getStrategyQueueList();
        if ( strategyList ) {
            for each( var pStrategy : CBaseStrategy in strategyList ) {
                if ( !pStrategy )
                    continue;

                pStrategy.takeAction();
                pNetworkInput.delResponseStrategy( pStrategy )
            }
        }
    }

    /** @inheritDoc */
    override public function tickUpdate( delta : Number, obj : CGameObject ) : void {
        this._tickStateBoard( delta, obj );
        _lastTickActionFSM( delta, obj );
    }

    private function _lastTickActionFSM( delta : Number, obj : CGameObject ) : void {
        var pStateMachine : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( pStateMachine ) {
            if ( pStateMachine.actionFSM.currentState is ILastUpdatable ) {
                ILastUpdatable( pStateMachine.actionFSM.currentState ).lastUpdate( delta );
            }
        }
    }

    protected function _tickStateBoard( delta : Number, obj : CGameObject ) : void {
        var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        if ( pStateBoard ) {
            pStateBoard.clearDirty( CCharacterStateBoard.MOVABLE );

            if ( pStateBoard.m_bDirty ) {
                pStateBoard.m_bDirty = false;

                var pEventMediator : CEventMediator = obj.getComponentByClass( CEventMediator, true ) as CEventMediator;
                if ( pEventMediator ) {
                    pEventMediator.dispatchEvent( new Event( CCharacterEvent.STATE_VALUE_UPDATE ) );
                }

                pStateBoard.clearAllDirty();
            }
        }
    }

}
}
