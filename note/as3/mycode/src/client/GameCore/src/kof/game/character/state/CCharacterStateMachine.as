//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;
import QFLib.Foundation.free;
import QFLib.Framework.CCharacter;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.framework.fsm.CFiniteStateMachine;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fx.CFXMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CSubscribeBehaviour;

/**
 * 游戏状态组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterStateMachine extends CBaseStateMachine implements IUpdatable {

    static public const NONE : String = "none";
    static public const STARTUP : String = "startup";

    /** @private */
    private var m_pBaseFsm : CFiniteStateMachine;
    /** @private */
    private var m_pActionFsm : CFiniteStateMachine;
    /** @private */
    private var m_pGodTimeDog : CTimeDog;

    /** Creates a new CCharacterStateMachine. */
    public function CCharacterStateMachine() {
        super( "fsm" );
    }

    override public function get actionFSM() : CFiniteStateMachine {
        return m_pActionFsm;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        if ( !m_pBaseFsm ) {
            m_pBaseFsm = CFiniteStateMachine.create( {
                events : [
                    {
                        name : STARTUP, from : NONE, to : CGameBaseStateConstants.BORN
                    },
                    {
                        name : CGameBaseStateConstants.EVENT_BORN,
//                        from : CGameBaseStateConstants.BORN,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CGameBaseStateConstants.IDLE
                    },
                    {
                        name : CGameBaseStateConstants.EVENT_FIGHT_BEGAN,
                        from : CGameBaseStateConstants.IDLE,
                        to : CGameBaseStateConstants.FIGHT
                    },
                    {
                        name : CGameBaseStateConstants.EVENT_FIGHT_END,
                        from : CGameBaseStateConstants.FIGHT,
                        to : CGameBaseStateConstants.IDLE
                    }
                ]
            } );

            m_pBaseFsm.addEventListener( CStateEvent.ENTER, _onBaseStateEnter );
        }

        if ( !m_pActionFsm ) {
            m_pActionFsm = CFiniteStateMachine.create( {
                error : _onActionStateError,
                events : [
                    {
                        name : STARTUP,
//                        from : NONE,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CCharacterActionStateConstants.IDLE
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_RUN,
                        from : [ CCharacterActionStateConstants.IDLE ],
                        to : CCharacterActionStateConstants.RUN
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_STOP,
                        from : CCharacterActionStateConstants.RUN,
                        to : CCharacterActionStateConstants.IDLE
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_ATTACK_BEGAN,
                        from : [
                            CCharacterActionStateConstants.ATTACK,
                            CCharacterActionStateConstants.RUN,
                            CCharacterActionStateConstants.IDLE,
                            CCharacterActionStateConstants.GETUP
                        ],
                        to : CCharacterActionStateConstants.ATTACK
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_ATTACK_END,
                        from : CCharacterActionStateConstants.ATTACK,
                        to : CCharacterActionStateConstants.IDLE
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_DODGE_BEGAN,
                        from : [
                            CCharacterActionStateConstants.IDLE,
                            CCharacterActionStateConstants.RUN,
                            CCharacterActionStateConstants.HURT,
                            CCharacterActionStateConstants.ATTACK,
                            CCharacterActionStateConstants.KNOCK_UP,
                            CCharacterActionStateConstants.LYING
                        ],
                        to : CCharacterActionStateConstants.E_ROLL
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_HURT_BEGAN,
                        from : [
                            CCharacterActionStateConstants.IDLE,
                            CCharacterActionStateConstants.HURT,
                            CCharacterActionStateConstants.ATTACK,
//                            CCharacterActionStateConstants.GETUP,
                            CCharacterActionStateConstants.RUN,
                            CCharacterActionStateConstants.LYING,
//                            CCharacterActionStateConstants.KNOCK_UP
                        ],
                        to : CCharacterActionStateConstants.HURT
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_CATCH_BEGIN,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CCharacterActionStateConstants.BE_CATCH
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_CATCH_END,
                        from : CCharacterActionStateConstants.BE_CATCH,
                        to : CCharacterActionStateConstants.IDLE
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_KNOCK_UP_BEGAN,
                        from : [
                            CCharacterActionStateConstants.IDLE,
                            CCharacterActionStateConstants.HURT,
                            CCharacterActionStateConstants.RUN,
                            CCharacterActionStateConstants.ATTACK,
//                            CCharacterActionStateConstants.GETUP,
                            CCharacterActionStateConstants.KNOCK_UP,
                            CCharacterActionStateConstants.LYING
                        ],
                        to : CCharacterActionStateConstants.KNOCK_UP
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_LYING_BEGAN,
                        from : [
                            CCharacterActionStateConstants.KNOCK_UP,
                            CCharacterActionStateConstants.HURT
                        ],
                        to : CCharacterActionStateConstants.LYING
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_GETUP_BEGAN,
                        from : [
                            CCharacterActionStateConstants.LYING
                        ],
                        to : CCharacterActionStateConstants.GETUP
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_POP,
                        from : [
                            CCharacterActionStateConstants.IDLE,
                            CCharacterActionStateConstants.RUN,
                            CCharacterActionStateConstants.E_ROLL,
                            CCharacterActionStateConstants.HURT,
                            CCharacterActionStateConstants.ATTACK,
                            CCharacterActionStateConstants.LYING,
                            CCharacterActionStateConstants.GETUP,
                            CCharacterActionStateConstants.BE_CATCH,
                        ],
                        to : CCharacterActionStateConstants.IDLE
                    },
                    {
                        name : CCharacterActionStateConstants.EVENT_DEAD,
                        from : CFiniteStateMachine.WILDCARD,
                        to : CCharacterActionStateConstants.DEAD
                    }
                ]
            } );

            // Initialized basic action states.
            this.addState( new CCharacterIdleState() );
            this.addState( new CCharacterRunState() );
            this.addState( new CCharacterAttackState() );
            this.addState( new CCharacterDodgeState() );
            this.addState( new CCharacterHurtState() );
            this.addState( new CCharacterKnockUpState() );
            this.addState( new CCharacterGetupState() );
            this.addState( new CCharacterLyingState() );
            this.addState( new CCharacterDeadState() );
            this.addState( new CCharacterBeCatchState() );
        }

        /**
         var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
         if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onCharacterPropertyUpdated, false, 0, true );
        }*/

        m_pActionFsm.addEventListener( CStateEvent.ENTER, _onActionStateEnter, false, 0, true );

        m_pBaseFsm.on( STARTUP );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
        if ( m_pBaseFsm ) {
            // REFCNT release.
            m_pBaseFsm.removeEventListener( CStateEvent.ENTER, _onBaseStateEnter );
            if ( m_pBaseFsm is IDisposable )
                IDisposable( m_pBaseFsm ).dispose();
        }
        m_pBaseFsm = null;

        if ( m_pActionFsm ) {
            m_pActionFsm.removeEventListener( CStateEvent.ENTER, _onActionStateError );
            if ( m_pActionFsm is IDisposable )
                IDisposable( m_pActionFsm ).dispose();
        }
        m_pActionFsm = null;

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onCharacterPropertyUpdated, false );
        }
    }

    final public function addState( state : CCharacterState ) : void {
        if ( !state )
            return;
        state.m_pOwner = owner;
        m_pActionFsm.addState( state );
    }

    private function _onBaseStateEnter( event : CStateEvent ) : void {
        if ( event.from == NONE && event.to == CGameBaseStateConstants.BORN ) {
            Foundation.Log.logTraceMsg( "Entered born ..." );

            m_pActionFsm.on( STARTUP );
        }
    }

    final private function _onActionStateEnter( event : CStateEvent ) : void {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        switch ( event.from ) {
            case CCharacterActionStateConstants.E_ROLL:
            case CCharacterActionStateConstants.GETUP:
            {
                var bEval : Boolean = true;
                if ( event.from == CCharacterActionStateConstants.E_ROLL && event.argList.length > 1 ) {
                    bEval = Boolean( event.argList[ 1 ] )
                }

                if ( event.from == CCharacterActionStateConstants.GETUP ) {
                    var isMonster : Boolean = CCharacterDataDescriptor.isMonster( owner.data );
                    if ( isMonster ) {
                        var pMonsterProp : CMonsterProperty = owner.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                        if ( pMonsterProp ) {
                            if ( pMonsterProp.getupinvulnerable == 0 )
                                bEval = false;
                        }
                    }
                }

                if ( bEval ) {
                    if ( !m_pGodTimeDog )
                        m_pGodTimeDog = new CTimeDog( _stopGodTime );
                    m_pGodTimeDog.start( 1.0 );

                    if ( pStateBoard ) {
                        pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
                        pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
                    }

                    _playGodFx();

                }

                if( pStateBoard && event.to == CCharacterActionStateConstants.IDLE ) {
                    pStateBoard.resetValue( CCharacterStateBoard.BAN_DODGE , CCharacterStateBoard.BAN_DODGE );
                }
                break;
            }
            case CCharacterActionStateConstants.DEAD:
            {
                if ( event.to == CCharacterActionStateConstants.IDLE ) {
                    var isPlayer : Boolean = CCharacterDataDescriptor.isHero( owner.data );
                    if ( isPlayer ) {
                        if ( !m_pGodTimeDog )
                            m_pGodTimeDog = new CTimeDog( _stopGodTime );
                        m_pGodTimeDog.start( 4.001 );

                        if ( pStateBoard ) {
                            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
                            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
                        }

                        _playGodFx();
                    }
                }
                break;
            }
            case CCharacterActionStateConstants.HURT:
            {
                if( pStateBoard && event.to == CCharacterActionStateConstants.IDLE ) {
                    pStateBoard.resetValue( CCharacterStateBoard.BAN_DODGE , CCharacterStateBoard.BAN_DODGE );
                }
                break;
            }
            default:
                break;
        }
    }

    private function _stopGodTime() : void {
        free( m_pGodTimeDog );
        m_pGodTimeDog = null;

        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, true );
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, true );
        }

        _playGodFx( true );
    }

    private function _playGodFx( boStop : Boolean = false ) : void {
        var pProp : CCharacterProperty = getComponent( CCharacterProperty ) as CCharacterProperty;
        var pFxMedia : CFXMediator = getComponent( CFXMediator ) as CFXMediator;
        if ( pProp && pFxMedia ) {
            if ( !boStop )
                pFxMedia.playComhitEffects( pProp.getUpFx, true );
            else
                pFxMedia.stopComHitEffects( pProp.getUpFx );
        }
    }

    final private function _onActionStateError( name : String, from : String, to : String, args : Array, errorCode : int, errorMessage : String ) : int {
        // Foundation.Log.logErrorMsg( errorMessage );
        return errorCode;
    }

    final private function _onCharacterPropertyUpdated( event : Event ) : void {
        var pProperty : ICharacterProperty = getComponent( ICharacterProperty ) as ICharacterProperty;
        if ( pProperty ) {
            if ( pProperty.HP <= 0 ) {
                // already dead.
                var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
                if ( pStateBoard ) {
                    pStateBoard.setValue( CCharacterStateBoard.DEAD, true );
                }

                m_pActionFsm.on( CCharacterActionStateConstants.EVENT_DEAD );
            }
        }
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
        if ( m_pGodTimeDog ) {
            m_pGodTimeDog.update( delta );
        }
    }

}
}
