//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/22.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;
import flash.utils.getTimer;

import kof.game.character.fight.CCharacterNetworkInput;

import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.synctimeline.ESyncStateType;
import kof.game.character.fight.sync.synctimeline.ESyncStateType;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

import kof.table.ChainPropertyStatus;
import kof.table.ChainPropertyStatus.EStateEndCondition;

public class CStateChanceEffect extends CAbstractSkillEffect {
    public function CStateChanceEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        super.dispose();
        for ( var key : String in m_timeConditions )
            delete  m_timeConditions[ key ];

        for ( var i : int = 0; i < m_statusInfo.PropertyStatusType.length; i++ ) {
            var stateType : String = m_statusInfo.PropertyStatusType[ i ];
            if ( stateType == null || stateType.length == 0 )
                continue;

            if ( m_pOwner ) {
                _resetChangeState( stateType );
            }
        }

        if( m_syncChangeState )
            _resetSyncBoardState();

        for( key in m_syncChangeState ) {
            delete m_syncChangeState[ key ];
        }
        m_syncChangeState = null;

        m_timeConditions = null;
        m_pOwner = null;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
        m_elapseTime += delta;
        if ( m_elapseTime >= effectStartTime && !m_boStateChange ) {
            for ( var i : int = 0; i < m_statusInfo.PropertyStatusType.length; i++ ) {
                var statusType : String = m_statusInfo.PropertyStatusType[ i ];
                if ( !statusType || statusType.length == 0 )
                    continue;
                var nEndCondition : int = m_statusInfo.EndCondition[ i ];
                var nDurationTime : int = m_statusInfo.DurationTime[ i ];
                var conditionValue : Boolean = Boolean( m_statusInfo.IsOpen[ i ] );
                _setChangeState( statusType, conditionValue );
                _setupStopCondition( nEndCondition, statusType, nDurationTime );
                _syncStates( statusType, conditionValue, nDurationTime );
            }
            if ( null != m_syncChangeState && effectStartTime != 0.0 ) {
                var skillID : int;
                if( pSkillCaster)
                        skillID = pSkillCaster.skillID;
                var pFigthTrigger : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle , false ) as CCharacterFightTriggle;
                if( pFigthTrigger ) {
                    pFigthTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_SKILL_STATE , null , [ ESyncStateType.STATE_FIGHT , m_syncChangeState , skillID ] ));
                }
            }
            m_boStateChange = true;
        }

        if ( m_timeConditions ) {
            for ( var stateType : String in m_timeConditions ) {
                var endTime : Number = m_timeConditions[ stateType ];
                if ( endTime <= m_elapseTime ) {
                    _resetChangeState( stateType );
                    delete m_timeConditions[ stateType ];
                }
            }
        }
    }

    override public function initData( ... arg ) : void {
        m_statusInfo = CSkillCaster.skillDB.getChainPropertyStatus( effectID );
        if ( null == arg || arg.length <= 0 ) return;
        m_pOwner = arg[ 0 ] as CGameObject;

        if( effectStartTime == 0.0 ){
            for ( var i : int = 0; i < m_statusInfo.PropertyStatusType.length; i++ ) {
                var statusType : String = m_statusInfo.PropertyStatusType[ i ];
                if ( !statusType || statusType.length == 0 )
                    continue;
                var nDurationTime : int = m_statusInfo.DurationTime[ i ];
                var conditionValue : Boolean = Boolean( m_statusInfo.IsOpen[ i ] );
                _syncStates( statusType, conditionValue, nDurationTime );
            }
            update(0.0);
        }
    }

    public function get stateInfo() : Object{
        return m_syncChangeState;
    }

    private function _setChangeState( sType : String, value : * ) : void {
        var pStateBoard : CCharacterStateBoard = m_pOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var nType : int = CCharacterStateBoard[ sType ];
        pStateBoard.setValue( nType, value , CCharacterStateBoard.TAG_SKILL );
        if( nType == CCharacterStateBoard.PA_BODY )
                Foundation.Log.logTraceMsg(value + " set pabody at time :" + m_elapseTime );
    }

    private function _resetChangeState( sType : String ) : void {
        var pStateBoard : CCharacterStateBoard = m_pOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var nType : int = CCharacterStateBoard[ sType ];
        pStateBoard.resetValue( nType , CCharacterStateBoard.TAG_SKILL );
        if( nType == CCharacterStateBoard.PA_BODY )
                Foundation.Log.logTraceMsg("reset pabody at time :" + m_elapseTime );
    }

    private function _syncStates( type : String, value : Boolean, timeFrame : int ) : void {
        var pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var syncList : Array = [ CCharacterStateBoard.CAN_BE_ATTACK, CCharacterStateBoard.CAN_BE_CATCH, CCharacterStateBoard.PA_BODY ];
        if ( pFightTrigger ) {
            var nType : int = CCharacterStateBoard[ type ];
            var bSync : int = syncList.indexOf( nType );
            var subStateType : int = -1;
            if ( bSync > -1 ) {
                subStateType = _getSyncStateType( nType );
                if ( subStateType > -1 ) {
                    if ( null == m_syncChangeState ) {
                        m_syncChangeState = {};
                    }
                    if ( timeFrame != 0 )
                       m_syncChangeState[ subStateType ] = timeFrame * 0.033;
                    else
                       m_syncChangeState[ subStateType ] = 0;
                }
            }
        }
    }

    private static function _getSyncStateType( type : int ) : int {
        switch ( type ) {
            case CCharacterStateBoard.CAN_BE_ATTACK:
                return ESyncStateType.SUB_FIGHT_UNATTACKABLE;
            case CCharacterStateBoard.CAN_BE_CATCH:
                return ESyncStateType.SUB_FIGHT_UNCATCHABLE;
            case CCharacterStateBoard.PA_BODY:
                return ESyncStateType.SUB_FIGHT_BABODY;
            default:
                return -1;
        }
    }

    private function _setupStopCondition( conditionType : int, stateType : String, durationTime : int = 0 ) : void {
        var pFightTrigger : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        switch ( conditionType ) {
            case EStateEndCondition.E_TIME_END:
                m_timeConditions = new Dictionary();
                m_timeConditions[ stateType ] = durationTime * CSkillDataBase.TIME_IN_ONEFRAME + effectStartTime;
                break;
            case EStateEndCondition.E_ANIMATION_END:
                pFightTrigger.addEventListener( CFightTriggleEvent.ANIMATION_ACTION_END, _endChangeState( stateType, conditionType ) );
                break;
            case EStateEndCondition.E_SKILL_END:
                pFightTrigger.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _endChangeState( stateType, conditionType ) );
                break;
            default:
                CSkillDebugLog.logTraceMsg( "undefine StateEndCondition" );
                break;
        }
    }

    private function _endChangeState( sType : String, conditionType : int ) : Function {
        return function ( e : CFightTriggleEvent ) : void {
            if ( !m_pOwner )
                return;
            _setChangeState( sType, false );
            var pFightTriggle : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if ( EStateEndCondition.E_ANIMATION_END == conditionType )
                pFightTriggle.removeEventListener( CFightTriggleEvent.ANIMATION_ACTION_END, _endChangeState( sType, conditionType ) );

            if ( EStateEndCondition.E_SKILL_END == conditionType )
                pFightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _endChangeState( sType, conditionType ) );
        };
    }

    private function _resetSyncBoardState() : void {
        if( m_pOwner.isRunning ) {
            var pSyncBoard : CCharacterSyncBoard = m_pOwner.getComponentByClass( CCharacterSyncBoard, false ) as CCharacterSyncBoard;
            if ( pSyncBoard ) {
                pSyncBoard.resetValue( CCharacterSyncBoard.SYNC_SUB_STATES );
                pSyncBoard.resetValue( CCharacterSyncBoard.SYNC_STATE );
            }
        }
    }

    private var m_boStateChange : Boolean;
    private var m_statusInfo : ChainPropertyStatus;
    private var m_pOwner : CGameObject;
    private var m_elapseTime : Number = 0.0;
    private var m_timeConditions : Dictionary;
    private var m_syncChangeState : Object;
}
}
