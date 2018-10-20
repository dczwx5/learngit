//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/13.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.emitter.CMissile;
import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.syncentity.CHitStateSync;
import kof.game.character.fight.sync.synctimeline.base.CCharacterFightData;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterHitAction;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.message.Fight.HitRequest;
import kof.message.Fight.HitResponse;
import kof.table.Hit;

public class CHitStrategy extends CBaseStrategy {
    public function CHitStrategy() {
        super();
    }

    override public function doRequestAction() : void {

    }

    override public function doResponseAction() : void {
        var bValid : Boolean = true;
        var bIsMissile : Boolean;
        bIsMissile = hitResponse.dynamicStates && hitResponse.dynamicStates.hasOwnProperty( 'isMissile' ) ?
                hitResponse.dynamicStates[ 'isMissile' ] : false;

        //Missile Hit
        if ( bIsMissile && bValid ) {
            _responseFightHit();
            _handleMissileHit();
            return;
        }
        // execute hit
        if ( bValid ) {
            _responseFightHit();
        }
    }

    /**
     override public function doResponseAction() : void {

        //无效击打回滚状态:前续节点有global击打，并且hurttime大于节点间的时间差
        var bValid : Boolean = true;
        var bIsMissile : Boolean;
        if ( prevGlobalNode ) {
            var prevGlobalHitAction : CFighterHitAction;
            prevGlobalHitAction = _checkIfPrevGlobalNodeHit() as CFighterHitAction;
            bValid = prevGlobalHitAction == null;
            if ( !bValid ) {
                _rollBackStateToHitAction( prevGlobalHitAction );
                return;
            }
        }

        bIsMissile = hitResponse.dynamicStates && hitResponse.dynamicStates.hasOwnProperty( 'isMissile' ) ?
                hitResponse.dynamicStates[ 'isMissile' ] : false;

        if ( bIsMissile && bValid ) {
//            _responseMissileHit();
            _handleMissileHit();
            _responseFightHit();

            return;
        }
        // execute hit
        if ( bValid ) {
            _responseFightHit();
        }
    }
     */
    private function _handleMissileHit() : void {
        var missileID : int;
        var missileSeq : int;
        missileID = hitResponse.dynamicStates && hitResponse.dynamicStates.hasOwnProperty( 'missileID' ) ?
                hitResponse.dynamicStates[ 'missileID' ] : -1;
        missileSeq = hitResponse.dynamicStates && hitResponse.dynamicStates.hasOwnProperty( 'missileSeq' ) ?
                hitResponse.dynamicStates[ 'missileSeq' ] : -1;
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        var pHitMissile : CGameObject;
        if ( pSkillCaster ) {
            var missileFightTrigger : CCharacterFightTriggle;
            pHitMissile = pSkillCaster.findMissileBySeq( missileSeq );

            if ( pHitMissile ) {

                missileFightTrigger = pHitMissile.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( missileFightTrigger ) {
                    missileFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.HIT_TARGET, null, null ) );
                }
            }
        }

    }

    private function _responseMissileHit() : void {
        var msg : HitResponse = hitResponse;
        var targetInfo : Object;

        //这里设置自己的状态
        var pSceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        _setSyncCharacterStatsWithDynamic( owner, msg.dynamicStates );
        _setInputDiretion( owner, msg.dirX, msg.dirY );
        //处理击打目标同步问题
        var targetInfoList : Array = msg.targets;

        if ( targetInfoList != null ) {
            var hitTarget : CGameObject;
            var theFirstTargetInfo : Object;
            var hitQueueID : int;
            var hitID : int;
            var targetList : Array;
            var skillHitQueueID : int;

            theFirstTargetInfo = targetInfoList[ 0 ];
            hitID = msg.hitId;
            hitQueueID = theFirstTargetInfo.queueID;
            skillHitQueueID = msg.dynamicStates.skillHitQueueID;

            if ( pSceneMediator ) {
                targetList = [];
                for each( targetInfo  in targetInfoList ) {
                    hitTarget = pSceneMediator.findGameObj( targetInfo.type, targetInfo.ID );
                    if ( hitTarget ) {
                        var boLocalHasHitted : Boolean;
                        boLocalHasHitted = getBoPuppetHitTarget( hitID, hitQueueID, hitTarget, skillHitQueueID );

                        if ( !boLocalHasHitted ) {
                            var targetSyncStateBoard : CCharacterSyncBoard;
                            targetSyncStateBoard = hitTarget.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
                            _setSyncCharacterStatsWithDynamic( hitTarget, targetInfo.dynamicStates );
                        }
                    }
                }
                _syncPuppetStatFromHostHit( hitID, hitQueueID, targetList, skillHitQueueID );
                _resetTargetsHitSyncBoard( targetList );
            }
        }
    }

    private function _syncPuppetStatFromHostHit( hitId : int, hitQueueID : int, targetList : Array, skillHitQueueID : int ) : void {
        var pPupetHostComp : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( pPupetHostComp ) {
            var vTargets : Vector.<CGameObject> = new <CGameObject>[];
            for each( var theTar : CGameObject in targetList ) {
                vTargets.push( theTar );
            }
            pPupetHostComp.syncFromHostHit( hitId, hitQueueID, vTargets, skillHitQueueID );
        }
    }

    private function _resetTargetsHitSyncBoard( targetList : Array ) : void {
        for each( var clearTarget : CGameObject in targetList ) {
            var clearBoard : CCharacterSyncBoard;
            if ( clearTarget ) {
                clearBoard = clearTarget.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
                clearBoard.clearAllDirty();
            }
        }
    }

    private function _checkIfPrevGlobalNodeHit() : CBaseFighterKeyAction {
        var fighterDataList : Vector.<CCharacterFightData> = prevGlobalNode.nodeFightData.getFighterDatas();
        for each( var fighterData : CCharacterFightData in fighterDataList ) {
            var keyAction : CBaseFighterKeyAction;
            for each ( keyAction in fighterData.fighterActions ) {
                var hitAction : CFighterHitAction;
                var hitInfo : Hit;
                var bHitFirst : Boolean;
                if ( keyAction == null || keyAction.type != EFighterActionType.E_HIT_ACTION ) {
                    continue;
                }

                hitAction = keyAction as CFighterHitAction;
                if ( null != hitAction.findHitTarget( owner ) ) {
                    hitInfo = CSkillCaster.skillDB.getHitDataByID( hitAction.HitID );
                    if ( hitInfo ) {
                        bHitFirst = (hitInfo.HitHurtTime + hitInfo.HitStopTime) > (timelineNode.nodeDataTime - prevGlobalNode.nodeDataTime);
                    }
                    if ( bHitFirst )
                        return hitAction;
                }
            }
        }
        return null;
    }

    private function _responseFightHit() : void {
        var msg : HitResponse = hitResponse;
        var targetInfo : Object;

        //这里设置自己的状态
        var pSceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        var boIgnoreGuard : Boolean;

        _setInputDiretion( owner, msg.dirX, msg.dirY );
        if ( msg.dynamicStates && msg.dynamicStates.hasOwnProperty( CCharacterSyncBoard.BO_IGNORE_GUARD ) ) {
            boIgnoreGuard = msg.dynamicStates[ CCharacterSyncBoard.BO_IGNORE_GUARD ];
        }
        //处理击打目标同步问题
        var targetInfoList : Array = msg.targets;

        if ( targetInfoList != null && targetInfoList.length > 0 ) {
            var hitTarget : CGameObject;
            var theFirstTargetInfo : Object;
            var hitQueueID : int;
            var hitID : int;
            var targetList : Array;
            var hitFxPosionList : Array;
            var distanceDiscreaseList : Array;
            var skillHitQueueID : int;
            var damageInfos : Array;

            theFirstTargetInfo = targetInfoList[ 0 ];
            hitID = msg.hitId;
            hitQueueID = theFirstTargetInfo.queueID;
            skillHitQueueID = msg.dynamicStates.skillHitQueueID;

            var hitData : Hit = CSkillCaster.skillDB.getHitDataByID(hitID);
            if( hitData && hitData.DamageID == 0 ){
                return;
            }

            if ( pSceneMediator ) {
                targetList = [];
                hitFxPosionList = [];
                distanceDiscreaseList = [];
                damageInfos = [];
                for each( targetInfo  in targetInfoList ) {

                    var damageInfo : Object = {};
                    var fxPosition : CVector3 = CVector3.zero();

                    hitTarget = pSceneMediator.findGameObj( targetInfo.type, targetInfo.ID );
                    if ( hitTarget ) {
                        var effectPos : Object;
                        var boLocalHasHitted : Boolean;
                        boLocalHasHitted = getBoPuppetHitTarget( hitID, hitQueueID, hitTarget, skillHitQueueID );

                        if ( !boLocalHasHitted ) {
                            var targetStateBoard : CCharacterStateBoard;
                            var distanceDiscrease : Number;
                            var boPaBody : Boolean;
                            targetStateBoard = hitTarget.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                            boPaBody = targetStateBoard.getValue( CCharacterStateBoard.PA_BODY );

                            if ( targetInfo.dynamicStates ) {
                                var ds : Object = targetInfo.dynamicStates;
                                var fHeight : Number = 0.0;
                                if( ds.hasOwnProperty(CCharacterSyncBoard.NHEIGHT_PLAYER ))
                                    fHeight = targetInfo.dynamicStates[ CCharacterSyncBoard.NHEIGHT_PLAYER ];

                                if ( !boPaBody && !targetInfo.dynamicStates[ CCharacterSyncBoard.BO_PA_BODY ] )
                                    _setPosition( hitTarget, targetInfo.posX, targetInfo.posY, false, fHeight );

                                distanceDiscrease = targetInfo.dynamicStates[ CCharacterSyncBoard.HIT_MOTION_RADIO ];

                                effectPos = targetInfo.dynamicStates[ CCharacterSyncBoard.HIT_EFFECT_POINT ];
                                if ( effectPos )
                                    fxPosition = new CVector3( effectPos.fx, effectPos.fy, effectPos.fz );
                            }

                            var dynamicState : Object = targetInfo.dynamicStates;
                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.DAMAGE_HURT ) )
                                damageInfo[ CCharacterSyncBoard.DAMAGE_HURT ] = targetInfo.dynamicStates[ CCharacterSyncBoard.DAMAGE_HURT ];

                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.BO_CRITICAL_HIT ) )
                                damageInfo[ CCharacterSyncBoard.BO_CRITICAL_HIT ] = targetInfo.dynamicStates[ CCharacterSyncBoard.BO_CRITICAL_HIT ];

                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.BO_PA_BODY ) )
                                damageInfo[ CCharacterSyncBoard.BO_PA_BODY ] = targetInfo.dynamicStates[ CCharacterSyncBoard.BO_PA_BODY ];

                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.DEFENSE_POWER ) )
                                damageInfo[ CCharacterSyncBoard.DEFENSE_POWER ] = targetInfo.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER ];

                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.BO_ON_GROUND ) )
                                damageInfo[ CCharacterSyncBoard.BO_ON_GROUND ] = targetInfo.dynamicStates[ CCharacterSyncBoard.BO_ON_GROUND ];

                            if ( dynamicState.hasOwnProperty( CCharacterSyncBoard.BO_GUARD ) )
                                damageInfo[ CCharacterSyncBoard.BO_GUARD ] = targetInfo.dynamicStates[ CCharacterSyncBoard.BO_GUARD ];
                            if( dynamicState.hasOwnProperty( CCharacterSyncBoard.BO_COUNTER) )
                                damageInfo[ CCharacterSyncBoard.BO_COUNTER] = targetInfo.dynamicStates[ CCharacterSyncBoard.BO_COUNTER];
                            if( dynamicState.hasOwnProperty(CCharacterSyncBoard.MOTION_ID))
                                damageInfo[ CCharacterSyncBoard.MOTION_ID] = targetInfo.dynamicStates[ CCharacterSyncBoard.MOTION_ID];

                            targetList.push( hitTarget );
                            hitFxPosionList.push( fxPosition );
                            damageInfos.push( damageInfo );
                            distanceDiscreaseList.push( distanceDiscrease );
                            _syncPuppetsProperty( targetInfo );
                        }
                    }
                }

                var missileSeq : int = hitResponse.dynamicStates && hitResponse.dynamicStates.hasOwnProperty( 'missileSeq' ) ?
                        hitResponse.dynamicStates[ 'missileSeq' ] : -1;

                var skillId : int = hitResponse.skillID;

                pSkillCaster.castHostHitToTargets( hitID, skillHitQueueID, targetList, boIgnoreGuard,
                        hitFxPosionList, distanceDiscreaseList, damageInfos, missileSeq, skillId );

                _syncPuppetStatFromHostHit( hitID, hitQueueID, targetList, skillHitQueueID );
            }
        }
    }

    private function getBoPuppetHitTarget( hitID : int, hitQueueID : int, hitTarget : CGameObject, skillHitQueueID : int ) : Boolean {
        return false;
        var thePuppetInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        var responseComp : CCharacterResponseQueue = owner.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
        var hostSkillQueueID : Number;
        if ( responseComp ) {
            hostSkillQueueID = responseComp.curSkillQueue.queueID;
        }

        if ( thePuppetInput ) {
            var puppetHitInfos : Vector.<CHitStateSync> = thePuppetInput.getPuppetHitBySkillQueue( hostSkillQueueID, hitID );
            if ( puppetHitInfos && puppetHitInfos.length == 0 )
                return false;

            if ( null == puppetHitInfos || (puppetHitInfos && puppetHitInfos.length == 0 ) ) {
                //子弹打中
                return false;
            }
            for each( var hitState : CHitStateSync in puppetHitInfos ) {
                var pTargets : Vector.<CGameObject> = hitState.hitTargetList;
                var boRet : Boolean;
                boRet = hitState.skillHitQueueID == skillHitQueueID;
                boRet = boRet && pTargets;
                boRet = boRet && (pTargets.indexOf( hitTarget ) >= 0);

                if ( boRet )
                    return true;
            }
        }

        return false;
    }

    private function _syncPuppetsProperty( targetInfo : Object ) : void {
        var sceneFacade : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        var targetProperty : CCharacterProperty;
        if ( sceneFacade ) {
            var hitTarget : CGameObject = sceneFacade.findGameObj( targetInfo.type, targetInfo.ID );
            if ( hitTarget != null ) {
                if ( hitTarget ) {
                    targetProperty = hitTarget.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                    targetProperty.DefensePower = targetInfo.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER ];
                }
            }
        }
    }

    private function _rollBackStateToHitAction( hitAction : CFighterHitAction ) : void {
        var myStateObj : Object = hitAction.findHitTarget( owner );
        if ( myStateObj ) {
            var sceneFacade : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
            var targetProperty : CCharacterProperty;
            var targetStateBoard : CCharacterStateBoard;
            if ( sceneFacade ) {
                var hitTarget : CGameObject = sceneFacade.findGameObj( myStateObj.type, myStateObj.ID );
                if ( hitTarget != null ) {
                    if ( hitTarget ) {
                        targetProperty = hitTarget.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                        targetStateBoard = hitTarget.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                        targetProperty.DefensePower = myStateObj.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER ];// - targetInfo.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER_DELTA ];

                        var syncDir : int = myStateObj.dynamicStates[ CCharacterSyncBoard.SKILL_DIR ];
                        targetStateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( syncDir, 0 ) );
                    }
                }
            }
        }
    }

    private function get hitRequest() : HitRequest {
        return action.actionData as HitRequest;
    }

    private function get hitResponse() : HitResponse {
        return action.actionData as HitResponse;
    }
}
}
