//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/15.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;

import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.framework.events.CPropertyChangeEvent;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.emitter.CMasterCompomnent;

import kof.game.character.fight.emitter.behaviour.CMissileBasicBehaviour;
import kof.game.character.fight.emitter.disabletrigger.CMissileHit;
import kof.game.character.fight.emitter.effecttrigger.CMissileBaseEffect;
import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMissileProperty;
import kof.game.character.property.CMissileProperty;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;
import kof.message.Fight.FightMissileDeadRequest;
import kof.table.Aero;
import kof.table.Aero.EAeroDisableType;
import kof.table.Emitter;

/**
 * the component for missile , that have many behaviors , move behaviors , effects behaviors .ext...
 */
public class CEmitterComponent extends CGameComponent implements IUpdatable {
    public function CEmitterComponent( pDb : IDatabase, missileContainer : CMissileContainer, networking : INetworking ,sceneSystem : ISceneFacade ) {
        super();
        m_pDatabase = pDb;
        m_pMissileContainer = missileContainer;
        m_pNetworking = networking;
        m_pSceneFacade = sceneSystem;
    }

    override protected function onEnter() : void {
        super.onEnter();

        var pMovement : CMovement = owner.getComponentByClass( CMovement, true ) as CMovement;
        pMovement.collisionEnabled = false;

        var pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTrigger )
            pFightTrigger.addEventListener( CFightTriggleEvent.MISSILE_DEAD, RecycleMissile, false, 0, true )

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _buildUpMissile );
        }

    }

    override protected function onExit() : void {
        super.onExit();
    }

    private function _clearMissile() : void {
        if ( m_missileBehavior )
            m_missileBehavior = null;

        m_missileBehavior = null;

        if ( m_missileEffect )
            m_missileEffect.dispose();
        m_missileEffect = null;

        if ( m_missileHit )
            m_missileHit.dispose();
        m_missileHit = null;

        if ( m_missileTimeHit )
            m_missileTimeHit.dispose();
        m_missileTimeHit = null;

        if ( m_comUtility )
            m_comUtility.dispose();
        m_comUtility = null;

    }

    public function update( delta : Number ) : void {
        if ( m_missileBehavior )
            m_missileBehavior.updateBehaviour( delta );

        if ( m_missileEffect )
            m_missileEffect.update( delta );

        if ( m_missileHit )
            m_missileHit.update( delta );

        if ( m_missileTimeHit )
            m_missileTimeHit.update( delta );
    }

    private function buildupComUtility() : void {
        if ( null == m_comUtility ) {
            m_comUtility = new CComponentUtility( owner );
        }
    }

    private function buildupBehavior() : void {
        if ( !m_missileBehavior ) {
            m_missileBehavior = CMissileBehaviorCreater.getMissileBehaviorByType( missileData.MoveType, owner );
            m_missileBehavior.initiaBehaviour( owner );
        }
    }

    private function buildupHit() : void {
        if ( !m_missileHit ) {
            m_missileHit = CMissileBehaviorCreater.getMissileHitByType( missileData.DisabelTrigger, owner );
            m_missileHit.initHitBehavior( owner );

            m_missileTimeHit = CMissileBehaviorCreater.getMissileHitByType( EAeroDisableType.E_TIMEOUT, owner )
            m_missileTimeHit.initHitBehavior( owner );
        }
    }

    private function buildSkillEffects() : void {
        var pSkillCater : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;

        //傀儡端的子弹不执行击打吧
        var materComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( materComp ) {
            var masterNetComp : CCharacterNetworkInput = (!materComp.master) ?
                    null : materComp.master.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
            if ( masterNetComp && masterNetComp.isAsPuppet ) {
                if ( pSkillCater ) {
                    pSkillCater.buildSkillEffects( missileData, 0, null, CSkillCaster.S_EXCLUSI_EFFECT );
                    return;
                }
            }
        }

        if ( pSkillCater ) {
            pSkillCater.buildSkillEffects( missileData, 0, null );
        }
    }

    private function removeSkillEffect() : void {
        var pSkillCater : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;

        if ( pSkillCater )
            pSkillCater.removeSkillEffects();
    }

    private function buildupEffectTrigger() : void {
        m_missileEffect = CMissileBehaviorCreater.getMissileEffetyType( missileData.EffectTrigger, owner );
        if ( m_missileEffect )
            m_missileEffect.initEffect( owner );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        var masterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( masterComp && masterComp.master ) {
            var pNetwork : CCharacterNetworkInput = masterComp.master.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
            if ( pNetwork )
                m_asHost = pNetwork.isAsHost;
        }
    }

    private final function get missileID() : int {
        var pMissileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        return pMissileProperty.missileId;
    }

    public final function get missileData() : Aero {
        var aeroData : Aero = CSkillCaster.skillDB.getAeroByID( missileID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        return aeroData;
    }

    private function _buildUpMissile( event : Event ) : void {
        //build up component utility
        buildupComUtility();
        //build up the move behavior ( MoveType )
        buildupBehavior();
        //build up the hit behavior (  disabletrigger )
        buildupHit();
        //build up the effect ( EffectType)
        buildSkillEffects();
//        buildupEffects();
        //EffectTrigger
        buildupEffectTrigger();

        if ( pEventMediator )
            pEventMediator.addEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyChange );

    }

    private function _onPropertyChange( e : CPropertyUpdateEvent ) : void {
        var target : CGameObject = e.owner;
        if ( target == null )
            return;
        var missileProperty : CMissileProperty = target.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        var eventMediator : CEventMediator = target.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( missileProperty )
            if ( missileProperty.missileHP <= 0 ) {
                eventMediator.removeEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyChange );
                var pFightTrigger : CCharacterFightTriggle = target.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pFightTrigger )
                    pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_DEAD, null ) );
            }
    }

    public function RecycleMissile( e : CFightTriggleEvent = null ) : void {
        var pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTrigger )
            pFightTrigger.removeEventListener( CFightTriggleEvent.MISSILE_DEAD, RecycleMissile );

//        _dispatchToMaster();

        _dispatchDeadToServer();
        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY, _buildUpMissile );
            pEventMediator.removeEventListener( CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyChange );
        }

        _clearMissile();
        m_pMissileContainer.recycleMissile( owner );
    }

    private function _dispatchDeadToServer() : void {
        _dispatchToMaster();

        if( !m_asHost ) return ;
        var missileSeq : Number;
        var pMissileProperty : CMissileProperty;
        pMissileProperty = owner.getComponentByClass( CMissileProperty , true ) as CMissileProperty;
        missileSeq = pMissileProperty.missileSeq;
        var msg : FightMissileDeadRequest = new FightMissileDeadRequest();
        msg.type = 0 ;
        msg.ID = 0 ;
        msg.skillId = 0 ;
        msg.missileId = missileSeq;
        m_pNetworking.post( msg );
    }

    private function _dispatchToMaster() : void {

        var pMater : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( pMater && pMater.master ) {
            var masterFightTrigger : CCharacterFightTriggle = pMater.master.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if( masterFightTrigger == null )
                    return;

            var missileSeq : Number;
            var skillID : int;
            var missileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
            missileSeq = missileProperty.missileSeq;
            skillID = pMater.aliasSkillID;
            masterFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.HERO_MISSILE_DEAD, null, [ missileSeq, skillID ] ) );

            if( m_pSceneFacade )
                m_pSceneFacade.dispatchEvent( new CSceneEvent(CSceneEvent.MISSILE_REMOVE , missileSeq ));
        }
    }

    public function findMissile( missileID : int, missileSeq : int ) : CGameObject {
        return m_pMissileContainer.findMissile( missileID, missileSeq );
    }

    final public function get comUtility() : CComponentUtility {
        return m_comUtility;
    }

    final public function get pEventMediator() : CEventMediator {
        return this.getComponent( CEventMediator ) as CEventMediator;
    }

    private var m_pEmmiterInfo : Emitter;
    private var m_tickTime : Number;
    private var m_missileBehavior : CMissileBasicBehaviour;
    private var m_missileHit : CMissileHit;
    private var m_missileTimeHit : CMissileHit;
    private var m_missileEffect : CMissileBaseEffect;
    private var m_comUtility : CComponentUtility;
    private var m_pDatabase : IDatabase;
    private var m_pMissileContainer : CMissileContainer;
    private var m_pNetworking : INetworking;
    private var m_asHost : Boolean;
    private var m_pSceneFacade : ISceneFacade;

}
}
