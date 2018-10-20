//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/22.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Framework.CFX;

import flash.events.Event;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.CSkillList;
import kof.game.character.animation.IAnimation;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.collision.ICollisable;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.ERPRecoveryType;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fx.CFXMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;

/**
 * just a fast way to get the component of CGameObject
 */
public class CComponentUtility {
    public function CComponentUtility( owner : CGameObject ) {
        m_pOwner = owner;
        _initial();
    }

    private function _initial() : void {
        if ( fightTriggle ) {
            fightTriggle.addEventListener( CFightTriggleEvent.HIT_TARGET, _onFightTriggerEvent );
            fightTriggle.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onFightTriggerEvent );
            fightTriggle.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _onFightTriggerEvent );
            fightTriggle.addEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL, _playComFX );
            fightTriggle.addEventListener( CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL, _playComFX );
            fightTriggle.addEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED, _onFightTriggerEvent );
            fightTriggle.addEventListener( CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT, _comboRecoveryRP );
            fightTriggle.addEventListener( CFightTriggleEvent.EVT_NOT_ENOUGHT_AP, _onFightTriggerEvent );
        }

        if ( pEventMediator )
            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateChange );

        m_theControlledFX = new <CFX>[];
    }

    public function dispose() : void {
        //fixme
        if ( fightTriggle ) {
            fightTriggle.removeEventListener( CFightTriggleEvent.HIT_TARGET, _onFightTriggerEvent );
            fightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onFightTriggerEvent );
            fightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _onFightTriggerEvent );
            fightTriggle.removeEventListener( CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL, _playComFX );
            fightTriggle.removeEventListener( CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL, _playComFX );
            fightTriggle.removeEventListener( CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT, _comboRecoveryRP );
            fightTriggle.removeEventListener( CFightTriggleEvent.EVT_NOT_ENOUGHT_AP, _onFightTriggerEvent );
            fightTriggle.removeEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED, _onStateChange );
        }

        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onStateChange );

        emitControlledFX();
        m_theControlledFX = null;
    }

    private function _onFightTriggerEvent( e : CFightTriggleEvent ) : void {
        var event : String = e.type;
        var temMainSkill : int;
        var parms : Array;
        var pSkill : int;
        switch ( event ) {
            case CFightTriggleEvent.HIT_TARGET:
            {
                var aliasSkillID : int = e.parmList ? e.parmList[ 0 ] : 0;
                if ( pSkillCaster.isInSameMainSkill( aliasSkillID ) ) {
                    m_boHitSomeBody = true;
                }
                break;
            }
            case CFightTriggleEvent.SPELL_SKILL_END:
            {
                if ( boHitSomeBody ) {
                    parms = e.parmList;
                    var pSkillProComp : CSkillPropertyComponent = owner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
                    if ( pSkillProComp )
                        pFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_SKILL_HIT_TARGET, pSkillProComp.getSkillHitRagePowerRecoverty( parms[ 0 ] ) );
                }
                else {
                    var endSkillId : int;
                    parms = e.parmList;
                    if ( parms ) {
                        endSkillId = parms[ 0 ];
                    }
                    restoreAttackPower( endSkillId );
                }

                emitControlledFX();
                break;
            }
            case CFightTriggleEvent.SPELL_SKILL_BEGIN:
            {
                parms = e.parmList;
                if ( parms ) {
                    pSkill = parms[ 0 ];
                }
                if ( CSkillUtil.isActiveSkill( pSkill ) ) {
                    m_boHitSomeBody = false;
                    temMainSkill = 0;
                }
                break;
            }
            case CFightTriggleEvent.EVT_NOT_ENOUGHT_AP:
            {
                if ( CCharacterDataDescriptor.isHero( owner.data ) ) {
                    if ( stateBoard && !stateBoard.getValue( CCharacterStateBoard.IN_ATTACK ) ) {
                        pSkillCaster.playCharacterShake( 99, 0.2 );
                    }
                }
                break;
            }
            case CFightTriggleEvent.SKILL_BE_INTERRUPTED:
            {
                if ( !boHitSomeBody ) {
                    var skillID : int;
                    parms = e.parmList;
                    if ( parms ) {
                        skillID = parms[ 0 ];
                    }
                    restoreAttackPower( skillID );
                }
                m_boHitSomeBody = false;
                emitControlledFX();
                break;
            }
        }

    }

    private function restoreAttackPower( skillID : int ) : void {
        var skillComp : CSkillPropertyComponent = owner.getComponentByClass( CSkillPropertyComponent, false ) as CSkillPropertyComponent;
        var fightCal : CFightCalc = pFightCalc;
        var targetSkillID : int;
        if ( skillComp && fightCal ) {
            targetSkillID = CSkillUtil.getMainSkill( skillID );
            fightCal.battleEntity.calcAttackPower( skillComp.getRestoreApWhenSkillHitNobody( targetSkillID ) );
        }
        var pTrigger : CCharacterFightTriggle = this.fightTriggle;
        if ( pTrigger && targetSkillID != 0 ) {
            pTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_RETURN_SKILL_CONSUME, null, [ targetSkillID ] ) );
        }

    }

    private function _onStateChange( e : Event ) : void {
        var pStateBoard : CCharacterStateBoard = stateBoard;
        var pProp : CCharacterProperty = characterProperty;
        if ( pStateBoard && pStateBoard.isDirty( CCharacterStateBoard.PA_BODY ) ) {
            if ( fxMediator ) {
                if ( pStateBoard.getValue( CCharacterStateBoard.PA_BODY ) ) {
                    fxMediator.playComhitEffects( pProp.paBodyFx, true );
                } else {
                    fxMediator.stopComHitEffects( pProp.paBodyFx );
                }
            }
        }
    }

    public function addToControlledFX( fx : CFX ) : void {
        var pFx : CFX = fx;
        if ( !pFx || pFx.disposed ) return;

        m_theControlledFX.push( fx );
    }

    public function emitControlledFX() : void {
        for each( var fx : CFX in m_theControlledFX ) {
            fx.stop();
        }

        m_theControlledFX.splice( 0, m_theControlledFX.length );
    }

    private function _playComFX( e : CFightTriggleEvent ) : void {
        var fxType : String = e.type;
        switch ( fxType ) {
            case CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL:
                fxMediator.playComhitEffects( characterProperty.driveCancelFx );
                if ( pSyncBoard ) {
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_DRIVE_CANCEL, true );
                }
                break;
            case CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL:
                fxMediator.playComhitEffects( characterProperty.superCancelFx );
                break;
        }

    }

    private function _comboRecoveryRP( e : CFightTriggleEvent ) : void {
        var comboCnt : int = int( e.parmList[ 0 ] );
        var comboInterval : int = characterProperty.rageRestoreComboInterval;
        if ( comboCnt != 0 && comboInterval != 0 ) {
            if ( comboCnt % characterProperty.rageRestoreComboInterval == 0 )
                pFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_COMBO );
        }
    }

    final public function get owner() : CGameObject {
        return m_pOwner;
    }

    final public function get collisionComponent() : CCollisionComponent {
        return m_pOwner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
    }

    final public function get pSkillCaster() : CSkillCaster {
        return m_pOwner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    final public function get stateBoard() : CCharacterStateBoard {
        return m_pOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final public function get cAnimation() : IAnimation {
        return m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
    }

    final public function get theCollisableCmp() : ICollisable {
        return m_pOwner.getComponentByClass( ICollisable, true ) as ICollisable;
    }

    final public function get pSyncBoard() : CCharacterSyncBoard {
        return m_pOwner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
    }

    final public function get movementCmp() : CMovement {
        return m_pOwner.getComponentByClass( CMovement, true ) as CMovement;
    }

    final public function get tranformCmp() : ITransform {
        return m_pOwner.getComponentByClass( ITransform, true ) as ITransform;
    }

    final public function get skillCaster() : CSkillCaster {
        return m_pOwner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    final public function get pTargetCriteriaComp() : CTargetCriteriaComponet {
        return m_pOwner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
    }


    final public function get modelDisplay() : IDisplay {
        return m_pOwner.getComponentByClass( IDisplay, true ) as IDisplay;
    }

    final public function get fightTriggle() : CCharacterFightTriggle {
        return m_pOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    final public function get pEventMediator() : CEventMediator {
        return m_pOwner.getComponentByClass( CEventMediator, true ) as CEventMediator;
    }

    final public function get skillList() : CSkillList {
        return m_pOwner.getComponentByClass( CSkillList, true ) as CSkillList;
    }

    final public function get facadeMediator() : CFacadeMediator {
        return m_pOwner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
    }

    final public function get fxMediator() : CFXMediator {
        return m_pOwner.getComponentByClass( CFXMediator, true ) as CFXMediator;
    }

    final public function get pNetInput() : CCharacterNetworkInput {
        return m_pOwner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput
    }

    final public function get characterProperty() : CCharacterProperty {
        return m_pOwner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
    }

    final public function get sceneMediator() : CSceneMediator {
        return m_pOwner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
    }

    final public function get fightProperty() : CFightProperty {
        return m_pOwner.getComponentByClass( CFightProperty, true ) as CFightProperty;
    }

    public function get boHitSomeBody() : Boolean {
        return m_boHitSomeBody;
    }

    public function get pFightCalc() : CFightCalc {
        return m_pOwner.getComponentByClass( CFightCalc, true ) as CFightCalc;
    }

    private var m_pOwner : CGameObject;

    private var m_boHitSomeBody : Boolean;

    private var m_theControlledFX : Vector.<CFX>;
}
}
