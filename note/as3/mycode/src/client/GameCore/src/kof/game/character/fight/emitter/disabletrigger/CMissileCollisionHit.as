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
 * hitting effects when collision bound tough target
 */
public class CMissileCollisionHit extends CMissileHit {

    public function CMissileCollisionHit( owner : CGameObject ) {
        super(owner);
        effectType = EAeroDisableType.E_MISSTARGET;
    }

    override public function dispose() : void {

        var trigger : CCharacterFightTriggle = missileObject.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.addEventListener( CFightTriggleEvent.MISSILE_COLLIDE_EXPLOSION, onRecycleMissile );

        missileObject = null;
        super.dispose();
    }

    override public function initHitBehavior( ... arg ) : void {
        if ( null == arg || arg[ 0 ] == null )
            return;
        missileObject = owner ;
        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty , true ) as CMissileProperty;
        m_pMissileInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

        var trigger : CCharacterFightTriggle = missileObject.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.addEventListener( CFightTriggleEvent.MISSILE_COLLIDE_EXPLOSION, onRecycleMissile );

        var pMovement : CMovement = missileObject.getComponentByClass( CMovement , true ) as CMovement;
        pMovement.collisionEnabled = false;
    }

    override public function update( delta : Number ) : void {}

    override protected function isEvaluate() : Boolean {
        return true;
    }

    private function onRecycleMissile( e : CFightTriggleEvent ) : void
    {
        triStateMachine.actionFSM.on( CTriStateConst.EVT_FADE , m_pMissileInfo );
    }

    final private function get emitterComp() : CEmitterComponent
    {
        return missileObject.getComponentByClass( CEmitterComponent , true ) as CEmitterComponent;
    }

    private var missileObject : CGameObject;
    private var m_pMissileInfo : Aero;
}
}
