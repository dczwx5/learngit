//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/5.
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

public class CMissileSkillEndHit extends CMissileHit {
    public function CMissileSkillEndHit( owner : CGameObject ) {
        super( owner );
        effectType = EAeroDisableType.E_SKILLEND;
    }

    override public function dispose() : void {
        missileObject = null;
        super.dispose();
    }

    override public function initHitBehavior( ... arg ) : void {
        if ( null == arg || arg[ 0 ] == null )
            return;
        missileObject = owner;
        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty , true ) as CMissileProperty;
        m_pMissileInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

        var trigger : CCharacterFightTriggle = emitterComp.owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, onEffectExecute );

        var pMovement : CMovement = emitterComp.owner.getComponentByClass( CMovement , true ) as CMovement;
        pMovement.collisionEnabled = false;
    }

    override public function update( delta : Number ) : void {

    }

    override protected function isEvaluate() : Boolean {
        return true;
    }

    private function onEffectExecute( e : CFightTriggleEvent ) : void {
        //remove the missile and show the explosion fx
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
