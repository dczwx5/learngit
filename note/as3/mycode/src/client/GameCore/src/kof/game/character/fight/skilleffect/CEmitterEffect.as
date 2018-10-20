//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/13.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Foundation.free;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;


import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CTargetCriteriaComponet;

import kof.game.character.fight.emitter.CEmmiterController;

import kof.game.character.fight.emitter.CMissileContainer;

import kof.game.character.fight.emitter.CMissileContainer;

import kof.game.character.fight.skill.CSkillCaster;

import kof.game.character.fight.skill.CSkillCasterContext;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Emitter;
import kof.table.Emitter.EApearPosType;

public class CEmitterEffect extends CAbstractSkillEffect implements IUpdatable {

    public function CEmitterEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        super.dispose();
        if( m_skillCaster )
            m_skillCaster.removeEmitter( m_pEmitterController );
        m_appearingBound = null;
//        m_theDefaultAppearPosition = null;
//        if( m_emitterTargets )
//                m_emitterTargets.splice( 0 , m_emitterTargets.length );
//
//        m_emitterTargets = null;
    }

    //子弹发完就不理的 从列表中移除
    override public function update( delta : Number ) : void {
        if ( isNaN( m_elapsTime ) )
            return;

        super.update( delta );
        m_elapsTime = m_elapsTime + delta;

        var boFoundTarget : Boolean = _findAppearTarget();

        if ( boFoundTarget && !m_boShotted ) {
            castEmitterWithPosition();
        }

        if ( !m_boShotted && m_pEmitterData.MissileBornPos == EApearPosType.EApearCollise ) {
            _tryAchievingCollisionPos();
        }


    }

    override public function lastUpdate( delta : Number ) : void {
        super.lastUpdate( delta )

        if ( !m_boShotted && m_pEmitterData.MissileBornPos == EApearPosType.EApearCollise ) {

            if ( m_elapsTime >= m_pEmitterData.Duration * CSkillDataBase.TIME_IN_ONEFRAME ) {
                    castEmitterWithPosition();
            }
        }

//        if ( m_boShotted ) {
//            m_elapsTime = NaN;
//            m_pContainer.removeSkillEffect( this );
//        }
    }

    private function _findAppearTarget() : Boolean {
        if ( m_pEmitterData.MissileBornPos == EApearPosType.EApearCollise ) {
            if ( m_emitterTargets && m_emitterTargets.length > 0 )
                return true;
            var boFoundTarget : Boolean = findTarget();
            return boFoundTarget;
        } else if ( m_pEmitterData.MissileBornPos == EApearPosType.EApearOwener || m_pEmitterData.MissileBornPos == EApearPosType.Erandom ) {
            return _tryAchievingCollisionPos();
        } else {
            CSkillDebugLog.logErrorMsg( "Has not this Appear type for Emitter that Type = " + m_pEmitterData.MissileBornPos );
            return false
        }
    }

    override public function doStart() : void {
        super.doStart();
    }
    ;
    private function _tryAchievingCollisionPos() : Boolean {
        if ( m_theDefaultAppearPosition != null )
            return true;

        m_appearingBound = collisionComp.getCollisionBoundByHitEvent( hitEventSignal ) as CCharacterCollisionBound;
        if ( null != m_appearingBound ) {
            m_theDefaultAppearPosition = m_appearingBound.characterCollision.testAABBBox.center;
            CSkillDebugLog.logTraceMsg( "Missile Effect Find Collision Box of " + hitEventSignal );
            return true;
        }

        return false;
    }

    private function findTarget() : Boolean {
        m_emitterTargets = criteriaComp.getTargetByCollision( hitEventSignal, m_pEmitterData.TargetFilter );

        if ( m_emitterTargets == null || m_emitterTargets.length == 0 )
            return false;
        return true;
    }

    private function castEmitterWithPosition() : void {
        var pos : CVector3;
        if ( m_appearingBound || m_theDefaultAppearPosition ) {
            pos = m_theDefaultAppearPosition;
        }

        m_pEmitterController = m_skillCaster.createEmitterWithID( effectID, hitEventSignal, pos, m_emitterTargets );
        m_boShotted = true;
    }

    [inline]
    final private function get collisionComp() : CCollisionComponent {
        return owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
    }

    [inline]
    final private function get criteriaComp() : CTargetCriteriaComponet {
        return owner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
    }

    override public function initData( ... args ) : void {
        super.initData( null );
        var owner : CGameObject = args[ 0 ] as CGameObject;
        var skillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        m_skillCaster = skillCaster;
        m_elapsTime = 0.0;
        m_pEmitterData = CSkillCaster.skillDB.getEmmiterByID( effectID ) as Emitter;
    }

    private var m_skillCaster : CSkillCaster;
    private var m_elapsTime : Number;
    private var m_boShotted : Boolean;
    private var m_appearingBound : CCharacterCollisionBound;
    private var m_pEmitterData : Emitter;
    private var m_emitterTargets : Array;
    private var m_theDefaultAppearPosition : CVector3;
    private var m_pEmitterController : CEmmiterController;

}
}
