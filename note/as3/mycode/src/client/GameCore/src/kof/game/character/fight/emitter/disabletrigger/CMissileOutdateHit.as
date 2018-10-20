//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/22.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.disabletrigger {

import kof.game.character.fight.emitter.*;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.emitter.statemach.CTriStateConst;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMissileProperty;
import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Aero.EAeroDisableType;

/**
 * hitting effects per the timer
 */
public class CMissileOutdateHit extends CMissileHit {
    public function CMissileOutdateHit( owner : CGameObject ) {
        super( owner );
        effectType = EAeroDisableType.E_TIMEOUT;
    }

    override public function initHitBehavior( ... arg ) : void {
        if ( null == arg || arg[ 0 ] == null )
            return;
        missileObject = owner;
        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        m_pMissileInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

    }

    override public function dispose() : void {
        var trigger : CCharacterFightTriggle = missileObject.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.removeEventListener( CFightTriggleEvent.MISSILE_EXPLOSION_END, onRecycleMissileTimer );
        missileObject = null;
    }

    override public function update( delta : Number ) : void {
        if ( m_boEnd )
            return;

        m_elapseTime = m_elapseTime + delta;

        if ( m_elapseTime >= m_pMissileInfo.ExistTime ) {
            m_boEnd = true;
            executeEffect();
        }
    }

    override protected function executeEffect() : void {
        triStateMachine.actionFSM.on( CTriStateConst.EVT_FADE, m_pMissileInfo );
    }

    private function _playDeadAnimation() : Boolean {
        var pMovement : CMovement = missileObject.getComponentByClass( CMovement, true ) as CMovement;
        pMovement.movable = false;

        var md : IAnimation = missileObject.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( !md.isStateActive( CMissileStateValue.EXLORSION_1 ) ) {
            var trigger : CCharacterFightTriggle = missileObject.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            trigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_EXPLOSION_BEGIN, null ) );

            md.pushState( CMissileStateValue.EXLORSION_1 );
            md.playAnimation( m_pMissileInfo.DeadSFXName.toUpperCase(), true );
            return true;
        }

        return false;
    }

    private function onRecycleMissileTimer( event : CFightTriggleEvent = null ) : void {
        var trigger : CCharacterFightTriggle = missileObject.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.removeEventListener( CFightTriggleEvent.MISSILE_EXPLOSION_END, onRecycleMissileTimer );
        trigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_DEAD, null ) );
    }

    private var missileObject : CGameObject;
    private var m_pMissileInfo : Aero;
    private var m_elapseTime : Number = 0.0;
    private var m_boEnd : Boolean;
}
}
