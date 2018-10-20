//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/3.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.statemach {

import kof.framework.fsm.CStateEvent;
import kof.game.character.animation.IAnimation;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.fight.emitter.CMissileStateValue;
import kof.game.character.fight.emitter.CMissileStatesConst;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.movement.CMovement;
import kof.table.Aero;
import kof.table.Aero.EAeroDisableType;

public class CTriNoisyState extends CTriBaseState {
    public function CTriNoisyState() {
        super( CTriStateConst.NOISY );
    }

    override protected function onEvaluate( event : CStateEvent ) : Boolean {
        super.onAfterState( event );

        var aeroInfo : Aero = event.argList[ 1 ] as Aero || null;
        if ( aeroInfo == null ) {
            CSkillDebugLog.logTraceMsg( "aero has no infos !!!! check IF its ID int the Aero Table" );
            return false;
        }
        return true;
    }

    override protected function onExitState( event : CStateEvent ) : Boolean {
        super.onExitState( event );
        _makeExit();
        m_pAeroData = null;
        return true;
    }

    override protected function onEnterState( event : CStateEvent ) : void {
        super.onEnterState( event );

        m_pAeroData = event.argList[ 1 ] || null;

        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( m_pAeroData.WorkStop == 1 ) {
            pAnimation.emitWithVelocityXYZ( 0, 0, 0 );
            pAnimation.modelDisplay.enablePhysics = false;
        }

        if ( m_pAeroData.EffectSFXName != null || m_pAeroData.EffectSFXName != '' ) {
            pAnimation.pushState( CMissileStateValue.EFFECT_1 );
            pMissileDisplay.boStateValueChange = true;
            var pfightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            pfightTrigger.addEventListener( CFightTriggleEvent.MISSILE_ANIMATION_END, _animationEndCallBack )
        }

        _onExecuteNoisy();
    }

    override protected function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );
    }

    private function _makeExit() : void {
        _removeEvent();
    }

    private function _onExecuteNoisy() : void {
        var theMovement : CMovement = owner.getComponentByClass( CMovement, true ) as CMovement;
        theMovement.movable = false;

        if( m_pAeroData ) {
            var audioName : String = m_pAeroData.EffectSound;
            if ( audioName != null && audioName != '' ) {
                var audioFacade : CAudioMediator = owner.getComponentByClass( CAudioMediator, false ) as CAudioMediator;
                if ( audioFacade )
                    audioFacade.playAudioByName( audioName );
            }
        }
    }

    private function _animationEndCallBack( e : CFightTriggleEvent ) : void {
        _removeEvent();
        _effectTimeEnd();
    }

    private function _removeEvent() : void {
        if ( pFightTrigger )
            pFightTrigger.removeEventListener( CFightTriggleEvent.MISSILE_ANIMATION_END, _animationEndCallBack );
    }

    private function _effectTimeEnd( sEventName : String = null, sFrom : String = null, sTo : String = null ) : void {
        if ( sEventName && sFrom && sTo ) {
            fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_COMPLETE, sFrom, sTo ) );
        } else {
            if ( m_pAeroData.DisabelTrigger == EAeroDisableType.E_EFFECT || m_pAeroData.DisabelTrigger == EAeroDisableType.E_DISAPPEAR ) {
                fsm.on( CTriStateConst.EVT_FADE, m_pAeroData );
            }
            else {
                fsm.on( CTriStateConst.EVT_NOISE_END );
            }
        }
    }

    override protected function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );
        _onExecuteNoisy();
    }

    private final function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    private var m_pAeroData : Aero;

}
}
