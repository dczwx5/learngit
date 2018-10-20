//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/30.
//----------------------------------------------------------------------
package kof.game.character.fight {

import QFLib.Foundation.CTime;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;

import flash.events.Event;

import flash.events.TimerEvent;

import flash.utils.Timer;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skillchain.CFightingTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;

import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameComponent;

public class CAutoRecoveryComponent extends CGameComponent implements IUpdatable {
    public function CAutoRecoveryComponent( name : String = null, branchData : Boolean = false ) {
        super( "AutoRecovery", branchData );
        enabled = false;
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onEnter() : void {
        var bInvalide : Boolean;
        var isTrainLevel : Boolean;
        var isTeachingLevel : Boolean;
        var isNeverDead : Boolean;
        var pLevelMediator : CLevelMediator = owner.getComponentByClass( CLevelMediator, false ) as CLevelMediator;
        if ( pLevelMediator ) {
            isTrainLevel = pLevelMediator.isTrainLevel;
            isTeachingLevel = pLevelMediator.isTeachingLevel();
        }

        var pMonsterProperty : CMonsterProperty = owner.getComponentByClass( CMonsterProperty , false) as CMonsterProperty;
        if( pMonsterProperty )
                isNeverDead = pMonsterProperty.neverDead == 1;

        bInvalide = isTrainLevel || isNeverDead || isTeachingLevel;
        enabled = m_bActivated = bInvalide;

        if ( m_bActivated ) {
            _initialized();
        }
    }

    private function _initialized() : void {
        initializedRecoveryParam();
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateChange );
            pEventMediator.addEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyChange );
        }

    }

    private function _onStateChange( event : Event ) : void {
        if( m_bInDeadHeal )
                return;

        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var pProperty : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( pStateBoard ) {
            if ( pStateBoard.isDirty( CCharacterStateBoard.IN_CONTROL ) ) {
                if ( pStateBoard.getValue( CCharacterStateBoard.IN_CONTROL ) && pProperty.HP != pProperty.MaxHP )
                    m_idleElapseTime = m_delayRecoveryTimeWhenIdle;
                else {
                    m_bInIdleHeal = false;
                    _clearTime();
                    m_idleElapseTime = NaN;
                }
            }

        }

    }

    private function _onPropertyChange( e : Event ) : void {
        var pProperty : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var currentHP : int = pProperty.HP;
        if ( currentHP <= 0 ) {
            if( !m_bInDeadHeal ){
                m_deadElapseTime = m_delayRecoveryTimeWhenDead;
            }
            m_idleElapseTime = NaN;
        } else {
            m_deadElapseTime = NaN;
        }

    }

    override protected function onExit() : void {
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, false ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateChange );
            pEventMediator.removeEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyChange );
        }

        _clearTime();
    }

    override public function set enabled( value : Boolean ) : void {
        super.enabled = value;
    }

    public function update( delta : Number ) : void {

        if ( !isNaN( m_idleElapseTime ) ) {
            if ( m_idleElapseTime > 0 )
                m_idleElapseTime -= delta;
        }

        if ( !isNaN( m_deadElapseTime ) ) {
            if ( m_deadElapseTime > 0 )
                m_deadElapseTime -= delta;
        }

        if ( !m_bInIdleHeal && m_idleElapseTime <= 0 ) {
            _healWhenIdle();
        }

        if ( !m_bInDeadHeal && m_deadElapseTime <= 0 ) {
            _healWhenDead();
        }
    }

    private function _healWhenIdle() : void {
        m_bInIdleHeal = true;
        _setTimer( m_recoveryPerSecondWhenIdle );
    }

    private function _healWhenDead() : void {
        m_bInDeadHeal = true;
        m_bInIdleHeal = false;
        _setTimer( m_recoveryPerSecondWhenDead ) ;
    }

    private function _setTimer( recoveryForSecond : Number ) : void{
        _clearTime();
        var repeatCount : int = (1 / recoveryForSecond ) * HEAL_TIME_PER_SEC;
        var duration : Number = 1000 / HEAL_TIME_PER_SEC;
        m_theTimer = new Timer( duration );
        m_theTimer.addEventListener( TimerEvent.TIMER, _healTarget );
        m_theTimer.addEventListener( TimerEvent.TIMER_COMPLETE, _stopHealIdle );
        m_theTimer.start();
    }

    private function _clearTime() : void {
        if ( m_theTimer ) {
            m_theTimer.stop();
            m_theTimer.removeEventListener( TimerEvent.TIMER, _healTarget );
            m_theTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, _stopHealIdle );
            m_theTimer = null;
        }
    }

    private function _stopHealIdle( e : TimerEvent = null ) : void {
        m_bInDeadHeal = false;
        m_bInIdleHeal = false;
        m_deadElapseTime = NaN;
        m_idleElapseTime = NaN;
    }

    private function _healTarget( e : TimerEvent ) : void {
        var pCharacterProperty : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( pCharacterProperty ) {
            var maxHP : int = pCharacterProperty.MaxHP;
            var healHP : int;
            if ( m_bInDeadHeal ) {
                healHP = maxHP * (m_recoveryPerSecondWhenDead / HEAL_TIME_PER_SEC );
            }
            if ( m_bInIdleHeal ) {
                healHP = maxHP * ( m_recoveryPerSecondWhenIdle / HEAL_TIME_PER_SEC );
            }

            if ( healHP != 0 ) {
                var healID : int ;
                if( m_bInDeadHeal )
                        healID = 100001;
                if( m_bInIdleHeal )
                        healID = 100000;

                pCharacterProperty.HP = CMath.min( pCharacterProperty.MaxHP, pCharacterProperty.HP + healHP );
                //策划说不漂字了
//                var pFloatSprite : CFightFloatSprite = owner.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
//                if ( pFloatSprite )
//                    pFloatSprite.createGreenNumText( healHP );
                responseToSev( healID , pCharacterProperty.HP , healHP )

                if ( pCharacterProperty.HP == pCharacterProperty.MaxHP ) {
                    _clearTime();
                    _stopHealIdle();
                }
            }
        }
    }

    private function responseToSev( healID : int, currentHP : int , healHP : int) : void {
        var pFightTrigger : CCharacterFightTriggle= owner.getComponentByClass(CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var pNetOutputComp : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;

        var healInfo : Object = {};
        healInfo.cnt = 1;
        healInfo.ID = CCharacterDataDescriptor.getID( owner.data );
        healInfo.healHP = healHP;
        healInfo.type = CCharacterDataDescriptor.getType( owner.data );
        healInfo[ CCharacterSyncBoard.CURRENT_HP ] = currentHP;

        if ( pFightTrigger && pNetOutputComp != null )
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_HEAL, null, [ 0, healID, [ healInfo ] ] ) );
    }

    public function initializedRecoveryParam( recoverySpeed : Number = 0.5, delayWhenDead : Number = 2.0
            , speedWhenIdle : Number = 0.2, delayWhenIdle : Number = 5.0 ) : void {

        m_recoveryPerSecondWhenDead = recoverySpeed;
        m_recoveryPerSecondWhenIdle = speedWhenIdle;
        m_delayRecoveryTimeWhenDead = delayWhenDead;
        m_delayRecoveryTimeWhenIdle = delayWhenIdle;
    }

    private var m_bInIdleHeal : Boolean;
    private var m_bInDeadHeal : Boolean;

    private var m_deadElapseTime : Number;
    private var m_idleElapseTime : Number;
    private var m_recoveryPerSecondWhenDead : Number;
    private var m_recoveryPerSecondWhenIdle : Number;
    private var m_delayRecoveryTimeWhenDead : Number;
    private var m_delayRecoveryTimeWhenIdle : Number;
    private var m_bActivated : Boolean;
    private var m_theTimer : Timer;
    private const HEAL_TIME_PER_SEC : int = 5;
}
}
