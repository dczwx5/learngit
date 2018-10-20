//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Framework.CObject;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.utils.Dictionary;

import kof.framework.fsm.CFiniteStateMachine;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.CSkillInterruptList;
import kof.game.character.CTarget;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CFightTextConst;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.CFightOthersCalc;
import kof.game.character.fight.skillcalc.CPropertyRecovery;
import kof.game.character.fight.skillcalc.ECalcStateRet;
import kof.game.character.fight.skillcalc.ERPRecoveryType;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.CAbstractSkillEffect;
import kof.game.character.fight.skilleffect.util.CSkillScreenIns;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.syncentity.CHitStateSync;
import kof.game.character.fight.sync.synctimeline.ESyncStateType;
import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMissileProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterDodgeState;
import kof.game.character.state.CCharacterKnockUpState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Damage;
import kof.table.Hit;
import kof.table.Motion;
import kof.table.Motion.EMotionType;
import kof.table.Motion.EMotionType;
import kof.table.Motion.ETransWay;

public class CSkillHit extends CAbstractSkillEffect {
    public function CSkillHit( id : int, startFrame : Number, hitEvent : String, et : int, des : String = "" ) {
        super( id, startFrame, hitEvent, et, des );
        m_collisionTargetList = [];
        m_collidedAreaList = [];
        m_targetDic = new Dictionary();
    }

    override public function initData( ... args ) : void {
        if ( args == null ) return;
        var skillCtx : CComponentUtility = args[ 0 ] as CComponentUtility;

        this.m_pSkillContex = skillCtx;
        m_pLevelMediator = m_pSkillContex.owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
        hitData = CSkillCaster.skillDB.getHitDataByID( effectID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );

        if ( m_pSkillContex.pFightCalc ) {
            var fCalc : CFightOthersCalc = m_pSkillContex.pFightCalc.otherFightCalc;
            if ( fCalc ) {
                if ( fCalc.boResetNext ) {
                    fCalc.resetCHit();
                    fCalc.boResetNext = true;
                }
            }

        }
    }

    public function hitTargetDirectly( targets : Array, collisedArea : Array = null,
                                       bIgnoreGuard : Boolean = false, hitPosition : Array = null, distanceDiscrease : Array = null ) : void {
        m_pSpecifyTargets = targets;
        m_pSpecifyHitAeras = collisedArea;
        m_bSpecifyGuardIgnored = bIgnoreGuard;
        m_pSpecifyHitPosition = hitPosition;
        m_pDistanceDiscreaseList = distanceDiscrease;
        m_boHitDirectly = true;
    }

    public function HostHitTargetDirectly( targets : Array, skillHitQueueId : int, boIngoreGuard : Boolean = false,
                                           hitPosition : Array = null, distanceDiscreaseList : Array = null,
                                           damageInfo : Array = null , missileSeq : int = -1 , skillID : int = -1) : void {
        boSyncEffect = true;
        m_pSpecifyTargets = targets;
        m_bSpecifyGuardIgnored = boIngoreGuard;
        m_pSpecifyHitPosition = hitPosition;
        m_pDistanceDiscreaseList = distanceDiscreaseList;
        m_damgeInfoList = damageInfo;
        m_boHitDirectly = true;
        m_boHostDirectly = true;
        m_missileSeq = missileSeq;
        m_nCurrentSkillID = skillID;
    }

    override public function dispose() : void {

        m_isValid = false;
        hitData = null;
        if ( m_collisionTargetList )
            this.m_collisionTargetList.splice( 0, m_collisionTargetList.length );
        m_collisionTargetList = null;

        if ( m_pSpecifyTargets )
            this.m_pSpecifyTargets.splice( 0, m_pSpecifyTargets.length );
        m_pSpecifyTargets = null;

        if ( m_pSpecifyHitAeras )
            this.m_pSpecifyHitAeras.splice( 0, m_pSpecifyHitAeras.length );
        m_pSpecifyHitAeras = null;

        var key : Object;

        for ( key in m_targetDic ) {
            m_targetDic[ key ] = null;

            if ( m_collidedAreaList )
                m_collidedAreaList.splice( 0, m_collidedAreaList.length );
            m_collidedAreaList = null;

            for ( key in m_targetDic )
                delete  m_targetDic[ key ];
        }

        if ( m_hitCount == 0 ) {
            if ( m_pSkillContex.fightTriggle )
                m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_HIT_NOBODY, null, null ) );
        }

        m_hitCount = 0;

        if ( m_pSpecifyHitPosition )
            m_pSpecifyHitPosition.splice( 0, m_pSpecifyHitPosition.length );
        m_pSpecifyHitPosition = null;

        if ( m_pDistanceDiscreaseList )
            m_pDistanceDiscreaseList.splice( 0, m_pDistanceDiscreaseList );
        m_pDistanceDiscreaseList = null;
        m_boHitDirectly = false;
        m_boHostDirectly = false;
    }

    //暂时没用了 用完就输出，不用缓存reset
    override public function resetEffect() : void {
        if ( m_collisionTargetList )
            this.m_collisionTargetList.splice( 0, m_collisionTargetList.length );

        if ( m_collidedAreaList )
            m_collidedAreaList.splice( 0, m_collidedAreaList.length );

        m_tickTime = 0;
        m_hurtCount = 0;
        m_boHitComplete = false;

        for ( var key : Object in m_targetDic ) {
            m_targetDic [ key ] = null;
            delete  m_targetDic[ key ];
        }

        CSkillDebugLog.logTraceMsg( "**@CSkillHit：重置击打效果效果 ID ：" + effectID );
    }

    override public function update( delta : Number ) : void {

        if ( null == hitData )
            return;

        if ( !_findCriteriaTargets() ) {
            updateTargetTimeWhatever( delta );
            return;
        }
        var temHit : Hit = hitData;
        var targetList : Vector.<CGameObject>;

        updateTargetTimeWhatever( delta );
        targetList = hitTargetTimes( delta );

        if ( targetList != null && targetList.length ) {
            var pNetInput : CCharacterNetworkInput = m_pSkillContex.owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
            if ( pNetInput ) {
                pNetInput.stepHitQueueID();
                pNetInput.stepSkillHitQueueID();
            }
            var m_pTarget : CTarget = m_pSkillContex.owner.getComponentByClass( CTarget, true ) as CTarget;
            if ( m_pTarget ) {
                m_pTarget.setTargetObjects( targetList );
            }
            //fixme 子弹的击打
            if ( CCharacterDataDescriptor.isMissile( owner.data ) ) {
                _syncMissileHitTargetList( targetList );
            } else {
                _syncPlayerHitTargetList( targetList );
            }
            ;
        }
    }

    private function _syncMissileHitTargetList( targetList : Vector.<CGameObject> ) : void {
        var temHit : Hit = hitData;
        var masterCmp : CMasterCompomnent = m_pSkillContex.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( masterCmp ) {
            var master : CGameObject = masterCmp.master;
            if ( master ) {
                var missileID : int;
                var missileSeq : int;

                var missileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
                if ( missileProperty ) {
                    missileID = missileProperty.missileId;
                    missileSeq = missileProperty.missileSeq;
                }
                var aliasSkillID : int = masterCmp.aliasSkillID;
                var mpNetInput : CCharacterNetworkInput = master.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
                if ( mpNetInput )
                    mpNetInput.stepHitQueueID();

                var mpTarget : CTarget = master.getComponentByClass( CTarget, true ) as CTarget;
                if ( mpTarget )
                    mpTarget.setTargetObjects( targetList );
                if ( !m_boHostDirectly ) {
                    var mPFightTriggle : CCharacterFightTriggle = master.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                    mPFightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_HIT, null, [ targetList, temHit.ID, aliasSkillID, true, missileID, missileSeq ] ) );
                }
            }
        }
    }

    private function _syncPlayerHitTargetList( targetList : Vector.<CGameObject> ) : void {
        var temHit : Hit = hitData;
        if ( temHit == null || targetList == null || targetList.length == 0 )
            return;

        if ( !m_boHostDirectly ) {
            var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
            if ( pSyncBoard )
                pSyncBoard.setValue( CCharacterSyncBoard.BO_IGNORE_GUARD, m_bSpecifyGuardIgnored );

            var skillCaster : CSkillCaster = pSkillCaster;
            if ( skillCaster && m_pSkillContex ) {
                if ( m_pSkillContex.fightTriggle )
                    m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_HIT, null, [ targetList, temHit.ID, pSkillCaster.skillID ] ) );
            }
        }
    }

    override public function lastUpdate( delta : Number ) : void {
        if ( boLastUpdateDirty ) {
            boLastUpdateDirty = false;
            _dispatchHitTargetEvent( null );
        }

        if ( m_boHostDirectly ) {
            m_pContainer.removeSkillEffect( this );
        }
    }

    private function updateTargetTimeWhatever( delta : Number ) : void {
        var keyObj : CGameObject;
        for ( keyObj in m_targetDic ) {
            var targetInfo : CHitStateInfo = m_targetDic[ keyObj ] as CHitStateInfo;
            if ( targetInfo.beingHitted )
                targetInfo.elapsTime = targetInfo.elapsTime + delta;
        }

    }

    /**
     *execute hit to all the targets in m_targetDic many times
     * @param delta
     * @return  all the targets that in hurt
     */
    private function hitTargetTimes( delta : Number ) : Vector.<CGameObject> {
        var idx : int = -1;
        var keyObj : CGameObject;
        var targetList : Vector.<CGameObject> = new <CGameObject>[];
        var pStateBoard : CCharacterStateBoard;
        var masterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;

        for each( keyObj in collisionTargetList ) {

            if ( !_boTargetCanBeAttacked( keyObj ) ) continue;

//            if ( hitData.DamageID == 0 ) {
//                _notifyHitTargetEvent();
//                targetList.push( keyObj );
//                return targetList;
//            }

            var targetInfo : CHitStateInfo = m_targetDic[ keyObj ] as CHitStateInfo;
            if ( targetInfo == null ) {
                targetInfo = new CHitStateInfo();
            }

            var maxHitCount : int = hitData.TimesAtOneTarget;
            if ( m_boHostDirectly )
                maxHitCount = 1;

            if ( targetInfo.boNotReachMaxHit( maxHitCount ) ) {//hitData.TimesAtOneTarget ) ) {

                if ( hitData.DamageID == 0 ) {
                    _notifyHitTargetEvent();
                    targetList.push( keyObj );
                    return targetList;
                }

                var curHitCount : int = targetInfo.hitCount;

                var curElapsTime : Number = targetInfo.elapsTime;
                if ( curHitCount == 0 || ( hitData.EffectSpan != 0 && (int( curElapsTime / ( hitData.EffectSpan * CSkillDataBase.TIME_IN_ONEFRAME ) ) ) > curHitCount) ) {
                    pStateBoard = keyObj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

                    var boHurtingBefore : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_HURTING ) );
                    var boLyingBefore : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.LYING ) );
                    var boInCatchBefore : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_CATCH ));
                    var boPaBody : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.PA_BODY ) );
                    var targetproperty : CCharacterProperty = keyObj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                    var targetSkillCaster : CSkillCaster = keyObj.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
                    var bohitTarget : Boolean = false;

                    if ( m_boHostDirectly ) {
                        var paIndex : int;
                        var paInfo : Object;
                        var nDefensePwd : int;
                        paIndex = m_pSpecifyTargets.indexOf( keyObj );
                        if ( paIndex >= 0 ) {
                            paInfo = m_damgeInfoList[ paIndex ];
                            if( paInfo.hasOwnProperty( CCharacterSyncBoard.BO_PA_BODY ) ) {
                                boPaBody = paInfo[ CCharacterSyncBoard.BO_PA_BODY ];
                            }
                            if( paInfo.hasOwnProperty(CCharacterSyncBoard.DEFENSE_POWER)  ) {
                                nDefensePwd = paInfo[ CCharacterSyncBoard.DEFENSE_POWER ];
                                targetproperty.DefensePower = nDefensePwd;
                            }
                        }
                    }

                    /**霸体 || 怪物被设置成不能打断**/
                    var bInterrupt : Boolean;
                    var targetInSkill : int;
                    if( targetSkillCaster )
                            targetInSkill = targetSkillCaster.skillID;

                   bInterrupt = getMonsterInterruptTarget( targetInSkill );

                    if ( boPaBody || bInterrupt ) {
                        var pAnimation : IAnimation = keyObj.getComponentByClass( IAnimation, true ) as IAnimation;
                        var fxMediator : CFXMediator = keyObj.getComponentByClass( CFXMediator, true ) as CFXMediator;
                        var pShakeEffect : Array = [ [ hitData.HitCameraEffect, hitData.HitCameraZoomEffect ], [ hitData.DefCameraEffect, hitData.DefCameraZoomEffect ] ];
                        var pHitStopTime : Number = (hitData.HitStopTime > 7 ? 7 : hitData.HitStopTime) * CSkillDataBase.TIME_IN_ONEFRAME;
                        fxMediator.playAtBone( "guanghuan/pa_body_1", pHitStopTime );

//                        pAnimation.frozenFrame( pHitStopTime );
                        pAnimation.setFrozenDirty( pHitStopTime );
                        sceneShake( 1, pShakeEffect );
                        bohitTarget = true;
                    }
                    else if ( enterTargetHurtFSM( keyObj ) ) {
                        bohitTarget = true;
                    }

                    if ( bohitTarget ) {
                        targetList.push( keyObj );
                        targetInfo.beingHitted = true;
                        targetInfo.hitCount = curHitCount + 1;
                        var boGuard : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_GUARD ) );
                        var collisonComp : CCollisionComponent = m_pSkillContex.collisionComponent;
                        var collidedArea : CAABBox3;
                        var hitFxPosition : CVector3;
                        var nDex : int;
                        if ( null == m_pSpecifyTargets )
                            collidedArea = collisonComp.getCollisedArea( hitEventSignal, keyObj );
                        else {
                            nDex = m_pSpecifyTargets.indexOf( keyObj );
                            if ( nDex >= 0 ) {
                                if ( m_pSpecifyHitAeras )
                                    collidedArea = m_pSpecifyHitAeras[ nDex ];

                                if ( m_pSpecifyHitPosition ) {
                                    hitFxPosition = m_pSpecifyHitPosition[ nDex ] as CVector3;
                                }
                            }
                        }

                        if ( m_boHostDirectly ) {
                            var damage : int;
                            var boCrit : Boolean;
                            var damageInfo : Object;
                            if ( nDex >= 0 ) {
                                damageInfo = m_damgeInfoList[ nDex ];
                                damage = damageInfo[ CCharacterSyncBoard.DAMAGE_HURT ];
                                boCrit = damageInfo[ CCharacterSyncBoard.BO_CRITICAL_HIT ];
                            }
                            executeHostHurt( keyObj, hitFxPosition, damage, boCrit );
                        } else {
                            executeHurt( keyObj, collidedArea, hitFxPosition );
                        }
                        m_hitCount++;
                        //计算连击
                        if ( !boGuard ) {
                            var fCalc : CFightOthersCalc = m_pSkillContex.pFightCalc.otherFightCalc;

                            if ( masterComp ) {
                                masterComp.attachHitContinue( boHurtingBefore || boLyingBefore );
                            }

                            if ( fCalc ) {
                                if ( boHurtingBefore || boLyingBefore || boInCatchBefore ) {
                                    fCalc.boResetNext = false;
                                }

                                fCalc.increaseCHitWithCount( 1 );
                            }
                        }
                    }
                }

                m_targetDic[ keyObj ] = targetInfo;
            }

        }

        return targetList;

    }

    private function _boTargetCanBeAttacked( keyObj : CGameObject ) : Boolean {
        if ( m_boHostDirectly ) return true;

        var boPuppetCanHit : Boolean = true;//_verifyCanExecuteLocalHit( keyObj );

        if ( keyObj.isRunning && checkTargetBasicState( keyObj ) && boPuppetCanHit )
            return true;
        return false;
    }

    private function _notifyHitTargetEvent( hitTarget : CGameObject = null ) : void {
        m_boLastUpdateDirty = true;
//        _dispatchHitTargetEvent( hitTarget );
    }

    private function _dispatchHitTargetEvent( hitTarget : CGameObject ) : void {
        CSkillDebugLog.logTraceMsg( "**@CSkillHit：成功对目标执行击打效果，击中目标判定通过  ：" + effectID + " At Time : " + m_fElapseTickTime );
        var bDetected : Boolean = hitData ? hitData.DamageID == 0 : false;

        m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.HIT_TARGET, hitTarget, [ m_pSkillContex.skillCaster.skillID, hitData.ID, bDetected ] ) );
        var masterCmp : CMasterCompomnent = m_pSkillContex.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( masterCmp ) {
            masterCmp.attachFightTriggleEvent( new CFightTriggleEvent( CFightTriggleEvent.HIT_TARGET, null, [ masterCmp.aliasSkillID ] ) );
        }
    }

    private function _dispatchTargetBeingHitEvent( hitTarget : CGameObject ) : void {
        CSkillDebugLog.logTraceMsg( "**@CSkillHit：成功对目标执行击打效果，击中目标判定通过  ：" + effectID + "At Time : " + m_fElapseTickTime );
        if ( hitTarget == null )
            return;
        var pFightTrigger : CCharacterFightTriggle = hitTarget.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTrigger ) {
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.BEING_HITTED, null, null ) );
        }
    }

    /**
     *  to check if  the state of a target can be hit
     * @param target
     * @return  true can be attack
     */
    private function checkTargetBasicState( target : CGameObject ) : Boolean {
        var isNotDead : Boolean;
        var canBeAttackState : Boolean;
        var isNotMissile : Boolean;
        var isNotMissileOwner : Boolean;
        var isHPNotZero : Boolean;

        var pStateBoard : CCharacterStateBoard;
        pStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        var pStateMachine : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;

        isHPNotZero = true;
        // isHPNotZero = pCharacterPro.hp > 0;
        // isNotDead =  pStateBoard && !pStateBoard.getValue( CCharacterStateBoard.DEAD );
        isNotDead = pStateMachine && pStateMachine.actionFSM.current != CCharacterActionStateConstants.DEAD;
        canBeAttackState = pStateBoard && pStateBoard.getValue( CCharacterStateBoard.CAN_BE_ATTACK );

        var targetMasterCmp : CMasterCompomnent = target.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( !targetMasterCmp ) {
            isNotMissile = true;
        }

        var ownerMasterCmp : CMasterCompomnent = m_pSkillContex.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( ownerMasterCmp ) {
            if ( ownerMasterCmp.master !== target )
                isNotMissileOwner = true;
        }
        else {
            isNotMissileOwner = true;
        }

        return isHPNotZero && isNotDead && isNotMissile && isNotMissileOwner && canBeAttackState;
    }

    private function _verifyCanExecuteLocalHit( obj : CGameObject ) : Boolean {
        return true;
        var theResponseQueue : CCharacterResponseQueue = m_pSkillContex.owner.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
        var pNetInput : CCharacterNetworkInput = m_pSkillContex.owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( null == theResponseQueue || pNetInput.isAsHost ) return true;

        if ( pNetInput ) {
            var skillQueueID : int = pNetInput.localSkillQueue.queueID;
            var skillHitID : int = hitData.ID;
            var nextSkillHitQueueID : int = pNetInput.skillHitQueueID + 1;

            if ( m_boHostDirectly )
                return true;

            if ( pNetInput ) {
                var hostHitInfos : Vector.<CHitStateSync> = pNetInput.getHostHitBySkillQueue( skillQueueID, skillHitID );
                var hitTotalCount : int = 0;
                var maxHitIndex : int = 0;
                var hitDataCount : int = hitData.TimesAtOneTarget;
                if ( null == hostHitInfos || (hostHitInfos && hostHitInfos.length == 0) ) {

                    return true;
                }

                for each( var hitState : CHitStateSync in hostHitInfos ) {
                    var pTargets : Vector.<CGameObject> = hitState.hitTargetList;
                    if ( pTargets && pTargets.indexOf( obj ) >= 0 )
                        hitTotalCount++;

                    maxHitIndex = hitState.skillHitQueueID > maxHitIndex ? hitState.skillHitQueueID : maxHitIndex;
                }
                //已经超过次数 不能执行击打了
                if ( hitTotalCount >= hitDataCount )
                    return false;

                if ( maxHitIndex >= nextSkillHitQueueID )
                    return false;

            }
            return true;
        }
        return true;
    }

    /**
     *
     * @param target
     * @return true mean  target can enter the hurt state SUCCEEDED
     */
    private function enterTargetHurtFSM( target : CGameObject ) : Boolean {
        var pFSM : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        var targetTrigger : CCharacterFightTriggle = target.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var targetFightCalc : CFightCalc = target.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var pSkillCaster : CSkillCaster = target.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        var pFightFloatSprite : CFightFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
        var targetAnimation : IAnimation = target.getComponentByClass( IAnimation, true ) as IAnimation;
        var attackPos : CVector3;
        var targetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var targetFSM : CCharacterStateMachine = target.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        var pMotionData : Motion;
        var guard : Boolean;
        var bCounter : Boolean;

        // 在Idle和防御中需要抵消防御值
        var inAttack : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_ATTACK ) );
        var inHurting : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_HURTING ) );
        var inLying : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.LYING ) );
        var inCatch : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_CATCH ) );
        var bCanBeAttack : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.CAN_BE_ATTACK ) );
        var detectDPRet : int;
        var boOnGround : Boolean;
        var boCostGP : Boolean;
        var delDefensePower : int;
        var targetSyncBoard : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard , false ) as CCharacterSyncBoard;

        if ( !m_boHostDirectly && !bCanBeAttack )
            return false;


        /**计算防御状态*/
        if ( !inAttack && !inHurting && !inLying && !inCatch && !m_bSpecifyGuardIgnored ) {

            detectDPRet = pSkillCaster.pComUtility.pFightCalc.battleEntity.calcDefensePower( -hitData.ConsumeGP, false, false ); //targetFightCalc.battleEntity.calcDefensePower( -hitData.ConsumeGP );
            guard = detectDPRet == ECalcStateRet.E_PASS;
            var hurtRet : int = CFiniteStateMachine.Result.SUCCEEDED;
            // FIXME(Jeremy): Testing data.
            var iTypeOfHurt : int = guard ? 2 : 1; // 1 为受伤状态了 不管是不是暴击
            boCostGP = true;

            if ( targetProperty )
                delDefensePower = targetProperty.DefensePower == 0 ? 0 : hitData.ConsumeGP;
        }

        // Ground or Air.
        var simpleLog : String = CCharacterDataDescriptor.getSimpleDes( owner.data );
        var boInKnockUp : Boolean;
        var bInAeroLand : Boolean;
        if ( targetFSM )
            boInKnockUp = (targetFSM.actionFSM.currentState is CCharacterKnockUpState);
        if ( boInKnockUp )
            bInAeroLand = targetAnimation.currentAnimationState == CAnimationStateConstants.AERO_LAND;

        boOnGround = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
        if ( m_boHostDirectly ) {

            var paIndex : int;
            var paInfo : Object;
            var syncMotionID : int;
            paIndex = m_pSpecifyTargets.indexOf( target );
            if ( paIndex >= 0 ) {
                paInfo = m_damgeInfoList[ paIndex ];
                if ( paInfo ) {
                    if( paInfo.hasOwnProperty( CCharacterSyncBoard.BO_ON_GROUND ) )
                        boOnGround = paInfo[ CCharacterSyncBoard.BO_ON_GROUND ];
                    if( paInfo.hasOwnProperty( CCharacterSyncBoard.BO_GUARD ) )
                        guard = paInfo[ CCharacterSyncBoard.BO_GUARD ];
                    if( paInfo.hasOwnProperty( CCharacterSyncBoard.BO_COUNTER) )
                        bCounter = paInfo[ CCharacterSyncBoard.BO_COUNTER];
                    if( paInfo.hasOwnProperty( CCharacterSyncBoard.MOTION_ID))
                        syncMotionID = paInfo[ CCharacterSyncBoard.MOTION_ID];
                }
            }
        }

        pMotionData = _getMotionDataByState( guard, boOnGround, boInKnockUp, bInAeroLand, simpleLog );

        if( !m_boHostDirectly && targetSyncBoard ) {
            targetSyncBoard.setValue( CCharacterSyncBoard.NHEIGHT_PLAYER, target.transform.z );
            targetSyncBoard.setValue( CCharacterSyncBoard.BO_ON_GROUND, boOnGround );
            if(pMotionData != null )
                targetSyncBoard.setValue( CCharacterSyncBoard.MOTION_ID, pMotionData.ID );
        }

        if(m_boHostDirectly && pMotionData !=null &&  pMotionData.ID != syncMotionID )
        {
            pMotionData = CSkillCaster.skillDB.getMotionDataByID( syncMotionID );
//            Foundation.Log.logWarningMsg("击打位移不一致 强制同步 ：" + syncMotionID + " (not:" + pMotionData.ID + ")");
        }

        {
            var hitStopTime : Number = hitData.HitStopTime * CSkillDataBase.TIME_IN_ONEFRAME;
            if ( guard )
                hitStopTime = hitData.GHitStopTime * CSkillDataBase.TIME_IN_ONEFRAME;

            var hitPart : int = guard ? hitData.GuardCategory : hitData.HurtCategory;
            var pDir : Point = m_pSkillContex.stateBoard.getValue( CCharacterStateBoard.DIRECTION );
            var pHitSound : Array = [ hitData.HitSoundEffect, hitData.GaurdSoundEffect ];
            var pShakeEffect : Array = [ [ hitData.HitCameraEffect, hitData.HitCameraZoomEffect ], [ hitData.DefCameraEffect, hitData.DefCameraZoomEffect ] ];
            var iTypeOfMotion : int = pMotionData ? pMotionData.MoveType : EMotionType.PAN;
            var iCharacterShake : int = hitData.CharacterShakeEffect;
            var fDecreaseRadio : Number;//衰减距离比值

            var collisionCmp : CCollisionComponent = m_pSkillContex.collisionComponent;
            fDecreaseRadio = collisionCmp.getDecreseRadio( hitEventSignal, target );
            if( !m_boHostDirectly && targetSyncBoard ) {
                targetSyncBoard.setValue( CCharacterSyncBoard.HIT_MOTION_RADIO , fDecreaseRadio );
            }

            if ( m_boHitDirectly ) {
                var inDex : int = m_pSpecifyTargets.indexOf( target );
                if ( inDex >= 0 && m_pDistanceDiscreaseList != null )
                    fDecreaseRadio = m_pDistanceDiscreaseList[ inDex ];
            }

            var eleEffectName : String = hitData.ElementEffect;

            if ( pMotionData )
                CSkillDebugLog.logTraceMsg( "击退位移ID :-> " + pMotionData.ID + "位移衰减 :->" + fDecreaseRadio );

            if ( pMotionData && (pMotionData.TransWay == ETransWay.AWAY_SPELLER || pMotionData.TransWay == ETransWay.TO_SPELLER ) ) {
                attackPos = _getSpellerPosition();
            } else {
                attackPos = m_pSkillContex.tranformCmp.position.clone();
            }
            // NOTE(jeremy): 如果目标处于空中，默认继续击飞
            iTypeOfMotion = (false == boOnGround ) ? EMotionType.KNOCKUP : iTypeOfMotion; //pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ))

            if ( guard || EMotionType.PAN == iTypeOfMotion ) {
                hurtRet = pFSM.actionFSM.on( CCharacterActionStateConstants.EVENT_HURT_BEGAN, iTypeOfHurt, hitPart, pDir.x, hitStopTime, pMotionData, attackPos, hitData.HitHurtTime, pHitSound, pShakeEffect, iCharacterShake, fDecreaseRadio, eleEffectName );
            } else if ( EMotionType.KNOCKUP == iTypeOfMotion ) {
                hurtRet = pFSM.actionFSM.on( CCharacterActionStateConstants.EVENT_KNOCK_UP_BEGAN, pDir.x, hitStopTime, pMotionData, attackPos, pHitSound, pShakeEffect, iCharacterShake, fDecreaseRadio );
            }

            if ( !inCatch &&
                    hurtRet != CFiniteStateMachine.Result.SUCCEEDED &&
                    hurtRet != CFiniteStateMachine.Result.NO_TRANSITION ) {

                CSkillDebugLog.logTraceMsg( "目标进入受伤状态失败，不能击打对方：ID = " + hitData.ID + " guard Sate = " + guard + " To Knock up State : from " + pFSM.actionFSM.currentState + (EMotionType.KNOCKUP == iTypeOfMotion) );
                return false;
            }

            //成功进入受伤才去扣除防御值
            targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, CCharacterSyncBoard.SYNC_HIT_PROPERTY ) );
            //targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.HIT_MOTION_RADIO, fDecreaseRadio ] ) );



            if ( boCostGP ) {// !inAttack && !inHurting && !inLying && !inCatch && !m_bSpecifyGuardIgnored ) {
                detectDPRet = pSkillCaster.pComUtility.pFightCalc.battleEntity.calcDefensePower( -hitData.ConsumeGP );
                if ( delDefensePower != 0 ) {
                    //targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.DEFENSE_POWER_DELTA, hitData.ConsumeGP ] ) );
                    if( !m_boHostDirectly && targetSyncBoard)
                        targetSyncBoard.setValue( CCharacterSyncBoard.DEFENSE_POWER_DELTA, hitData.ConsumeGP);
                    targetFightCalc.recovery.resetRecoveryByType( CPropertyRecovery.RECOVERY_TYPE_DP );
                }
            }

            /** counter */
            if ( inAttack  || bCounter ) {
                pStateBoard.setValue( CCharacterStateBoard.COUNTER, true );
                //targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.DEFENSE_POWER_DELTA, 0 ] ) );
                if(!m_boHostDirectly && targetSyncBoard)
                    targetSyncBoard.setValue( CCharacterSyncBoard.DEFENSE_POWER_DELTA, hitData.ConsumeGP);
                m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_COUNTER, null ) );
            }
            else {
                pStateBoard.setValue( CCharacterStateBoard.COUNTER, false );
            }

            var bGuard : Boolean;
            bGuard = pStateBoard.getValue( CCharacterStateBoard.IN_GUARD );

            if ( !bGuard ) {
                _playCombineFx( target );
            }

            _addToSuperControl( target );

            //sync target uncontrol state
            if ( !m_boHostDirectly ) {
                var syncState : int = ESyncStateType.STATE_UNCONTROL;
                var theSubState : Object;
                if ( targetSyncBoard ) {
                    theSubState = {};
                    if ( EMotionType.KNOCKUP == iTypeOfMotion ) {
                        var knockUpTime : Number = 0.0;
                        if ( pMotionData )
                            knockUpTime = CFacadeMediator.getKnockUpTime( target.transform.z, pMotionData.ySpeed, pMotionData.yDamping );
                        theSubState[ ESyncStateType.SUB_UNCONTROL_UP ] = hitStopTime + knockUpTime;
                    } else if ( bGuard ) {
                        theSubState[ ESyncStateType.SUB_UNCONTROL_GUARD ] = hitStopTime +
                                ( hitData.HitHurtTime == 0 ? (12 * CSkillDataBase.TIME_IN_ONEFRAME) : hitData.HitHurtTime * CSkillDataBase.TIME_IN_ONEFRAME);
                    } else {
                        theSubState[ ESyncStateType.SUB_UNCONTROL_HURT ] = hitStopTime +
                                ( hitData.HitHurtTime == 0 ? 12 * CSkillDataBase.TIME_IN_ONEFRAME : hitData.HitHurtTime * CSkillDataBase.TIME_IN_ONEFRAME );
                    }
                }

                if( targetSyncBoard ) {
                    targetSyncBoard.setValue( CCharacterSyncBoard.SYNC_STATE, syncState );
                    targetSyncBoard.setValue( CCharacterSyncBoard.SYNC_SUB_STATES, theSubState );
                }
            }

            //显示破防飘字扣除防御值
            if ( detectDPRet == ECalcStateRet.E_TRANSFER ) {
                if ( pFightFloatSprite )
                    pFightFloatSprite.createFightText( CFightTextConst.TEXT_PO_FANG );
                _playGuardCrashFX( target );
            }

            return true;
        }
    }

    private function _getSpellerPosition() : CVector3 {
        var spellerPos : CVector3;
        var masterComp : CMasterCompomnent;
        var masterTransform : CKOFTransform;
        masterComp = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( masterComp ) {
            if ( masterComp.master ) {
                masterTransform = masterComp.master.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
                spellerPos = masterTransform.position.clone();
            }
        } else {
            var pTransform : ITransform = owner.getComponentByClass( ITransform, true ) as ITransform;
            spellerPos = pTransform.position.clone();
        }
        return spellerPos;
    }

    private function _getMotionDataByState( guard : Boolean, boOnGround : Boolean, boOnKnockUpState : Boolean, inAeroLandAnimation : Boolean, dbLogMsg : String ) : Motion {

        var retMotion : Motion;
        var simpleLog : String = CCharacterDataDescriptor.getSimpleDes( owner.data );
        var retMotionID : int;
        if ( guard ) {
            if ( hitData.GHitMotionID != 0 )
                retMotionID = hitData.GHitMotionID;
        } else {

            if ( boOnGround ) {
                if ( (boOnKnockUpState) ) { //} && !inAeroLandAnimation ) {
                    retMotionID = hitData.HitMotionInAirID;
                } else {
                    retMotionID = hitData.HitMotionID;
                }
            } else {
                if ( hitData.HitMotionInAirID != 0 )
                    retMotionID = hitData.HitMotionInAirID;
            }
        }
        if ( retMotionID != 0 )
            retMotion = CSkillCaster.skillDB.getMotionDataByID( retMotionID, simpleLog );

        return retMotion;
    }

    private function _playGuardCrashFX( target : CGameObject ) : void {
        var pFXMediator : CFXMediator = target.getComponentByClass( CFXMediator, true ) as CFXMediator;
        var pProp : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( pFXMediator ) {
            pFXMediator.playComhitEffects( pProp.guardCrashFx );
        }
    }

    private function _playCombineFx( target : CGameObject ) : void {
        var sElementEffect : String = hitData.ElementEffect;
        if ( sElementEffect && sElementEffect != "" ) {
            var pFxMediator : CFXMediator = target.getComponentByClass( CFXMediator, true ) as CFXMediator;
            pFxMediator.playComhitEffects( sElementEffect );
        }
    }

    private function _playHitSound( pSounds : String ) : void {
        var soundMedia : CAudioMediator = owner.getComponentByClass( CAudioMediator, true ) as CAudioMediator;
        if ( !soundMedia || !pSounds || !pSounds.length )
            return;
        soundMedia.playAudioByName( pSounds )
    }

    private function executeHostHurt( target : CGameObject, hitFxPosion : CVector3, damage : int, boCrit : Boolean ) : void {
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var guard : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_GUARD ) );

        _increaseTargetRagePowderByDamage( target, damage );
         if(_getbShowDamageFloat())
            _showDamageFloatSprite( target, damage, boCrit, null );//hitFxPosion );
        _handleAttackerStoptime( hitData.AttackerStopTime * CSkillDataBase.TIME_IN_ONEFRAME );

        {
            // compute the collided area's center position and play the hitting fx.
            m_pSkillContex.fxMediator.playBindHitEffect( _getHitFXName( guard, boCrit ), hitFxPosion );
        }

        {
            if ( !guard ) {
                _playHitSound( hitData.HitSoundEffect );
            } else {
                _playHitSound( hitData.GaurdSoundEffect );
            }

        }

        _notifyHitTargetEvent();
        _dispatchTargetBeingHitEvent( target );
    }

    private function _getbShowDamageFloat() : Boolean{
        var damageInfo : Damage = CSkillCaster.skillDB.getDamageByID( hitData.DamageID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        if( !damageInfo  || damageInfo.NeverShow )
                return false;
        return true;
    }

    private function _showDamageFloatSprite( target : CGameObject, damage : int, boCrit : Boolean, position : CVector3 ) : void {

        var pFightFloatSprite : CFightFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
        var boShowHeroStyle : Boolean;
        var pMaster : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        boShowHeroStyle = CCharacterDataDescriptor.isHero( owner.data );
        if ( pMaster != null )
            boShowHeroStyle = CCharacterDataDescriptor.isHero( pMaster.master ? pMaster.master.data : null );

        //序章又大又好看
        var pLevelFacade : CLevelMediator = target.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
        if( pLevelFacade && pLevelFacade.isPlelude ){
            boShowHeroStyle = boCrit = true;
        }

        if ( pFightFloatSprite ) {
            if ( !boCrit ) {
                if ( boShowHeroStyle ) {
                    pFightFloatSprite.createBubbleNumber( -damage, position );
                } else
                    pFightFloatSprite.createBubbleNumber( -damage, position, CFightTextConst.EN_NUMBER, "shinningnums", CFightTextConst.EN_NUMBER_POOL, "DynamicShiningText" );
            } else {
                if ( boShowHeroStyle ) {
                    pFightFloatSprite.createBubbleNumber( -damage, position,
                            CFightTextConst.CRITICAL_FONT, CFightTextConst.CRITICAL_HIGH_FONT, CFightTextConst.CRI_APPARE_POOL_NAME, CFightTextConst.CRI_SHINNING_POOL_NAME, 48 );
                } else {
                    pFightFloatSprite.createBubbleNumber( -damage, position,
                            CFightTextConst.EN_CRITICALNUMBER, CFightTextConst.CRITICAL_HIGH_FONT, CFightTextConst.EN_CRITICAL_POOL, CFightTextConst.CRI_SHINNING_POOL_NAME, 48 );
                }
            }
        }
    }

    private function _increaseTargetRagePowderByDamage( target : CGameObject, finalDamage : int ) : void {
        /** target's and self's ragePower increase */
        var targetFightCalc : CFightCalc = target.getComponentByClass( CFightCalc, true ) as CFightCalc;
        var masterCmp : CMasterCompomnent = target.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        {
            /** The target increase ragePower*/
            targetFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_DAMAGED, finalDamage );
            targetFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_BEINGHITTED );
            /**the attacker increase ragePower*/
            var pOwnerFightCalc : CFightCalc = m_pSkillContex.owner.getComponentByClass( CFightCalc, true ) as CFightCalc;
            if ( pOwnerFightCalc ) {
                pOwnerFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_DAMAGE_TARGET, finalDamage );
            }

            if ( masterCmp ) {
                var ptheMaster : CGameObject = masterCmp.master;
                if ( ptheMaster ) {
                    var ptheMasterFightCalc : CFightCalc = ptheMaster.getComponentByClass( CFightCalc, true ) as CFightCalc;
                    ptheMasterFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_DAMAGED, finalDamage );
                }
            }

        }
    }

    /**
     *返回防御状态
     */
    private function executeHurt( target : CGameObject, collidedArea : CAABBox3, hitFxPosition : CVector3 ) : void {
        var fMediator : CFacadeMediator = target.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        var targetTrigger : CCharacterFightTriggle = target.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var damageInfo : Damage = CSkillCaster.skillDB.getDamageByID( hitData.DamageID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        var pTargetProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pFightFloatSprite : CFightFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;

        //fixme the missile should disapear
        if ( targetTrigger )
            targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.BEING_HITTED, null, null ) );

        var guard : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_GUARD ) );
        var inAttack : Boolean = Boolean( pStateBoard.getValue( CCharacterStateBoard.IN_ATTACK ) );
        var boCrit : Boolean;
        var masterComp : CMasterCompomnent;

        if ( fMediator ) {


            var damageComp : CFightDamageComponent = owner.getComponentByClass( CFightDamageComponent, true ) as CFightDamageComponent;
            var masterCmp : CMasterCompomnent = m_pSkillContex.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            var skillUpID : int = CSkillUtil.getMainSkill( m_pSkillContex.skillCaster.skillID );
            if ( masterCmp )
                skillUpID = masterCmp.aliasSkillID;

            var finalDamage : int = 0;
            if ( !guard ) {
                if ( fMediator ) {
                    {
                        if ( damageInfo == null ) {
                            CSkillDebugLog.logErrorMsg( "can not find damage info in Damage Json file , ID = " + hitData.DamageID );
                        }
                        /** execute damage */
                        finalDamage = damageComp.executeHurt( target, damageInfo, skillUpID );
                        /**target  being critical hit*/
                        boCrit = pStateBoard.getValue( CCharacterStateBoard.CRITICAL_HIT );
                        if ( boCrit ) {
                            m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_CRITICALHIT, null ) );
                            if ( targetTrigger )
                                targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_BEING_CRITICALHITTED, null ) );

                            masterComp = m_pSkillContex.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
                            if ( masterComp && masterComp.master ) {
                                var masterFightTriggel : CCharacterFightTriggle = masterComp.master.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                                if ( masterFightTriggel )
                                    masterFightTriggel.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_PLAYER_CRITICALHIT, null, null ) );
                            }
                        }
                    }
                    if ( targetTrigger )
                        targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.BEING_HURT, null ) );
                }

            }
            else {
                finalDamage = damageComp.executeGuardHurt( target, damageInfo, skillUpID );
            }

            _increaseTargetRagePowderByDamage( target, finalDamage );

            if ( targetTrigger ) {
                targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, CCharacterSyncBoard.SYNC_HIT_STATUS ) );
                targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.DAMAGE_HURT, finalDamage ] ) );
                targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.CURRENT_HP, pTargetProperty.HP ] ) );
            }

            var otherSpriteCenter : CVector3;
            if ( collidedArea )
                otherSpriteCenter = collidedArea.center;

            if ( otherSpriteCenter == null )
                otherSpriteCenter = hitFxPosition;

            if( damageInfo && !damageInfo.NeverShow && finalDamage !=0 )
                _showDamageFloatSprite( target, finalDamage, boCrit, otherSpriteCenter );

            if ( !guard ) {
                _playHitSound( hitData.HitSoundEffect );
            } else {
                _playHitSound( hitData.GaurdSoundEffect );
            }
        }

        _handleAttackerStoptime( hitData.AttackerStopTime * CSkillDataBase.TIME_IN_ONEFRAME );

        {
            // compute the collided area's center position and play the hitting fx.
            var hitPosition : CVector3;
            if ( collidedArea ) {
                var pCollidedCenter : CVector3 = collidedArea.center;
                hitPosition = _getHitPosition( target, pCollidedCenter );
            }

            if ( hitPosition == null && hitFxPosition )
                hitPosition = hitFxPosition;

            m_pSkillContex.fxMediator.playBindHitEffect( _getHitFXName( guard, boCrit ), hitPosition, 20 );
            targetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.HIT_EFFECT_POINT, hitPosition ] ) );
        }

        if ( !guard ) {

            CSkillDebugLog.logTraceMsg( "**@CSkillHit：成功对目标执行击打效果,造成对方伤害效果ID为  ：" + effectID );

            m_pSkillContex.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.HURT_TARGET, target, null ) );
        }
        else
            CSkillDebugLog.logTraceMsg( "**@CSkillHit：成功对目标执行击打效果,造成对方防御  ：" + effectID );

        _notifyHitTargetEvent();
    }


    private function _handleAttackerStoptime( time : Number ) : void {
        if ( time > 0.0 ) {
            m_pSkillContex.cAnimation.setFrozenDirty( time );
//            m_pSkillContex.cAnimation.frozenFrame( hitData.AttackerStopTime * CSkillDataBase.TIME_IN_ONEFRAME, _onFrozemEnd );
        }
    }

    private function _onFrozemEnd() : void {

    }

    private function _getHitFXName( boGuard : Boolean, boCrit : Boolean ) : String {
        var sFXName : String;
        if ( boGuard ) {
            sFXName = hitData.GHitSFXName;
        } else if ( boCrit ) {
            sFXName = hitData.CHitSFXName;
        } else {
            sFXName = hitData.HitSFXName;
        }
        return sFXName;
    }

    public static function _getHitPosition( target : CGameObject, pCollidedCenter : CVector3 ) : CVector3 {
        var fZ : Number = NaN;
        var pDisplay : IDisplay = target.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( pDisplay ) {
            fZ = pDisplay.modelDisplay.position.z;
        }
        var fX : Number = pCollidedCenter.x;
        var fY : Number = pCollidedCenter.z;
        return new CVector3( fX, fY, fZ );
    }

    private function _findCriteriaTargets() : Boolean {
        var filterTargets : Array;
        if ( m_pSpecifyTargets == null )
            filterTargets = targetCriteriaComp.getTargetByCollision( hitEventSignal, hitData.TargetFilter );
        else
            filterTargets = m_pSpecifyTargets;

        if ( null == filterTargets || filterTargets.length == 0 )
            return false;

        m_collisionTargetList.splice( 0, m_collisionTargetList.length );
        for ( var i : int = 0; i < hitData.TargetNum && i < filterTargets.length; i++ ) {
            m_collisionTargetList[ i ] = filterTargets[ i ];
            if ( !m_targetDic[ filterTargets [ i ] ] ) {
                m_targetDic[ filterTargets [ i ] ] = new CHitStateInfo();
            }
        }

//        CSkillDebugLog.logTraceMsg( "**@CSkillHit：找到目标，对应击打标识为 hitEventSinal ：" + hitEventSignal + " 目标数量： " + filterTargets.length );

        return true;
    }

    private function sceneShake( iTypeOfHurt : int, pSceneShake : Array ) : void {
        var sceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        if ( !sceneMediator || !pSceneShake || !pSceneShake.length )
            return;

        var center2D : CVector3;
        var centerTransform : CKOFTransform;
        centerTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        center2D = new CVector3( centerTransform.x, centerTransform.y, centerTransform.z );

        if ( iTypeOfHurt == 2 ) {
            if ( pSceneShake[ 1 ] ) {
                for each ( var shakeID : int in pSceneShake[ 1 ] )
                    CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID, center2D );
            }

        } else {
            if ( pSceneShake[ 0 ] ) {
                for each ( var shakeID1 : int in pSceneShake[ 0 ] )
                    CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID1, center2D );
            }
        }

    }

    protected function get collisionTargetList() : Array {
        return m_collisionTargetList;
    }

    final private function get targetCriteriaComp() : CTargetCriteriaComponet {
        return m_pSkillContex.pTargetCriteriaComp;
    }

    private function get campID() : int {
        return m_pSkillContex.characterProperty.campID;
    }

    final private function get skillPropertyComp() : CSkillPropertyComponent {
        return owner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
    }

    private function _addToSuperControl( target : CGameObject ) : void{
        var nCurrentSkillID : int;
        var pMasterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent , true ) as CMasterCompomnent;

        var theSkillCaster : CSkillCaster = pSkillCaster;
        if( theSkillCaster )
                nCurrentSkillID = theSkillCaster.skillID ;

        if ( pMasterComp ) {
            if (pMasterComp.master ) {
                    nCurrentSkillID = pMasterComp.aliasSkillID;
            }
        }

        var superControl : CSuperControlComponent = target.getComponentByClass( CSuperControlComponent , true ) as CSuperControlComponent;
        var stateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        var missileSignal : int ;

        if( m_boHostDirectly && m_missileSeq >= 0 ) {
            nCurrentSkillID = m_nCurrentSkillID;
            if( CSkillUtil.boSuperSkill( nCurrentSkillID )) {
                missileSignal = m_missileSeq;
                superControl.missileHitToSuperControl( null, missileSignal );
                return;
            }
        } else if( nCurrentSkillID != 0 ) {
            var isMissile : Boolean = CCharacterDataDescriptor.isMissile( owner.data );
            var controller : CGameObject = isMissile ? pMasterComp.master : owner;
            if( superControl != null && stateBoard != null ) {
                if( CSkillUtil.boSuperSkill( nCurrentSkillID )){
                    //这里是为了在多个条件判定加入状态的或的逻辑
                    if( isMissile ) {
                        var missileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty , false ) as CMissileProperty;
                        if( missileProperty )
                            missileSignal = missileProperty.missileSeq;

                        superControl.missileHitToSuperControl( controller ,  missileSignal ) ;
                    }else{
                        superControl.addObjToSuperControl( controller );
                    }
                }
            }
        }
    }

    private function getMonsterInterruptTarget( skillID : int ) : Boolean {
        var bInterrupt : Boolean;
        var inSkill : Boolean;
        var pSkillInterrupt : CSkillInterruptList = owner.getComponentByClass( CSkillInterruptList, true ) as CSkillInterruptList;
        var pMasterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent , true ) as CMasterCompomnent;
        if ( pSkillInterrupt )
            bInterrupt = pSkillInterrupt.getIsInterruptSkill( pSkillCaster.skillID );

        if ( pMasterComp ) {
            if (pMasterComp.master ) {
                pSkillInterrupt = pMasterComp.master.getComponentByClass( CSkillInterruptList, true ) as CSkillInterruptList;
                if ( pSkillInterrupt )
                    bInterrupt = pSkillInterrupt.getIsInterruptSkill(pMasterComp.aliasSkillID );
            }
        }

        inSkill = skillID != 0 && !CSkillUtil.isHitSkill( CSkillUtil.getMainSkill( skillID ));
        return bInterrupt && inSkill;
    }

    //过滤函数
    private function onFilter( item : Object, index : int, arr : Array ) : Boolean {

        var character : CGameObject = item as CGameObject;
        if ( m_pLevelMediator ) {
            return m_pLevelMediator.isAttackable( character );
        }
        return false;
    }

    final private function get hitData() : Hit {
        return m_hitData;
    }

    final private function set hitData( value : Hit ) : void {
        m_hitData = value;
    }

    private var m_pSkillContex : CComponentUtility; //CSkillCasterContext;
    private var m_collisionTargetList : Array;
    private var m_collidedAreaList : Array;

    private var m_tickTime : Number;
    private var m_hurtCount : int = 0;
    private var m_hitCount : int = 0;
    private var m_hitData : Hit;
    //因为碰撞框检测到目标是按帧来检测的 所以这个碰撞框要一直tick
    private var m_boHitComplete : Boolean;
    private var m_targetDic : Dictionary;//要记录每个目标受击的次数
    private var m_pLevelMediator : CLevelMediator;
    private var m_pSpecifyTargets : Array;
    private var m_pSpecifyHitAeras : Array;
    private var m_pDistanceDiscreaseList : Array;

    //hose data
    private var m_boHitDirectly : Boolean;
    private var m_boHostDirectly : Boolean;
    private var m_damgeInfoList : Array;
    private var m_missileSeq : int = -1;
    private var m_nCurrentSkillID : int = -1 ;
    // 忽略防御运算和逻辑处理
    private var m_bSpecifyGuardIgnored : Boolean;
    private var m_pSpecifyHitPosition : Array;


}
}

