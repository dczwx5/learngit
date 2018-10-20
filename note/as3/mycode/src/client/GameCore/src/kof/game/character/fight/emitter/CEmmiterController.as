//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/16.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Framework.CObject;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CKOFTransform;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.level.CLevelMediator;
import kof.game.character.level.CScenarioComponent;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMissileProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Aero;
import kof.table.Aero.EAeroType;
import kof.table.Emitter;
import kof.table.Emitter.EApearPosType;
import kof.util.CObjectUtils;

/**
 * the class for emitter entity . just to control how often to shot the missile .or where the missile should appare
 */
public class CEmmiterController implements IUpdatable, IDisposable {
    public function CEmmiterController( skillOwner : CSkillCaster, emmiter : Emitter,
                                        hitEvent : String = '', defaultPos : CVector3 = null, targets : Array = null ) {
        m_pSkillCaster = skillOwner;
        m_pEmmiter = emmiter;
        m_sHitEvent = hitEvent;
        m_elapseTime = 0.0;
        m_theDefaulPos = defaultPos;
        m_theDefaultPosTargets = targets;
        m_missileData = CSkillCaster.skillDB.getAeroByID( m_pEmmiter.MissileID );
        m_bMonster = CCharacterDataDescriptor.isMonster( skillOwner.owner.data ) ||
                (pMasterComponent
                && pMasterComponent.ownerType == CCharacterDataDescriptor.TYPE_MONSTER);
    }

    public function dispose() : void {
        if ( m_pContainer )
            m_pContainer = null;

        isValid = false;
        m_pEmmiter = null;
        m_pSkillCaster = null;
        m_bound = null;
        if ( m_theDefaulPos ) m_theDefaulPos = null;
        if ( m_theDefaultPosTargets )
            m_theDefaultPosTargets.splice( 0, m_theDefaultPosTargets );
        m_theDefaultPosTargets = null;
    }

    public function update( delta : Number ) : void {
        if ( isNaN( m_elapseTime ) )
            return;

        m_elapseTime = m_elapseTime + delta;
        //create missile per time
        var curDelayTime : Number;
        if ( emmiterInfo && _hasNextIDByEmitter( emmiterInfo.ID ) ) {// pIdsRepository.hasNextIDByEmitter(emmiterInfo.ID)) {
            for ( var i : int = m_currentMissileIndex; i < emmiterInfo.MissileCount; i++ ) {
                curDelayTime = emmiterInfo.delay[ i ];
                if ( curDelayTime <= m_elapseTime ) {
                    shotMissile();
                    m_currentMissileIndex++;
                }
            }
        }

    }

    private function get pIdsRepository() : CMissileIdentifersRepository {
        var target : CGameObject;
        if (m_pSkillCaster != null &&  m_pSkillCaster.owner is CMissile ) {
            var spellerComp : CMasterCompomnent = m_pSkillCaster.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            target = spellerComp.master;
        } else {
            target = m_pSkillCaster.owner;
        }

        if( target != null )
            return target.getComponentByClass( CMissileIdentifersRepository, true ) as CMissileIdentifersRepository;

        return null;
    }

    private function _hasNextIDByEmitter( emitterID : int ) : Boolean {
//        if ( m_bMonster || pLevelMediator.isPVE ) return true;
        if( isPlayingScenario ) return true;
        var pRespoitory : CMissileIdentifersRepository = pIdsRepository;
        if( null == pRespoitory ) return false;
        return pRespoitory.hasNextIDByEmitter( emmiterInfo.ID );
    }

    public function lastUpdate( delta : Number ) : void {
        if ( m_currentMissileIndex >= emmiterInfo.MissileCount ) {
            m_elapseTime = NaN;
            m_pContainer.removeEmmiter( this );
        }
    }

    public function setContainer( eContainer : CEmitterContainer ) : void {
        m_pContainer = eContainer;
    }

    private function shotMissile() : void {
        _buildMissiles();
    }

    final private function  get pMasterComponent() : CMasterCompomnent {
        return m_pSkillCaster.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
    }

    private function _decodeMissileData( pos : CVector3 = null ) : Object {
        var missileData : Object;
        var axis2D : CVector3 = pos;
        var missile : Aero = CSkillCaster.skillDB.getAeroByID( m_pEmmiter.MissileID );//missile.SFXName
        var pDisplsy : IDisplay = m_pSkillCaster.pComUtility.modelDisplay;
        var playerPorperty : CCharacterProperty = m_pSkillCaster.pComUtility.characterProperty;
        var missilePorperty : CMasterCompomnent = m_pSkillCaster.owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        var dir : int = pDisplsy.direction;

        missileData = {};
        missileData[ "fightProperty" ] = CObjectUtils.cloneObject( playerPorperty.fightProperty );
        missileData[ "campID" ] = CCharacterDataDescriptor.getCampID( m_pSkillCaster.owner.data );
        missileData[ "skin" ] = missile.MissleSpine;
        missileData[ "x" ] = axis2D.x;
        missileData[ "y" ] = axis2D.y;
        missileData[ "z" ] = axis2D.z;
        missileData[ "direction" ] = dir;
        missileData[ "missileId" ] = m_pEmmiter.MissileID;
        missileData[ "missileSeq" ] = _getNextSeqID();// missileIdRep.getNextIDByEmitter( emmiterInfo.ID );//this.m_currentMissileIndex;
        missileData[ "type" ] = CCharacterDataDescriptor.TYPE_MISSILE;
        missileData[ "missileHP" ] = missile.HMBeHit;

        var ownerType : int = CCharacterDataDescriptor.getType( m_pSkillCaster.owner.data );
        if ( ownerType == CCharacterDataDescriptor.TYPE_MISSILE ) {
            missileData[ "ownerId" ] = missilePorperty.ownerId;
            missileData[ "ownerType" ] = missilePorperty.ownerType;
            missileData[ "ownerSkin" ] = missilePorperty.ownerSkin;
            missileData[ "aliasSkillID" ] = missilePorperty.aliasSkillID;

        } else if ( ownerType == CCharacterDataDescriptor.TYPE_PLAYER ||
                ownerType == CCharacterDataDescriptor.TYPE_MONSTER ) {
            missileData[ "ownerId" ] = CCharacterDataDescriptor.getID( m_pSkillCaster.owner.data );
            missileData[ "ownerType" ] = CCharacterDataDescriptor.getType( m_pSkillCaster.owner.data );
            missileData[ "ownerSkin" ] = CCharacterDataDescriptor.getSkinName( m_pSkillCaster.owner.data );
            missileData[ "aliasSkillID" ] = m_pSkillCaster.skillID;
        }

        missileData[ "moveSpeed" ] = 1;

        return missileData;
    }

    private function _dispatchActivateMissile(missileSeq : Number , position : CVector3 ) : void {
        var missileOwner : CGameObject;
        if ( pMasterComponent )
            missileOwner = pMasterComponent.master;
        else
            missileOwner = m_pSkillCaster.owner;
        if( missileOwner ) {
            var pFightTrigger : CCharacterFightTriggle = missileOwner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.HERO_MISSILE_ACTIVATE, null ,[missileSeq , emmiterInfo.ID,position ]) );
        }
    }

    private function _getNextSeqID() : int {
//        if ( m_bMonster || pLevelMediator.isPVE )
        if( isPlayingScenario )
            return m_currentMissileIndex;

        var missileIdRep : CMissileIdentifersRepository = pIdsRepository ;// m_pSkillCaster.owner.getComponentByClass( CMissileIdentifersRepository, true ) as CMissileIdentifersRepository;
        if( missileIdRep == null )
                return 0;
        return missileIdRep.getNextIDByEmitter( emmiterInfo.ID );
    }

    private function get isPlayingScenario() : Boolean{
        var pLevelMediator : CLevelMediator = m_pSkillCaster.owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
        if( null == pLevelMediator )
                return false;
        return pLevelMediator.isPlayingScenario();
    }

    private function _buildMissiles() : void {
        var type : int = emmiterInfo.MissileBornPos;
        var missileAppearPos : CVector3;
        var missileData : Object;
        var eContainer : CMissileContainer = m_pSkillCaster.missileContainer;
        var missileSeq: Number
        switch ( type ) {
            case EApearPosType.EApearOwener:
            case EApearPosType.Erandom:
            {
                missileAppearPos = extraMissileBornPos();
                missileData = _decodeMissileData( missileAppearPos );
                if ( missileData != null ) {
                    missileSeq = missileData.missileSeq;
                    eContainer.shotMissile( missileData );
                     _dispatchActivateMissile( missileSeq , new CVector3( missileData.x , missileData.y , missileData.z ));
                }
                break;
            }
            case EApearPosType.EApearCollise:
            {
                var boFindTarget : Boolean;
                var targets : Array = m_theDefaultPosTargets;
                if ( !targets || targets.length == 0 )
                    targets = pCriteriaComp.getTargetByCollision( m_sHitEvent, m_pEmmiter.TargetFilter );

                var target : CGameObject;
                if ( targets && targets.length != 0 ) {
                    var maxTargetCnt : int = CMath.min( m_pEmmiter.MissileCount, targets.length );
                    var pTransform : CKOFTransform;

                    for ( var i : int = 0; i < maxTargetCnt; i++ ) {
                        target = targets[ i ];
                        if ( !target || !target.isRunning )
                            continue;

                        pTransform = target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;

                        if ( !pTransform ) return;
                        var fHeight : Number = pTransform.z + m_pEmmiter.EffectOffsetPosy;
                        var offsetHeight : Number = fHeight < 0 ? 0 : fHeight;
                        missileAppearPos = CObject.get2DPositionFrom3D( pTransform.x + m_pEmmiter.EffectOffsetPosx,
                                offsetHeight, pTransform.y + m_pEmmiter.EffectOffsetPosz );

                        missileData = _decodeMissileData( new CVector3( missileAppearPos.x, missileAppearPos.y, offsetHeight ) );
                        if ( missileData != null ) {
                            missileSeq = missileData.missileSeq;
                            eContainer.shotMissile( missileData );
                            _dispatchActivateMissile(missileSeq , new CVector3( missileData.x , missileData.y , missileData.z));
                            return;
                        }
                    }

                    boFindTarget = true;
                }

                if ( m_theDefaulPos && !boFindTarget ) {
                    missileAppearPos = _findCollisePosition( m_theDefaulPos ).m_vCenterPosition;
                    missileData = _decodeMissileData( missileAppearPos );
                    if ( missileData != null ) {
                        missileSeq =  missileData.missileSeq;
                        eContainer.shotMissile( missileData );
                        _dispatchActivateMissile(missileSeq , missileAppearPos);
                        return;
                    }
                }

                CSkillDebugLog.logTraceMsg( " controller can't shot missile  for appear  Pos type : " + type );

                break;
            }
            default:
                CSkillDebugLog.logTraceMsg( " no implement for appear  Pos type : " + type );

        }
    }

    private function extraMissileBornPos() : CVector3 {
        var type : int = emmiterInfo.MissileBornPos;
        switch ( type ) {
            case EApearPosType.EApearOwener:
            {
                var retPosition : CVector3;
                if ( m_theDefaulPos ) {
                    retPosition = _findCollisePosition( m_theDefaulPos ).m_vCenterPosition;

                    return retPosition;
                }
                retPosition = _findCollisePosition().m_vCenterPosition;
                return retPosition;
            }
            //fixme
            case EApearPosType.EApearEffectTarget:
                CSkillDebugLog.logTraceMsg( " no implement for apear  Pos type : " + type );
                return null;
            //fixme
            case  EApearPosType.EApearTarget:
                CSkillDebugLog.logTraceMsg( " no implement for apear  Pos type : " + type );
                return null;
            case EApearPosType.Erandom:
            {
                var colInfo : CollisionInfo = _findCollisePosition( null, true );
                retPosition = colInfo.m_vCenterPosition;
//                var delta : int = CMath.rand() < 0.5 ? 1 : -1;
//                var retExt : CVector3 = colInfo.m_vCollisionBox;
//                var randomX : Number = CMath.rand() * retExt.x * delta;
//                var randomY : Number = CMath.rand() * retExt.z * delta;
//                var randomZ : Number = CMath.rand() * retExt.y * delta;
//                retPosition.addOnValueXYZ( randomX, randomY, randomZ );
                return retPosition;
            }
            default:
                //fixme
                CSkillDebugLog.logTraceMsg( " no implement for apear  Pos type : " + type );
                return null;
        }

        return null;
    }

    private function _findCollisePosition( defaultPos : CVector3 = null, bRandom : Boolean = false ) : CollisionInfo {

        var kofTranform : CKOFTransform = m_pSkillCaster.owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        var offset : CVector3 = CVector3.ZERO.clone();
        var centerPos : CVector3;
        var m_bound : CCharacterCollisionBound = pCollisionComp.getCollisionBoundByHitEvent( m_sHitEvent ) as CCharacterCollisionBound;
        var collisionInfo : CollisionInfo = new CollisionInfo();
        var randomY : Number = 0.0;
        var randomX : Number = 0.0;
        var randomZ : Number = 0.0;
        if ( m_bound ) {
            var localAABB : CAABBox3;
            localAABB = m_bound.characterCollision.testAABBBox;
            collisionInfo.m_vCollisionBox = new CVector3( localAABB.extX, localAABB.extY, localAABB.extZ );
            if ( bRandom && localAABB ) {
                var delta : int = CMath.rand() < 0.5 ? 1 : -1;
                randomX = CMath.rand() * collisionInfo.m_vCollisionBox.x * delta;
                randomY = CMath.rand() * collisionInfo.m_vCollisionBox.y * delta;
                randomZ = CMath.rand() * collisionInfo.m_vCollisionBox.z * delta;
            }
            centerPos = localAABB.center;
            offset.setValueXYZ( centerPos.x, centerPos.y, centerPos.z );
        }
        else {
            if ( defaultPos ) {
                centerPos = defaultPos;
                offset.setValueXYZ( centerPos.x, centerPos.y, centerPos.z );
            } else
                offset.addOnValueXYZ( kofTranform.x, kofTranform.y, kofTranform.z );
        }
        offset.addOnValueXYZ( m_pEmmiter.EffectOffsetPosx, 0, m_pEmmiter.EffectOffsetPosz );

        if ( bRandom ) {
            offset.addOnValueXYZ( randomX, randomY, randomZ );
        }

        //
        if ( m_missileData && m_missileData.MoveType == EAeroType.E_PHYSICAL && pSceneMediator ) {

            var kofTransform : CKOFTransform = m_pSkillCaster.owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            if ( !pSceneMediator.isWalkable( offset.x, kofTranform.y, 0 ) ) {
                if ( kofTransform ) {
                    offset.x = kofTransform.x;
                }
            }
        }
        var fHeight : Number = offset.z + m_pEmmiter.EffectOffsetPosy;

        offset.z = fHeight < 0 ? 0 : fHeight;
        //
        var offset2D : CVector3 = CObject.get2DPositionFrom3D( offset.x, offset.z, offset.y );

//        var fHeight : Number = offset2D.z + m_pEmmiter.EffectOffsetPosy;

//        offset2D.z = fHeight < 0 ? 0 : fHeight;
        collisionInfo.m_vCenterPosition = new CVector3( offset2D.x, offset2D.y, offset.z );
        return collisionInfo;
    }

    final private function get pCollisionComp() : CCollisionComponent {
        return m_pSkillCaster.pComUtility.collisionComponent;
    }

    final private function get pCriteriaComp() : CTargetCriteriaComponet {
        return m_pSkillCaster.owner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
    }

    final private function get pSceneMediator() : CSceneMediator {
        return m_pSkillCaster.owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
    }

    final private function get pLevelMediator() : CLevelMediator{
        return m_pSkillCaster.owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
    }

    public function reActive() : void {
        isValid = true;
        m_currentMissileIndex = 0;
    }

    public function get isValid() : Boolean {
        return m_isValid;
    }

    public function set isValid( value : Boolean ) : void {
        m_isValid = value;
    }

    public function get emmiterInfo() : Emitter {
        return m_pEmmiter;
    }

    public function set cBound( value : CCharacterCollisionBound ) : void {
        m_bound = value;
    }


    private var m_elapseTime : Number = 0.0;
    private var m_pSkillCaster : CSkillCaster;
    private var m_pEmmiter : Emitter;
    private var m_isValid : Boolean;
    private var m_currentMissileIndex : int;
    private var m_pContainer : CEmitterContainer;
    private var m_bound : CCharacterCollisionBound;
    private var m_sHitEvent : String;
    private var m_theDefaulPos : CVector3;
    private var m_theDefaultPosTargets : Array;
    private var m_missileData : Aero;
    private var m_bMonster : Boolean;
}
}

import QFLib.Math.CVector3;

class CollisionInfo {
    public var m_vCenterPosition : CVector3;
    public var m_vCollisionBox : CVector3;
}
