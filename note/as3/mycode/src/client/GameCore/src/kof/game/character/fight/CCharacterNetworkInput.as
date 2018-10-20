//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/4.
//----------------------------------------------------------------------
package kof.game.character.fight {

import QFLib.Collision.common.IIterator;
import QFLib.Foundation;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Point;

import flash.utils.Dictionary;

import kof.framework.INetworking;
import kof.framework.events.CEventPriority;
import kof.framework.events.CRequestEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.buff.buffentity.IBuff;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CHitQueueSeq;
import kof.game.character.fight.sync.CSkillQueueSeq;
import kof.game.character.fight.sync.CSyncHitTargetEntity;
import kof.game.character.fight.sync.syncentity.CHitStateSync;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.fight.sync.synctimeline.ESyncStateType;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CMissileProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;
import kof.game.core.ITransform;
import kof.game.instance.IInstanceFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Common.AskRequest;
import kof.message.Fight.AskPropertyRequest;
import kof.message.Fight.CatchRequest;
import kof.message.Fight.DodgeRequest;
import kof.message.Fight.ExitSkillRequest;
import kof.message.Fight.FightMissileAbsorbRequest;
import kof.message.Fight.FightMissileActivateRequest;
import kof.message.Fight.FightMissileDeadRequest;
import kof.message.Fight.FightStateChangeRequest;
import kof.message.Fight.HealRequest;
import kof.message.Fight.HitRequest;
import kof.message.Fight.InterruptSkillRequest;
import kof.message.Fight.JumpInputRequest;
import kof.message.Fight.ReturnSkillConsumeRequest;
import kof.message.Fight.SkillCastRequest;
import kof.message.Fight.SummonRequest;
import kof.message.Map.SwitchHeroRequest;
import kof.message.Pvp.AddBufferRequest;
import kof.message.Pvp.ClientUpdateBuffRequest;
import kof.util.CAssertUtils;

public class CCharacterNetworkInput extends CSubscribeBehaviour {

    public function CCharacterNetworkInput( network : INetworking, instanceSystem : IInstanceFacade ) {
        super( "networkinput" );
        m_pNetworking = network;
        m_pInstancSys = instanceSystem;
    }

    override public function dispose() : void {
        super.dispose();
        dettackEventListener();
        dettackHostEventListner();

        m_pNetworking = null;
        m_pInstancSys = null;
        m_boAsHost = false;
    }

    override public function set enabled( value : Boolean ) : void {
        super.enabled = value;

        if ( enabled ) {
            this.attackEventListener();
        }
        else {
            this.dettackEventListener();
        }
    }

    override protected function onEnter() : void {
        super.onEnter();

        this.attackEventListener();
        this.attackHostEventListner();

        m_theHostHitStateSyncList = new _stateSyncIterator();
        m_thePuppetHitStateList = new _stateSyncIterator();
        m_localSkillQueue = new CSkillQueueSeq();
    }

    override protected function onExit() : void {
        super.onExit();
        dettackEventListener();
        dettackHostEventListner();

        if ( m_theHostHitStateSyncList )
            m_theHostHitStateSyncList.dispose();
        m_theHostHitStateSyncList = null;

        if ( m_thePuppetHitStateList )
            m_thePuppetHitStateList.dispose();
        m_thePuppetHitStateList = null;

        m_localSkillQueue = null;
        m_pNetworking = null;
        m_boAsHost = false;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
    }

    private function attackEventListener() : void {
        var pFightTriggle : CCharacterFightTriggle = getComponent( CCharacterFightTriggle ) as CCharacterFightTriggle;
        if ( pFightTriggle ) {
            pFightTriggle.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _onLocalSkillBegine, false, 0, true );
            pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_HIT, _onLocalHitTarget, false, 0, true );
            pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, _onSyncFightState );
            pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, _onSyncFightStateValue );
        }
    }

    private function dettackEventListener() : void {
        var pFightTriggle : CCharacterFightTriggle = getComponent( CCharacterFightTriggle ) as CCharacterFightTriggle;
        if ( pFightTriggle ) {
            pFightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN, _onLocalSkillBegine );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_HIT, _onLocalHitTarget );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, _onSyncFightState );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, _onSyncFightStateValue );
        }
    }

    private function attackHostEventListner() : void {
        if ( !owner || !owner.isRunning )
            return;

        if ( isAsHost ) {
            var pFightTriggle : CCharacterFightTriggle = getComponent( CCharacterFightTriggle ) as CCharacterFightTriggle;
            if ( pFightTriggle ) {
                pFightTriggle.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onEndToFight, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_HEAL, _onSyncHeal, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_DODGE, _onSyncDodge, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_JUMP, _onSyncJumpInput, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_ADDBUFF, _onSyncAddBuff, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_EFFECT, _onSyncDotEffect, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_CATCH, _onSyncCatchEffect, false, 0, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SYNC_SKILL_STATE, _onSyncState, false, 0, true );

//                pFightTriggle.addEventListener( CFightTriggleEvent.HERO_MISSILE_DEAD, _onMissileDeadRequest, false, 9, true );
                pFightTriggle.addEventListener( CFightTriggleEvent.HERO_MISSILE_ACTIVATE, _onMissileActivate );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_MISSILE_ABSORB, _onAbsorbMissile );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_SUMMON, _onSummon );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_ASK_PROPERTY, _onAskProperty );
                pFightTriggle.addEventListener( CFightTriggleEvent.REQUEST_RETURN_SKILL_CONSUME,_onReturnSkillConsume );
                pFightTriggle.addEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED , _onSkillInterrupted );
            }

            var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.addEventListener( CCharacterEvent.SWITCH_HERO, _onSwitchHeroRequest, false, CEventPriority.DEFAULT, true );
            }
        }
    }

    private function _hostBegineToFight( skillId : int, emitterIDs : Array, stateInfo : Object = null ) : void {
        var msg : SkillCastRequest = new SkillCastRequest();
        msg.ID = this.objID;
        msg.type = this.objType;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        stepSkillQueueID();
        resetSkillHitQueueID();
        resetSkillCatchQueueID();
        msg.queueID = skillQueueID;
        msg.skillID = skillId;
        //neet to sync the time
        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        pSyncBoard.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, owner.transform.z );
        pSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) );
        if ( stateInfo != null ) {
            pSyncBoard.setValue( CCharacterSyncBoard.SYNC_STATE, ESyncStateType.STATE_FIGHT );
            pSyncBoard.setValue( CCharacterSyncBoard.SYNC_SUB_STATES, stateInfo );
        }

        _SyncSpeedData();

        if ( emitterIDs != null && emitterIDs.length > 0 )
            pSyncBoard.setValue( CCharacterSyncBoard.EMITTER_IDS, emitterIDs );
        msg.dynamicStates = pSyncBoard.syncData;

        this.syncMsgCurrentTimeLine( EFighterActionType.E_SKILL_ACTION, msg );
        m_pNetworking.post( msg );

        pSyncBoard.clearAllDirty();
    }

    private function _SyncSpeedData() : void{
        /**
         * 同步动画速度主要是在空中的时候，有些技能释放同步到另外一端时，落地时间不一致，导致同步异常。！！地面的话就不用同步
          */
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay , true ) as IDisplay;
        var pStateBoard : CCharacterStateBoard = this.pStateBoard;
        if( pStateBoard && pStateBoard.getValue( CCharacterStateBoard.ON_GROUND )){
            return;
        }
        if( pSyncBoard && pDisplay && pDisplay.modelDisplay )
        {
            var currentVel : CVector3 = pDisplay.modelDisplay.velocityPerSec;
            if( currentVel == null || (currentVel.x == 0 && currentVel.y == 0 && currentVel.z == 0))
                    return;
            pSyncBoard.setValue( CCharacterSyncBoard.CURRENT_ANIMATION_SPEED , {
                "vx" : currentVel.x ,
                "vy" : currentVel.y,
                "vz" : currentVel.z });
        }
    }

    private function _puppetBegineToFight( skillID : int ) : void {
        m_localSkillQueue.stepQueueID();
        m_localSkillQueue.skillID = skillID;
        m_localSkillQueue.queueSeqTime = currentTimeForTimeline;
    }

    private function _onLocalSkillBegine( e : CFightTriggleEvent ) : void {
        var skillID : int = e.parmList[ 0 ];
        var emitters : Array = e.parmList[ 2 ];
        var stateInfo : Object = e.parmList[ 3 ];
        if ( isAsHost ) {
            _hostBegineToFight( skillID, emitters, stateInfo );
        } else
            _puppetBegineToFight( skillID );
    }

    private function _onLocalHitTarget( e : CFightTriggleEvent ) : void {
        var targetList : Vector.<CGameObject>;
        var hitID : int;
        var skillID : int;
        var isMissileHit : Boolean;
        var missileID : int;
        var missileSeq : int;
        if ( e.parmList ) {
            targetList = e.parmList[ 0 ] || null;
            hitID = e.parmList[ 1 ] || 0;
            skillID = e.parmList[ 2 ] || 0;
            isMissileHit = e.parmList[ 3 ] ? e.parmList[ 3 ] : false;
            missileID = e.parmList[ 4 ] ? e.parmList[ 4 ] : -1;
            missileSeq = e.parmList[ 5 ] >= 0 ? e.parmList[ 5 ] : -1;
        } else {
            targetList = null;
            hitID = 0;
            skillID = 0;
        }

        if ( isAsHost ) {
            _hostFightHit( targetList, hitID, skillID, isMissileHit, missileID, missileSeq );
        } else {
            _puppetFightHit( targetList, hitID, skillID, skillHitQueueID );
        }

    }

    private function dettackHostEventListner() : void {
        if ( !owner || !owner.isRunning )
            return;

        var pFightTriggle : CCharacterFightTriggle = getComponent( CCharacterFightTriggle ) as CCharacterFightTriggle;
        if ( pFightTriggle ) {
            pFightTriggle.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onEndToFight );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_DODGE, _onSyncDodge );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_HEAL, _onSyncHeal );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_JUMP, _onSyncJumpInput );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_ADDBUFF, _onSyncAddBuff );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_EFFECT, _onSyncDotEffect );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_CATCH, _onSyncCatchEffect );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_SKILL_STATE, _onSyncState );
//            pFightTriggle.removeEventListener( CFightTriggleEvent.HERO_MISSILE_DEAD, _onMissileDeadRequest );
            pFightTriggle.removeEventListener( CFightTriggleEvent.HERO_MISSILE_ACTIVATE, _onMissileActivate );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_MISSILE_ABSORB, _onAbsorbMissile );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_SUMMON, _onSummon );

            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_ASK_PROPERTY, _onAskProperty );
            pFightTriggle.removeEventListener( CFightTriggleEvent.REQUEST_RETURN_SKILL_CONSUME,_onReturnSkillConsume );
            pFightTriggle.removeEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED , _onSkillInterrupted );
        }

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.SWITCH_HERO, _onSwitchHeroRequest );
        }
    }

    private function _onSyncCatchEffect( event : CFightTriggleEvent ) : void {
        var msg : CatchRequest = new CatchRequest();
        msg.ID = this.objID;
        msg.type = objType;

        var pSkillCaster : CSkillCaster = this.getComponent( CSkillCaster ) as CSkillCaster;
        msg.skillID = pSkillCaster.skillID;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.catchQueueID = skillCatchQueueID;

        var targetList : Vector.<CGameObject>;
        var retList : Array = [];
        var catchTime : Number;
        var catchMoveDir : int;

        if ( event.parmList ) {
            targetList = event.parmList[ 0 ] || null;
            msg.catchId = event.parmList[ 1 ] || 0;
            msg.bCatchEnd = event.parmList[ 2 ] || 0;
            catchTime = event.parmList[ 3 ] || 0.0;
            catchMoveDir = event.parmList[ 4 ] || 0;
        } else {
            retList = [];
            msg.catchId = 0;
        }

        var targetData : Object;
        var t_dynamicStates : Object;
        for each( var target : CGameObject in targetList ) {
            if ( target && target.isRunning ) {
                var t_pSyncBoard : CCharacterSyncBoard =
                        target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;

                if ( t_pSyncBoard && catchTime > 0 ) {
                    t_dynamicStates = {};
                    var theSubStates : Object = {};
                    theSubStates[ ESyncStateType.SUB_UNCONTROL_BECATCH ] = catchTime;
                    t_dynamicStates[ CCharacterSyncBoard.SYNC_STATE ] = ESyncStateType.STATE_UNCONTROL;
                    t_dynamicStates[ CCharacterSyncBoard.SYNC_SUB_STATES ] = theSubStates;
                }

                targetData = _decodeTargetListObj( target, false );
                if ( targetData ) {
                    targetData[ "dynamicStates" ] = t_dynamicStates == null ? {} : t_dynamicStates ;
                    retList.push( targetData );
                }
            }
        }

        msg.targets = retList;
        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        if ( catchMoveDir != 0 )
            pSyncBoard.setValue( CCharacterSyncBoard.CATCH_MOVE_DIR, catchMoveDir );
        msg.dynamicStates = pSyncBoard.syncData;

        this.syncMsgCurrentTimeLine( EFighterActionType.E_CATCH_ACTION, msg );
        m_pNetworking.post( msg );

        pSyncBoard.clearAllDirty();
    }

    private function _onSyncState( event : CFightTriggleEvent ) : void {
        var params : Array;
        var msg : FightStateChangeRequest = new FightStateChangeRequest();
        params = event.parmList;
        msg.ID = objID;
        msg.type = objType;
        msg.state = params[ 0 ];
        msg.subStates = params[ 1 ];
        msg.skillID = params[ 2 ];
        msg.queueSeqTime = pFightTimeLineFacade.currentLineTime;
        m_pNetworking.post( msg );
    }

    private function _onMissileDeadRequest( event : CFightTriggleEvent ) : void {
        var msg : FightMissileDeadRequest = new FightMissileDeadRequest();
        var skillId : int = event.parmList[ 1 ];
        var missileID : int = event.parmList[ 0 ];
        msg.type = objType;
        msg.ID = objID;
        msg.skillId = skillId;
        msg.missileId = missileID;
        m_pNetworking.post( msg );
    }

    private function _onAbsorbMissile( event : CFightTriggleEvent ) : void {
        var msg : FightMissileAbsorbRequest = new FightMissileAbsorbRequest();
        msg.ID = objID;
        msg.type = objType;
        var dynamicObj : Object = {};
        dynamicObj[ "target" ] = _decodeMissiles( event.parmList[ 1 ] );
        dynamicObj[ "absorbID" ] = event.parmList[ 0 ];
        dynamicObj[ CCharacterSyncBoard.QUEUE_SEQ_TIME ] = currentTimeForTimeline;
        msg.dynamicStates = dynamicObj;
        m_pNetworking.post( msg );
    }

    private function _onSummon( event : CFightTriggleEvent ) : void {
        var msg : SummonRequest = new SummonRequest();
        var summonId : int = event.parmList[ 0 ];
        var summonPosition : CVector3 = event.parmList[ 1 ];
        var dir : int = event.parmList[ 2 ];
        msg.posX = summonPosition.x;
        msg.posY = summonPosition.y;
        msg.posH = summonPosition.z;
        msg.ID = objID;
        msg.type = objType;
        msg.sid = summonId;
        msg.direction = dir;

        m_pNetworking.post( msg );
    }

    private function _onAskProperty( event : CFightTriggleEvent ) : void {

        var msg : AskPropertyRequest = new AskPropertyRequest();
        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2;
        if ( pTransform )
            screenAxis = pTransform.to2DAxis();

        var time : Number = event.parmList ? event.parmList[ 0 ] : 0.0;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.ID = objID;
        msg.type = objType;
        msg.time = time;

        var theInputComp : CCharacterInput = pInput;
        if( theInputComp ) {
            msg.dirX = theInputComp.wheel.x;
            msg.dirY = theInputComp.wheel.y;
        }else{
            msg.dirX = 0;
            msg.dirY = 0;
        }

        msg.dynamicStates = null;

        m_pNetworking.post( msg );
    }

    private function _onReturnSkillConsume( event : CFightTriggleEvent ) : void{
        var msg : ReturnSkillConsumeRequest = new ReturnSkillConsumeRequest();
        msg.ID = objID;
        msg.type = objType;
        msg.skillID = event.parmList[0];
        msg.dynamicStates = null;
        m_pNetworking.post( msg );
    }

    private function _onSkillInterrupted( event : CFightTriggleEvent ) : void{
        var msg : InterruptSkillRequest = new InterruptSkillRequest();
        msg.ID = objID;
        msg.type = objType;
        msg.skillID = event.parmList[0];
        msg.dynamicStates = null;
        m_pNetworking.post( msg );
    }

    private function _decodeMissiles( missiles : Array ) : Array {
        var ret : Array = [];
        var targetInfo : Object;
        for each ( var target : CGameObject in missiles ) {
            targetInfo = {};
            var pMissileProperty : CMissileProperty = target.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
            var pMissileTransform : CKOFTransform = target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            var iScreenAxis : CVector2 = pMissileTransform.to2DAxis();
            if ( iScreenAxis ) {
                targetInfo.posX = iScreenAxis.x;
                targetInfo.posY = iScreenAxis.y;
            }

            targetInfo[ "missileSeq" ] = pMissileProperty.missileSeq;

            ret.push( targetInfo );
        }

        if ( ret.length == 0 )
            return null;
        return ret;
    }

    private function _onMissileActivate( event : CFightTriggleEvent ) : void {
        var msg : FightMissileActivateRequest = new FightMissileActivateRequest();
        var missileID : int = event.parmList[ 0 ];
        var emiiterID : int = event.parmList[ 1 ];
        var position : CVector3 = event.parmList[ 2 ];

        msg.ID = objID;//spellerID;
        msg.type = objType;//spellerType;
        msg.missileId = missileID;
        var dynamicStates : Object = {};
        dynamicStates[ "emitterID" ] = emiiterID;
        dynamicStates[ "posX" ] = position.x;
        dynamicStates[ "posY" ] = position.y;
        dynamicStates[ "posZ" ] = position.z;
        dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ] = currentTimeForTimeline;
        msg.dynamicStates = dynamicStates;
        m_pNetworking.post( msg );
    }

    private function _onSyncDotEffect( event : CFightTriggleEvent ) : void {
        var msg : ClientUpdateBuffRequest = new ClientUpdateBuffRequest();
        msg.targetId = this.objID;
        msg.targetType = this.objType;
        msg.effectId = event.parmList[ 0 ] || 0;
        msg.buffId = event.parmList[ 1 ] || 0;
        msg.destTargets = event.parmList[ 2 ] || null;
        msg.randomSeed = event.parmList[ 3 ] || 0;

        m_pNetworking.post( msg );
    }

    private function _onSwitchHeroRequest( event : CRequestEvent ) : void {
        var idHero : int = int( event.data );
        if ( idHero <= 0 )
            Foundation.Log.logWarningMsg( "Switching HERO with invalid ID: " + idHero );

        var msg : SwitchHeroRequest = this.m_pNetworking.getMessage( SwitchHeroRequest ) as SwitchHeroRequest;
        if ( msg ) {
            msg.ID = idHero;
            this.m_pNetworking.send( msg );
        }
    }

    protected function _onBeginToFight( e : CFightTriggleEvent = null ) : void {
        var msg : SkillCastRequest = new SkillCastRequest();
        msg.ID = this.objID;
        msg.type = this.objType;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        stepSkillQueueID();
        msg.skillID = e.parmList[ 0 ]; //.skillID;
        msg.queueID = skillQueueID;
        //neet to sync the time
        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        pSyncBoard.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, owner.transform.z );
        pSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) );
        msg.dynamicStates = pSyncBoard.syncData;

        this.syncMsgCurrentTimeLine( EFighterActionType.E_SKILL_ACTION, msg );
        m_pNetworking.post( msg );

        pSyncBoard.clearAllDirty();
    }

    protected function _onSyncHeal( e : CFightTriggleEvent = null ) : void {
        var msg : HealRequest = new HealRequest();
        msg.ID = this.objID;
        msg.type = objType;
        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.skillID = e.parmList[ 0 ] || 0;
        msg.healID = e.parmList[ 1 ] || 0;

        msg.targets = e.parmList[ 2 ] || null;
        var missileSeq : Number = e.parmList[ 3 ] || 0;
        msg.dynamicStates = {};
        msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ] = currentTimeForTimeline;
        if ( missileSeq > 0 )
            msg.dynamicStates[ "missileSeq" ] = missileSeq;

        m_pNetworking.post( msg );
    }

    protected function _onEndToFight( e : CFightTriggleEvent = null ) : void {
        var msg : ExitSkillRequest = new ExitSkillRequest();
        msg.ID = this.objID;
        msg.type = objType;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;
        msg.skillID = e.parmList[ 0 ];
        msg.queueID = skillQueueID;
        pSyncBoard.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, owner.transform.z );
        pSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) );
        pSyncBoard.setValue( CCharacterSyncBoard.SKILL_DIR, pStateBoard.getValue( CCharacterStateBoard.DIRECTION ).x );
        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        msg.dynamicStates = pSyncBoard.syncData;

        this.syncMsgCurrentTimeLine( EFighterActionType.E_SKILL_END_ACTION, msg );
        m_pNetworking.post( msg );

        pSyncBoard.clearAllDirty();
    }

    protected function _onSyncFightHit( e : CFightTriggleEvent ) : void {
        var msg : HitRequest = new HitRequest();
        msg.ID = this.objID;
        msg.type = objType;

        var targetList : Vector.<CGameObject>;
        var retList : Array = [];

        if ( e.parmList ) {
            targetList = e.parmList[ 0 ] || null;
            msg.hitId = e.parmList[ 1 ] || 0;
            msg.skillID = e.parmList[ 2 ] || 0;
        } else {
            retList = [];
            msg.hitId = 0;
            msg.skillID = 0;
        }

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;

        for each( var target : CGameObject in targetList ) {
            retList.push( _decodeTargetListObj( target ) );
        }

        msg.targets = retList;
        msg.selfBuffIndex = _decodeBuffList( owner );
        msg.dynamicStates = _decodeDynamicState( owner );

        this.syncMsgCurrentTimeLine( EFighterActionType.E_HIT_ACTION, msg );
        m_pNetworking.post( msg );
        pSyncBoard.clearAllDirty();

    }

    private function _hostFightHit( targetList : Vector.<CGameObject>, hitID : int, skillID : int,
                                    isMissilehit : Boolean = false, missileID : int = -1, missileSeq : int = -1 ) : void {
        var msg : HitRequest = new HitRequest();
        msg.ID = this.objID;
        msg.type = objType;

        var hitTargetList : Vector.<CGameObject> = targetList;
        var myHitID : int = hitID;
        var mySkillID : int = skillID;
        var retList : Array = [];

        msg.hitId = myHitID;
        msg.skillID = mySkillID;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;

        for each( var target : CGameObject in hitTargetList ) {
            retList.push( _decodeTargetListObj( target ) );
        }

        msg.targets = retList;
        msg.selfBuffIndex = _decodeBuffList( owner );
        msg.dynamicStates = _decodeDynamicState( owner );
        msg.dynamicStates[ 'isMissile' ] = isMissilehit;
        if ( missileID > 0 ) {
            msg.dynamicStates[ "missileID" ] = missileID;
            msg.dynamicStates[ "missileSeq" ] = missileSeq;
        }

        this.syncMsgCurrentTimeLine( EFighterActionType.E_HIT_ACTION, msg );
        m_pNetworking.post( msg );
        pSyncBoard.clearAllDirty();
    }

    private function _puppetFightHit( targetList : Vector.<CGameObject>, hitID : int, hitQueueID : int, skillHitQueueID : int ) : void {
        syncPuppetHit( hitID, targetList, hitQueueID, skillHitQueueID );
    }

    protected function _decodeDynamicState( target : CGameObject ) : Object {
        var dynamicStates : Object;
        var tSyncBoard : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        tSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );

        var fightComp : CFightCalc = target.getComponentByClass( CFightCalc, true ) as CFightCalc;
        if ( tSyncBoard && fightComp )
            tSyncBoard.setValue( CCharacterSyncBoard.CONTINUE_HIT_COUNT, fightComp.otherFightCalc.ContinusHit );

        dynamicStates = pSyncBoard.syncData;
        if ( CCharacterDataDescriptor.isMissile( target.data ) ) {
            var masterComp : CMasterCompomnent = target.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            dynamicStates.ownerID = masterComp.ownerId;
            dynamicStates.ownerType = masterComp.ownerType;
        }
        dynamicStates.skillHitQueueID = this.skillHitQueueID;

        return dynamicStates;
    }

    protected function _decodeBuffList( target : CGameObject ) : Array {
        var buffComp : CBuffContainer = target.getComponentByClass( CBuffContainer, true ) as CBuffContainer;
        if ( buffComp == null )
            return [];

        var iterator : IIterator = buffComp.getIterator();
        var buffList : Array = [];
        var buff : IBuff;
        while ( iterator.hasNext() ) {
            buff = iterator.next() as IBuff;
            buffList.push( buff.buffId );
        }

        return buffList;
    }

    protected function _onSyncAddBuff( e : CFightTriggleEvent ) : void {
        /**
         * bufferId
         * targets [(targetId1, type), (targetId2, type), (targetId3, type)......]
         */
        var msg : AddBufferRequest = new AddBufferRequest();
        var param : Array = e.parmList;
        CAssertUtils.assertNotNaN( param[ 0 ] );
        msg.type = objType;
        msg.srcId = objID;
        msg.emitBuffId = param[ 0 ] || 0;
        msg.hitTarget = param[ 1 ] || [];
        m_pNetworking.post( msg );
    }

    private function _onSyncDodge( e : CFightTriggleEvent ) : void {
        var msg : DodgeRequest = new DodgeRequest();
        msg.ID = this.objID;
        msg.type = objType;

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        var screenAxis : CVector2 = pTransform.to2DAxis();

        msg.dirX = pInput.wheel.x;
        msg.dirY = pInput.wheel.y;
        msg.posX = screenAxis.x;
        msg.posY = screenAxis.y;

        msg.queueID = skillQueueID;
        //need to sync the time
        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        pSyncBoard.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, owner.transform.z );
        pSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) );
        msg.dynamicStates = pSyncBoard.syncData;
        syncMsgCurrentTimeLine( EFighterActionType.E_DODGE_ACTION, msg );
        m_pNetworking.post( msg );
        pSyncBoard.clearAllDirty();
    }

    public function syncPuppetHit( hitID : int, targetInfo : Vector.<CGameObject>, hitQueueID : int, skillHitQueueID : int ) : void {
        var pHitSyncState : CHitStateSync;
        if ( targetInfo ) {
            pHitSyncState = allocateNextPuppetHitStateSync( hitQueueID );
        }

        if ( pHitSyncState ) {
            pHitSyncState.setSkillQueue( m_localSkillQueue.queueID, m_localSkillQueue.skillID );
        }

        pHitSyncState.setHitQueue( hitQueueID, hitID, targetInfo, skillHitQueueID );
    }

    public function syncFromHostHit( hitID : int, hitQueueID : int, targetList : Vector.<CGameObject>, skillHitQueueID : int ) : void {
        var pHitSyncState : CHitStateSync;
        if ( targetList ) {
            pHitSyncState = allocateHostNextHitStateSync( hitQueueID );//allocateNextPuppetHitStateSync( hitQueueID );
        }

        if ( pHitSyncState ) {
            pHitSyncState.setSkillQueue( m_localSkillQueue.queueID, m_localSkillQueue.skillID );
        }

        pHitSyncState.setHitQueue( hitQueueID, hitID, targetList, skillHitQueueID );
    }

    public function syncInputHit( hitID : int, targetInfo : Dictionary, queueID : int, skillID : int,
                                  tickTime : Number, boIsNetwork : Boolean ) : void {
        return;
        var hitInfo : Dictionary = targetInfo || null;
        if ( hitInfo ) {
            var pHitSync : CHitStateSync;
            if ( boIsNetwork )
                pHitSync = allocateHostNextHitStateSync( queueID );
            else
                pHitSync = allocateNextPuppetHitStateSync( queueID );

            var pHitQueueSeq : CHitQueueSeq = new CHitQueueSeq();
            pHitQueueSeq.queueID = queueID;
            pHitQueueSeq.hitID = hitID;
            pHitQueueSeq.skillID = skillID;
            pHitQueueSeq.queueSeqTime = tickTime;
            pHitSync.targetListInfo = hitInfo;
            pHitSync.hitQueueSeq = pHitQueueSeq;
        }
    }

    private function _onSyncJumpInput( e : CFightTriggleEvent ) : void {
        var msg : JumpInputRequest = new JumpInputRequest();
        msg.ID = this.objID;
        msg.type = this.objType;

        var pInput : CCharacterInput = owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( pInput ) {
            msg.dirX = pInput.wheel.x;
            msg.dirY = pInput.wheel.y;
        }
        else {
            msg.dirX = 0;
            msg.dirY = 0;
        }

        pSyncBoard.setValue( CCharacterSyncBoard.QUEUE_SEQ_TIME, currentTimeForTimeline );
        msg.dynamicStates = pSyncBoard.syncData;

        this.syncMsgCurrentTimeLine( EFighterActionType.E_JUMP_ACTION, msg );
        m_pNetworking.post( msg );

        pSyncBoard.clearAllDirty();
    }

    private function _onSyncFightState( e : CFightTriggleEvent ) : void {
        var paramList : Array = e.parmList;
        if ( paramList == null ) {
            Foundation.Log.logWarningMsg( "on fight: you must specify a state to sync" );
            return;
        }

        for each( var key : String in paramList ) {
            switch ( key ) {
                case  CCharacterSyncBoard.RAGE_POWER :
                    pSyncBoard.setValue( CCharacterSyncBoard.RAGE_POWER, pCharacterProperty.RagePower );
                    break;
                case CCharacterSyncBoard.ATTACK_POWER :
                    pSyncBoard.setValue( CCharacterSyncBoard.ATTACK_POWER, pCharacterProperty.AttackPower );
                    break;
                case CCharacterSyncBoard.MAX_ATTACK_POWER:
                    pSyncBoard.setValue( CCharacterSyncBoard.MAX_ATTACK_POWER, pCharacterProperty.MaxAttackPower );
                    break;
                case CCharacterSyncBoard.DEFENSE_POWER :
                    pSyncBoard.setValue( CCharacterSyncBoard.DEFENSE_POWER, pCharacterProperty.DefensePower );
                    break;
                case CCharacterSyncBoard.MAX_DEFENSE_POWER:
                    pSyncBoard.setValue( CCharacterSyncBoard.MAX_DEFENSE_POWER, pCharacterProperty.MaxDefensePower );
                    break;
                case CCharacterSyncBoard.BO_COUNTER:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_COUNTER, pStateBoard.getValue( CCharacterStateBoard.COUNTER ) );
                    break;
                case CCharacterSyncBoard.BO_CRITICAL_COUNTER:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_CRITICAL_COUNTER, pStateBoard.getValue( CCharacterStateBoard.CRITICAL_HIT_COUNTER ) );
                    break;
                case CCharacterSyncBoard.BO_GUARD:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_GUARD, pStateBoard.getValue( CCharacterStateBoard.IN_GUARD ) );
                    break;
                case CCharacterSyncBoard.BO_PA_BODY:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_PA_BODY, pStateBoard.getValue( CCharacterStateBoard.PA_BODY ) );
                    break;
                case CCharacterSyncBoard.BO_CRITICAL_HIT:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_CRITICAL_HIT, pStateBoard.getValue( CCharacterStateBoard.CRITICAL_HIT ) );
                    break;
                case CCharacterSyncBoard.BO_ON_GROUND:
                    pSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) );
                    break;
                case CCharacterSyncBoard.SKILL_CD_LIST:
                    var fightCal : CFightCalc = owner.getComponentByClass( CFightCalc, true ) as CFightCalc;
                    fightCal.syncFrom();
                    break;
                case CCharacterSyncBoard.HIT_BUFF_LIST:
                    pSyncBoard.setValue( CCharacterSyncBoard.HIT_BUFF_LIST, _decodeBuffList( owner ) );
                    break;
                case CCharacterSyncBoard.SKILL_DIR:
                    var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                    pSyncBoard.setValue( CCharacterSyncBoard.SKILL_DIR, dir.x );
                    break;
                default:
                    Foundation.Log.logTraceMsg( " UnHandle type for SyncBoard !! type = " + key );
                    break;
            }
        }
    }

    private function _onSyncFightStateValue( e : CFightTriggleEvent ) : void {
        var paramList : Array = e.parmList;
        if ( paramList == null ) {
            Foundation.Log.logWarningMsg( "on fight: you must specify a state to sync" );
            return;
        }

        var key : String = paramList[ 0 ];
        var value : * = paramList[ 1 ];

        switch ( key ) {
            case  CCharacterSyncBoard.DAMAGE_HURT :
                pSyncBoard.setValue( CCharacterSyncBoard.DAMAGE_HURT, value );
                break;
            case CCharacterSyncBoard.CURRENT_HP:
                pSyncBoard.setValue( CCharacterSyncBoard.CURRENT_HP, value );
                break;
            case CCharacterSyncBoard.HIT_EFFECT_POINT:
                var pos : CVector3 = paramList[ 1 ] as CVector3;
                if ( pos != null )
                    pSyncBoard.setValue( CCharacterSyncBoard.HIT_EFFECT_POINT, {
                        "fx" : pos.x,
                        "fy" : pos.y,
                        "fz" : pos.z
                    } );
                break;
            case CCharacterSyncBoard.BO_QUICKSTANDCOST:
                pSyncBoard.setValue( CCharacterSyncBoard.BO_QUICKSTANDCOST, value );
                break;
            case CCharacterSyncBoard.BO_DRIVEROLLCOST:
                pSyncBoard.setValue( CCharacterSyncBoard.BO_DRIVEROLLCOST, value );
                break;
            case CCharacterSyncBoard.HIT_MOTION_RADIO:
                pSyncBoard.setValue( CCharacterSyncBoard.HIT_MOTION_RADIO, value );
                break;
            case CCharacterSyncBoard.ATTACK_POWER_DELTA:
            case CCharacterSyncBoard.MAX_ATTACK_POWER:
            case CCharacterSyncBoard.MAX_DEFENSE_POWER:
            case CCharacterSyncBoard.DEFENSE_POWER_DELTA:
            case CCharacterSyncBoard.SYNC_STATE:
            case CCharacterSyncBoard.SYNC_SUB_STATES:
                pSyncBoard.setValue( key, value );
                break;
            case CCharacterSyncBoard.MOTION_ID:
                pSyncBoard.setValue( key , value);
                break;
            default:
                break;
        }
    }

    private function _decodeTargetListObj( target : CGameObject, bDecodeSyncBoard : Boolean = true ) : Object {
        var syncInfo : CSyncHitTargetEntity;

        if ( target == null || !target.isRunning )
            return null;

        syncInfo = new CSyncHitTargetEntity();
        syncInfo.ID = CCharacterDataDescriptor.getID( target.data );
        syncInfo.type = CCharacterDataDescriptor.getType( target.data );

        var iTransform : CKOFTransform = target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        if ( iTransform ) {
            var iScreenAxis : CVector2 = iTransform.to2DAxis();
            if ( iScreenAxis ) {
                syncInfo.posX = iScreenAxis.x;
                syncInfo.posY = iScreenAxis.y;
            }
        }

        var pNetMediator : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( pNetMediator )
            syncInfo.queueID = pNetMediator.hitQueueID;

        var pSyncComp : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
//        if ( pSyncComp )
//            pSyncComp.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, target.transform.z );

        var fightComp : CFightCalc = target.getComponentByClass( CFightCalc, true ) as CFightCalc;
        if ( pSyncComp && fightComp )
            pSyncComp.setValue( CCharacterSyncBoard.CONTINUE_HIT_COUNT, fightComp.otherFightCalc.ContinusHit );

        if ( pSyncComp )
            syncInfo.dynamicStates = pSyncComp.syncData;
        else
            syncInfo.dynamicStates = {};

        var ret : Object = syncInfo.toObj();

        if ( pSyncComp && bDecodeSyncBoard )
            pSyncComp.clearAllDirty();

        return ret;
    }

    public function get skillQueueID() : Number {
        return m_queueID;
    }

    public function get hitQueueID() : Number {
        return m_hitQueueID;
    }

    public function stepSkillQueueID() : void {
        m_queueID++;
    }

    public function get skillHitQueueID() : int {
        return m_nSkillHitQueueID;
    }

    public function get skillCatchQueueID() : int {
        return m_nSkillCatchQueueID;
    }

    public function stepSkillCatchQueueID() : int {
        return m_nSkillCatchQueueID++;
    }

    public function set skillCatchIndexID( count : int ) : void {
        this.m_nSkillCatchQueueID = count;
    }

    public function resetSkillCatchQueueID() : int {
        return m_nSkillCatchQueueID = 1;
    }

    //单个技能的hitqueuID;
    public function stepSkillHitQueueID() : void {
        m_nSkillHitQueueID++;
    }

    public function resetSkillHitQueueID() : void {
        m_nSkillHitQueueID = 1;
    }

    public function syncSkillQueueID( value : Number ) : void {
        m_queueID = value;
    }

    public function syncHitQueueID( value : Number ) : void {
        m_hitQueueID = value;
    }

    //全局的hitID
    public function stepHitQueueID() : void {
        m_hitQueueID = m_hitQueueID + 1;
    }

    private function allocateHostNextHitStateSync( queueID : Number ) : CHitStateSync {
        var hitSync : CHitStateSync;

        hitSync = m_theHostHitStateSyncList.popElement();
        if ( hitSync == null ) {
            hitSync = new CHitStateSync();
            m_theHostHitStateSyncList.pushElement( hitSync );
            return hitSync;
        } else {
            hitSync.reset();
            return hitSync;
        }

    }

    private function allocateNextPuppetHitStateSync( queueID : Number ) : CHitStateSync {
        var hitSync : CHitStateSync;

        hitSync = m_thePuppetHitStateList.popElement();
        if ( hitSync == null ) {
            hitSync = new CHitStateSync();
            m_thePuppetHitStateList.pushElement( hitSync );
            return hitSync;
        } else {
            hitSync.reset();
            return hitSync;
        }

    }

    private function syncMsgCurrentTimeLine( type : int, msg : CAbstractPackMessage ) : void {
        var pTimeLineFacade : CFightTimeLineFacade;
        pTimeLineFacade = owner.getComponentByClass( CFightTimeLineFacade, true ) as CFightTimeLineFacade;
        if ( !pTimeLineFacade || !pTimeLineFacade.bStarted )
            return;

        if(pLevelMediator.isPVE)
                return;

        pTimeLineFacade.insertMsgAtCurrentTime( type, msg );
    }

    public function getSyncHitStateByID( hitQueueId : int ) : CHitStateSync {
        return m_theHostHitStateSyncList.find( hitQueueId );
    }

    public function getLocalHitStateByID( hitQueueID : int ) : CHitStateSync {
        return m_thePuppetHitStateList.find( hitQueueID );
    }

    public function getPuppetHitBySkillQueue( skillQueueID : Number, hitID : int ) : Vector.<CHitStateSync> {
        return m_thePuppetHitStateList.findSpecifyHitsInfoList( skillQueueID, hitID );
    }

    public function getHostHitBySkillQueue( skillQueueID : Number, hitID : int ) : Vector.<CHitStateSync> {
        return m_theHostHitStateSyncList.findSpecifyHitsInfoList( skillQueueID, hitID );
    }

    final private function get pInput() : CCharacterInput {
        return this.getComponent( CCharacterInput ) as CCharacterInput;
    }

    final private function get pSceneFacade() : CSceneMediator {
        return this.getComponent( CSceneMediator ) as CSceneMediator;
    }

    final private function get pSkillCaster() : CSkillCaster {
        return this.getComponent( CSkillCaster ) as CSkillCaster;
    }

    final private function get levelMediator() : CLevelMediator {
        return this.getComponent( CLevelMediator ) as CLevelMediator;
    }

    public function get isAsHost() : Boolean {
        return m_boAsHost;
    }

    final public function set isAsHost( value : Boolean ) : void {
        if ( this.m_boAsHost == value )
            return;
        this.m_boAsHost = value;

        if ( value ) {
            attackHostEventListner();
        } else {
            dettackHostEventListner();
        }
    }

    final public function get isAsPuppet() : Boolean {
        var pLevelMediator : CLevelMediator = pLevelMediator;
        return !isAsHost || (pLevelMediator && pLevelMediator.isPVE);
    }

//    final public function get isAsPuppet() : Boolean {
//        return  !isAsHost &&
//                CCharacterDataDescriptor.isPlayer( owner.data ) &&
//                !CCharacterDataDescriptor.isRobot( owner.data );
//    }

    final public function get pCharacterProperty() : ICharacterProperty {
        return this.getComponent( ICharacterProperty ) as ICharacterProperty;
    }

    final public function get pStateBoard() : CCharacterStateBoard {
        return this.getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
    }

    final public function get pSyncBoard() : CCharacterSyncBoard {
        return this.getComponent( CCharacterSyncBoard ) as CCharacterSyncBoard;
    }

    final public function get pLevelMediator() : CLevelMediator {
        return this.getComponent( CLevelMediator ) as CLevelMediator;
    }

    final private function get objID() : Number {
        return (this.getComponent( ICharacterProperty ) as ICharacterProperty).ID;
    }

    final public function get pFightTimeLineFacade() : CFightTimeLineFacade {
        return this.getComponent( CFightTimeLineFacade ) as CFightTimeLineFacade;
    }

    final private function get objType() : int {
        var type : int = CCharacterDataDescriptor.getType( owner.data );
        return type;
    }

    final private function get currentTimeForTimeline() : Number {
        return pFightTimeLineFacade.currentLineTime;
    }

    public function get localSkillQueue() : CSkillQueueSeq {
        return m_localSkillQueue;
    }

    public function setLocalSkillQueueDirect( queueID : int, skillID : int, time : Number ) : void {
        m_localSkillQueue.queueID = queueID;
        m_localSkillQueue.skillID = skillID;
        m_localSkillQueue.queueSeqTime = time;
    }

    private var m_pNetworking : INetworking;
    private var m_pInstancSys : IInstanceFacade;
    private var m_boAsHost : Boolean;

    private var m_queueID : Number = 1;
    private var m_hitQueueID : Number = 1;

    private var m_localSkillQueue : CSkillQueueSeq;

    private var m_nSkillHitQueueID : int = 1;
    private var m_nSkillCatchQueueID : int = 1;
    //
    private var m_theHostHitStateSyncList : _stateSyncIterator;
    private var m_thePuppetHitStateList : _stateSyncIterator;
}
}

import kof.game.character.fight.sync.syncentity.CHitStateSync;

class _stateSyncIterator {
    private var _list : Vector.<CHitStateSync>;
    private var _curCursor : int = 0;

    public function _stateSyncIterator( maxLength : int = 100 ) : void {
        _list = new Vector.<CHitStateSync>( maxLength );
    }

    public function pushElement( obj : CHitStateSync ) : void {
        _list[ _curCursor++ ] = obj;
        if ( _curCursor == _list.length )
            _curCursor = 0;
    }

    public function popElement() : CHitStateSync {
        return _list[ _curCursor ];
    }

    public function dispose() : void {
        if ( _list ) {
            _list.splice( 0, _list.length );
        }
        _list = null;
        _curCursor = 0;
    }

    public function find( queueID : Number ) : CHitStateSync {
        var target : CHitStateSync;
        for ( var i : int = 0; i < _list.length; i++ ) {
            target = _list[ i ];
            if ( target ) {
                if ( target.hitQueueSeq.queueID == queueID )
                    return target;
            }
        }
        return null;
    }

    public function findHitsList( skillQueueID : Number ) : Vector.<CHitStateSync> {
        var ret : Vector.<CHitStateSync> = new <CHitStateSync>[];
        var target : CHitStateSync;
        for ( var i : int = 0; i < _list.length; i++ ) {
            target = _list[ i ];
            if ( target && target.skillQueueID == skillQueueID ) {
                ret.push( target );
            }
        }
        return ret;
    }

    public function findSpecifyHitsInfoList( skillQueueID : Number, hitId : int ) : Vector.<CHitStateSync> {
        var ret : Vector.<CHitStateSync> = new <CHitStateSync>[];
        var target : CHitStateSync;
        for ( var i : int = 0; i < _list.length; i++ ) {
            target = _list[ i ];
            if ( target && target.skillQueueID == skillQueueID && target.hitID == hitId ) {
                ret.push( target );
            }
        }
        return ret;
    }
}
