//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/3.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.statemach {

import flash.events.Event;

import kof.framework.fsm.CState;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.fight.emitter.CMissileStateValue;
import kof.game.character.fight.emitter.CMissileStatesConst;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMissileProperty;
import kof.table.Aero;

public class CTriSilenceState extends CTriBaseState {
    private var flySoundName:String;

    public function CTriSilenceState() {
        super( CTriStateConst.SILENCE );
    }

    override protected function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );

        var theMovement : CMovement = owner.getComponentByClass( CMovement, true ) as CMovement;
        theMovement.movable = true;
    }

    override protected function onEnterState( event : CStateEvent ) : void {
        super.onEnterState( event );
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        pAnimation.pushState( CMissileStateValue.FLYING_1 );
        pMissileDisplay.boStateValueChange = true;

        var pEventMediator : CEventMediator = this.eventMediator;
        if( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY , _playFlySound );
        }
    }

    private function _playFlySound( e : Event ): void{
        var missileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty , false ) as CMissileProperty;
        var pAeroData : Aero ;
        if( missileProperty ) {
            pAeroData = CSkillCaster.skillDB.getAeroByID( missileProperty.missileId);
            if ( pAeroData != null) {
                 flySoundName  = pAeroData.EffectSound;
                if ( flySoundName  != null && flySoundName!= '' ) {
                    var audioFacade : CAudioMediator = owner.getComponentByClass( CAudioMediator, false ) as CAudioMediator;
                    if ( audioFacade )
                        audioFacade.playAudioByName( flySoundName , 5, 0.0 );
                }
            }
        }
    }

    override protected function onExitState( event : CStateEvent ) : Boolean {
        super.onExitState( event );
        if ( flySoundName ) {
            if ( flySoundName!= null && flySoundName!= '' ) {
                var audioFacade : CAudioMediator = owner.getComponentByClass( CAudioMediator, false ) as CAudioMediator;
                if ( audioFacade )
                    audioFacade.stopAudioByName( flySoundName );
            }
        }

        var pEventMediator : CEventMediator = this.eventMediator;
        if( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY , _playFlySound );
        }
        return true;

    }
}

}
