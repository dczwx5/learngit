//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/10/26.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation.CMap;
import QFLib.Math.CAABBox3;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import kof.game.character.CKOFTransform;

import kof.game.character.animation.IAnimation;

import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;

import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillHit;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.util.CSkillScreenIns;
import kof.game.character.property.CMissileProperty;
import kof.game.core.CGameObject;
import kof.table.AeroAbsorber;

/**
 * just excited when hit missile
 */
public class CSkillMissileHitEffect extends CAbstractSkillEffect {
    public function CSkillMissileHitEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        if ( m_absorbingInfoList )
            m_absorbingInfoList.clear();

        if ( m_targets )
            m_targets.splice( 0, m_targets.length );

        if ( m_collisionTargets )
            m_collisionTargets.splice( 0, m_collisionTargets.length );

        m_absorbingInfoList = null;
        m_collisionTargets = null;
        m_targets = null;
        m_absorbingInfoList = null;

        if( m_directlyAbsorbingTargets )
                m_directlyAbsorbingTargets.splice( 0 , m_directlyAbsorbingTargets.length );
        m_directlyAbsorbingTargets = null;

        super.dispose();
    }

    override public function update( delta : Number ) : void {
        if ( m_aeroAbsorbInfo == null )return;
        super.update( delta );
        updateAbsorbingInfo( delta );
        if ( !_findMissile() ) return;
        _absorbMissile();
    }

    override public function lastUpdate( delta : Number ) : void {
        super.lastUpdate( delta );
    }

    private function updateAbsorbingInfo( delta : Number ) : void {
        for each( var _info : AbsorbingTargetInfo in m_absorbingInfoList ) {
            if ( _info )
                _info.update( delta );
        }
    }

    override public function initData( ... args ) : void {
        m_aeroAbsorbInfo = CSkillCaster.skillDB.getAeroAbsorberByID( effectID );
        m_absorbingInfoList = new CMap();
    }

    private function _absorbMissile() : void {
        var rets : Array = new Array();
        for each ( var colTarget : CGameObject in m_collisionTargets ) {
            var absorbInfo : AbsorbingTargetInfo = m_absorbingInfoList[ colTarget ];
            if ( ( absorbInfo != null && !absorbInfo.bTimeToAbsorb) )
                continue;
            rets.push( colTarget );
        }

        var maxTargetCount : int = m_aeroAbsorbInfo.TargetNum;
        if ( rets.length > 0 ) {
            rets = rets.splice( 0, CMath.min( maxTargetCount, rets.length ) );
            _doAbsorbTargets( rets );
            if ( pFightTrigger ) {
                pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_MISSILE_ABSORB, null, [m_aeroAbsorbInfo.ID, rets ] ) );
                pFightTrigger.dispatchEvent(
                        new CFightTriggleEvent( CFightTriggleEvent.HIT_TARGET, null, [ pSkillCaster.skillID ] ) );
            }
        }
    }

    private function _doAbsorbTargets( targets : Array ) : void {
        var maxCount : int = m_aeroAbsorbInfo.TimesAtOneTarget;
        var span : int = m_aeroAbsorbInfo.EffectSpan;

        for each( var target : CGameObject in targets ) {
            var absorbInfo : AbsorbingTargetInfo = m_absorbingInfoList[ target ];
            var collideBox : CAABBox3;
            var collisionPosition : CVector3;
            var targetAnimation : IAnimation;

            collideBox = pCollisionComp.getCollisedArea( this.hitEventSignal, target );
            if ( absorbInfo == null ) {
                absorbInfo = new AbsorbingTargetInfo( target, span, maxCount );
                m_absorbingInfoList.add( target, absorbInfo );
            }

            targetAnimation = target.getComponentByClass( IAnimation, true ) as IAnimation;

            _frozenAttacker( m_aeroAbsorbInfo.AttackerStopTime * CSkillDataBase.TIME_IN_ONEFRAME );

            targetAnimation.frozenFrame( m_aeroAbsorbInfo.TargetStopTime * CSkillDataBase.TIME_IN_ONEFRAME, _absorbMissileHP, target );

            _playHitSound( m_aeroAbsorbInfo.HitSoundEffect );

            collisionPosition = CSkillHit._getHitPosition( target, collideBox.center );
            _playHitFX( m_aeroAbsorbInfo.HitSFXName, collisionPosition );
            _shakeCamera( m_aeroAbsorbInfo.HitCameraEffect );

            if ( m_targets == null )
                m_targets = [];
            if ( m_targets.indexOf( target ) < 0 )
                m_targets.push( target );
            absorbInfo.doEffectToTarget();
        }
    }

    private function _absorbMissileHP( missile : CGameObject ) : void {
        if ( !missile || !missile.isRunning )
            return;

        var minusHP : int = m_aeroAbsorbInfo.AbsorbDefCnt;
        var pMissileProperty : CMissileProperty = missile.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        if ( pMissileProperty )
            pMissileProperty.missileHP = pMissileProperty.missileHP - minusHP;
    }

    private function _playHitSound( pSounds : String ) : void {
        var soundMedia : CAudioMediator = owner.getComponentByClass( CAudioMediator, true ) as CAudioMediator;
        if ( !soundMedia || !pSounds || !pSounds.length )
            return;
        soundMedia.playAudioByName( pSounds )
    }

    private function _playHitFX( fxName : String, collidePos : CVector3 ) : void {
        pFxMediator.playBindHitEffect( fxName, collidePos, 20 );
    }

    private function _frozenAttacker( fFrozenTime : Number ) : void {
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation )
            pAnimation.frozenFrame( fFrozenTime, null );
    }

    private function _shakeCamera( shakeID : int ) : void {
        if ( shakeID == 0 )
            return;
        var center2D : CVector3;
        var centerTransform : CKOFTransform;
        centerTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        center2D = new CVector3( centerTransform.x, centerTransform.y, centerTransform.z );
        CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( owner, shakeID, center2D );
    }

    protected function _findMissile() : Boolean {
        var pTargetCri : CTargetCriteriaComponet = owner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
        var ret : Array = pTargetCri.getTargetByCollision( hitEventSignal, m_aeroAbsorbInfo.TargetFilter );
        m_collisionTargets = ret;
        if ( m_collisionTargets && m_collisionTargets.length > 0 )
            return true;
        return false;
    }

    private final function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    private final function get pCollisionComp() : CCollisionComponent {
        return owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
    }

    private var m_aeroAbsorbInfo : AeroAbsorber;
    private var m_targets : Array;
    protected var m_collisionTargets : Array;
    private var m_absorbingInfoList : CMap;
    private var m_directlyAbsorbingTargets : Array;
}
}

import QFLib.Interface.IUpdatable;

import kof.game.core.CGameObject;

class AbsorbingTargetInfo implements IUpdatable {
    var m_pTarget : CGameObject;
    var m_fElapseTime : Number;
    var m_fLastEffectTime : Number;
    var m_fSpanTime : Number;
    var m_nMaxCount : int;
    var m_nCurrentHitCnt : int;


    public function AbsorbingTargetInfo( target : CGameObject, spanTime : Number, maxCount : int ) : void {
        m_fSpanTime = spanTime;
        m_nMaxCount = maxCount;
        m_pTarget = target;
    }

    public function update( delta : Number ) : void {
        if ( !isNaN( m_fElapseTime ) )
            m_fElapseTime += delta;
    }

    public function get target() : CGameObject {
        return m_pTarget;
    }

    public function get elapseTime() : Number {
        return m_fElapseTime;
    }

    public function get bTimeToAbsorb() : Boolean {
        if ( m_nCurrentHitCnt >= m_nMaxCount )
            return false;
        return m_fElapseTime > m_fSpanTime * m_nCurrentHitCnt;
    }

    public function doEffectToTarget() : void {
        reset();
        if ( isNaN( m_fElapseTime ) )
            m_fElapseTime = 0.0;

        m_nCurrentHitCnt++;
    }

    public function reset() : void {
        m_pTarget = null;
        m_fElapseTime = 0.0;
        m_fLastEffectTime = 0.0;
    }
}
