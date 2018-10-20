//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/5.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.effecttrigger {

import kof.game.character.fight.emitter.CEmitterComponent;
import kof.game.character.fight.emitter.CMissile;
import kof.game.character.fight.emitter.statemach.CTriStateConst;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.CSkillEffectContainer;
import kof.game.character.movement.CMovement;
import kof.game.core.CGameObject;

public class CMissileColliseEffect extends CMissileBaseEffect {
    public function CMissileColliseEffect( owner : CGameObject ) {
        super(owner);
    }

    override public function dispose() : void
    {
        super.dispose();
        _removeHitEvent();
    }

    override public function update( delta : Number ) : void
    {
        super.update( delta );
    }
    override public function initEffect( missile : CGameObject ) : void
    {
        super.initEffect( missile );
        var pMissileFightTrigger : CCharacterFightTriggle;
        pMissileFightTrigger = owner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
        pMissileFightTrigger.addEventListener( CFightTriggleEvent.HIT_TARGET , _executeEffect );
    }

    private function _executeEffect( e :CFightTriggleEvent ) : void
    {
        if( !boFade )
            triStateMachine.actionFSM.on( CTriStateConst.EVT_NOISE_BEGINE , aeroInfo );
    }

    override protected function setFade() : void
    {
        super.setFade();
        _removeHitEvent();
    }

    private function _removeHitEvent() : void
    {
        var trigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if( trigger )
            trigger.removeEventListener( CFightTriggleEvent.HIT_TARGET, _executeEffect );
    }

    private function onExplosionEnd( e : CFightTriggleEvent ) : void
    {
        var trigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        trigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_COLLIDE_EXPLOSION , null ));
    }
}
}
