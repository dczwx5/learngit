//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CCharacter;
import QFLib.Framework.CCharacter;
import QFLib.Math.CVector2;

import flash.events.Event;

import kof.framework.IConfiguration;
import kof.framework.INetworking;
import kof.framework.fsm.CStateEvent;
import kof.game.character.display.IDisplay;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CSubscribeBehaviour;
import kof.message.Level.AppearingWaysEndRequest;
import kof.message.Map.CharacterDeadRequest;
import kof.message.Map.CharacterMoveRequest;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNetworkMessageMediator extends CSubscribeBehaviour {

    /** @private */
    private var m_bAsHost : Boolean;
    /** @private */
    private var m_pFacadeMediator : CFacadeMediator;
    /** @private */
    private var m_pSceneFacade : CSceneMediator;
    /** @private */
    private var m_pStateMachine : CCharacterStateMachine;
    /** @private */
    private var m_pNetworking : INetworking;
    /** @private */
    private var m_bSchedulePositionSyncNeeded : Boolean;
    /** @private */
    private var m_fPositionSyncElapsedTime : Number;
    /** @private */
    private var m_fPositionSyncIntervalTime : Number = 0.1; // by default, 0.1 seconds broadcast to all.

    private var m_bForceBanMoveSchedule : Boolean;

    /**
     * Creates a new CNetworkMessageMediator.
     */
    public function CNetworkMessageMediator( networking : INetworking ) {
        super( "network" );

        m_pNetworking = networking;
    }

    override public function dispose() : void {
        super.dispose();

        this.detachEventListeners();
        this.detachHostEventListeners();

        this.m_pFacadeMediator = null;
        this.m_pSceneFacade = null;
        this.m_pNetworking = null;
        this.m_pStateMachine = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        m_pFacadeMediator = this.getComponent( CFacadeMediator ) as CFacadeMediator;
        m_pStateMachine = this.getComponent( CCharacterStateMachine ) as CCharacterStateMachine;
        m_pSceneFacade = this.getComponent( CSceneMediator ) as CSceneMediator;

        m_fPositionSyncElapsedTime = 0;
        m_bSchedulePositionSyncNeeded = false;

        this.attachEventListeners();
        this.attachHostEventListeners();

        updateIntervalTime();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();

        this.detachEventListeners();
        this.detachHostEventListeners();

        this.m_pFacadeMediator = null;
        this.m_pStateMachine = null;
        this.m_pSceneFacade = null;
    }

    final public function get isAsHost() : Boolean {
        return m_bAsHost;
    }

    final public function set asHost( value : Boolean ) : void {
        if ( m_bAsHost == value )
            return;
        m_bAsHost = value;

        if ( value ) {
            // as host.
            attachHostEventListeners();
        } else {
            detachHostEventListeners();
        }
    }

    final public function get objID() : Number {
        return (getComponent( ICharacterProperty ) as ICharacterProperty).ID;
    }

    final public function get objType() : int {
        return CCharacterDataDescriptor.getType( owner.data );
    }

    final public function get display() : CCharacter {
        const display : IDisplay = getComponent( IDisplay ) as IDisplay;
        if ( display ) {
            return display.modelDisplay;
        }
        return null;
    }

    protected function attachHostEventListeners() : void {
        if ( !isAsHost )
            return;

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.START_MOVE, _onStartMove, false, 0, true );
            pEventMediator.addEventListener( CCharacterEvent.STOP_MOVE, _onStopMove, false, 0, true );
            pEventMediator.addEventListener( CCharacterEvent.DIRECTION_CHANGED, _onDirectionChanged, false, 0, true );
            pEventMediator.addEventListener( CCharacterEvent.FORCE_RESET_DIRECTEION, _onResetDirection, false, 0, true );
        }
    }

    protected function detachHostEventListeners() : void {
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.START_MOVE, _onStartMove );
            pEventMediator.removeEventListener( CCharacterEvent.STOP_MOVE, _onStopMove );
            pEventMediator.removeEventListener( CCharacterEvent.DIRECTION_CHANGED, _onDirectionChanged );

            pEventMediator.removeEventListener( CCharacterEvent.FORCE_RESET_DIRECTEION, _onResetDirection );
        }
    }

    protected function attachEventListeners() : void {
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
//            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateValueUpdated, false, 0, true );
            pEventMediator.addEventListener( CCharacterEvent.APPEAR_END, _onAppearEnd, false, 0, true );

        }

        if ( m_pStateMachine ) {
            CAssertUtils.assertNotNull( m_pStateMachine.actionFSM );
            m_pStateMachine.actionFSM.addEventListener( CStateEvent.LEAVE, _onLeaveState, false, 0, true );
            m_pStateMachine.actionFSM.addEventListener( CStateEvent.ENTER, _onEnterState, false, 0, true );
        }
    }

    protected function detachEventListeners() : void {
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
//            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateValueUpdated );
            pEventMediator.removeEventListener( CCharacterEvent.APPEAR_END, _onAppearEnd );
        }

        if ( m_pStateMachine && m_pStateMachine.actionFSM ) {
            if ( m_pStateMachine.actionFSM ) m_pStateMachine.actionFSM.removeEventListener( CStateEvent.LEAVE, _onLeaveState );
            m_pStateMachine.actionFSM.removeEventListener( CStateEvent.ENTER, _onEnterState );
        }
    }

    private function updateIntervalTime() : void {
        if( this.objType == CCharacterDataDescriptor.TYPE_MONSTER )
            m_fPositionSyncIntervalTime = 0.3;

        var pConfig : IConfiguration = this.getComponent( IConfiguration ) as IConfiguration;
        if ( pConfig) {
            var fInterval : int = pConfig.getInt( 'networkSyncInterval', m_fPositionSyncIntervalTime * 1000 );

            m_fPositionSyncIntervalTime = 0.001 * fInterval;
        }
    }

    private function _onEnterState( event : CStateEvent ) : void {
//        if ( !isAsHost )
//            return;
    }

    private function _onLeaveState( event : CStateEvent ) : void {
        if ( !isAsHost )
            return;

        if ( event.from == CCharacterActionStateConstants.RUN ) {
            // NOTE: 离开Run状态应当停止移动事件同步
            /** var input : CCharacterInput = owner.getComponentByClass( CCharacterInput , true ) as CCharacterInput;
             if( input )
             input.wheel = new Point( 0 , 0 );*/
            this._onStopMove( null );
        }
    }

    private function _onStateValueUpdated( event : Event ) : void {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard && pStateBoard.isDirty( CCharacterStateBoard.DEAD ) && true == pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) {
            // update to dead.
            this._onCharacterDead();
        }
    }

    /** CCharacterEvent.APPEAR_END triggered. */
    private function _onAppearEnd( event : Event ) : void {
        // tell server that event happend.
        var pAppear : CMonsterAppear = this.getComponent( CMonsterAppear ) as CMonsterAppear;
        if ( pAppear ) {
            var msg : AppearingWaysEndRequest = m_pNetworking.getMessage( AppearingWaysEndRequest ) as AppearingWaysEndRequest;

//            msg.entityID = pAppear.entityID;
            msg.type = pAppear.entityType;
            msg.ID = pAppear.ID;

            m_pNetworking.send( msg );
        }
    }

    /**
     * 角色进入死亡状态，同步到Server
     */
    private function _onCharacterDead() : void {
        var msg : CharacterDeadRequest = m_pNetworking.getMessage( CharacterDeadRequest ) as CharacterDeadRequest;
        msg.id = this.objID;
        msg.type = int( owner.data.type );

        m_pNetworking.send( msg );
    }

    protected function getHeightByGround( pos3DX : Number, pos3DZ : Number, pos3DHeight : Number ) : Number {
        var pCharacter : CCharacter = this.display;
        var fTerrainHeight : Number = 0.0;
        if ( pCharacter) {
            if ( !pCharacter.inAir )
                return 0;
            fTerrainHeight = pCharacter.terrainHeight;
        }
        return Math.max( pos3DHeight - fTerrainHeight, 0 );
    }

    private function _onDirectionChanged( event : Event ) : void {
        var msg : CharacterMoveRequest = new CharacterMoveRequest();
        msg.id = this.objID;
        msg.type = this.objType;
        msg.eventType = 0;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        var gridPoint : CVector2 = m_pSceneFacade.toGrid( pTransform.x, pTransform.y, pTransform.z );

        var pInput : CCharacterInput = this.getComponent( CCharacterInput ) as CCharacterInput;
        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.gridX = gridPoint.x;
        msg.gridY = gridPoint.y;

        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.posH = getHeightByGround( transform.x, transform.y, transform.z );
        msg.time = 0.0;

        m_pNetworking.post( msg );

        m_bSchedulePositionSyncNeeded = true;
        m_fPositionSyncElapsedTime = 0;
    }
    private function _onResetDirection ( event : Event ) : void{
        var msg : CharacterMoveRequest = new CharacterMoveRequest();
        msg.id = this.objID;
        msg.type = this.objType;
        msg.eventType = 4;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        var gridPoint : CVector2 = m_pSceneFacade.toGrid( pTransform.x, pTransform.y, pTransform.z );

        var pInput : CCharacterInput = this.getComponent( CCharacterInput ) as CCharacterInput;
        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.gridX = gridPoint.x;
        msg.gridY = gridPoint.y;

        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.posH = getHeightByGround( transform.x, transform.y, transform.z );
        msg.time = 0.0;

        m_pNetworking.post( msg );
    }

    protected function _onStartMove( event : Event ) : void {
        var msg : CharacterMoveRequest = new CharacterMoveRequest();
        msg.id = this.objID;
        msg.type = this.objType;
        msg.eventType = 1;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        var gridPoint : CVector2 = m_pSceneFacade.toGrid( pTransform.x, pTransform.y, pTransform.z );

        var pInput : CCharacterInput = this.getComponent( CCharacterInput ) as CCharacterInput;
        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.gridX = gridPoint.x;
        msg.gridY = gridPoint.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.posH = getHeightByGround( transform.x, transform.y, transform.z );
        msg.time = 0.0;

        m_pNetworking.post( msg );

        m_bSchedulePositionSyncNeeded = true;
        m_fPositionSyncElapsedTime = 0;
    }

    private function _onStopMove( event : Event = null ) : void {
        var msg : CharacterMoveRequest = new CharacterMoveRequest();
        msg.id = this.objID;
        msg.type = this.objType;
        msg.eventType = 2;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        var gridPoint : CVector2 = m_pSceneFacade.toGrid( pTransform.x, pTransform.y, pTransform.z );

        var pInput : CCharacterInput = this.getComponent( CCharacterInput ) as CCharacterInput;
        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.gridX = gridPoint.x;
        msg.gridY = gridPoint.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.posH = getHeightByGround( transform.x, transform.y, transform.z );
        msg.time = 0.0;

        m_pNetworking.post( msg );

        m_bSchedulePositionSyncNeeded = false;
        m_fPositionSyncElapsedTime = 0;
    }

    private function _onScheduleMove() : void {
        var msg : CharacterMoveRequest = new CharacterMoveRequest();
        msg.id = this.objID;
        msg.type = this.objType;
        msg.eventType = 3;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        var gridPoint : CVector2 = m_pSceneFacade.toGrid( pTransform.x, pTransform.y, pTransform.z );

        var pInput : CCharacterInput = this.getComponent( CCharacterInput ) as CCharacterInput;
        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.gridX = gridPoint.x;
        msg.gridY = gridPoint.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.posH = getHeightByGround( transform.x, transform.y, transform.z );
        msg.time = 0.0;

        m_pNetworking.post( msg );
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_bSchedulePositionSyncNeeded && !m_bForceBanMoveSchedule) {
            if ( isNaN( m_fPositionSyncElapsedTime ) )
                m_fPositionSyncElapsedTime = 0;
            m_fPositionSyncElapsedTime += delta;
            if ( m_fPositionSyncElapsedTime >= m_fPositionSyncIntervalTime ) {
                m_fPositionSyncElapsedTime -= m_fPositionSyncIntervalTime;

                // Post current position state to all.
                this._onScheduleMove();
            }
        }
    }

    final public function set bForceBanMoveSchedule( value : Boolean ) : void{
        this.m_bForceBanMoveSchedule = value;
    }
}
}

// vim:ft tw=0
