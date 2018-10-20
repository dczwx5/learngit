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
import kof.game.character.fight.emitter.CMissileDisplay;
import kof.game.character.fight.emitter.CMissileStateValue;
import kof.game.character.fight.emitter.CMissileStatesConst;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;
import kof.table.Aero;
import kof.table.Aero;
import kof.table.Aero.EAeroDisableType;

public class CTriFadeState extends CTriBaseState {
    public function CTriFadeState() {
        super( CTriStateConst.FADE );
    }

    override protected function onEvaluate( event : CStateEvent ) : Boolean {
        if ( m_bDeadSign )
            return false;
        return true;
    }

    override protected function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );

        const pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.DEAD, true );
            m_bDeadSign = true;
        }

        if ( event.from == CTriStateConst.NOISY ) {
            if ( m_pAeroData.DisabelTrigger == EAeroDisableType.E_DISAPPEAR ) {
                var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster ,true  )as CSkillCaster;
                if( pSkillCaster ) {
                    pSkillCaster.cancelSkill();
                }
                pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_DEAD, null ) );
                return;
            }
        }

        _doFade();
    }

    override protected function onEnterState( event : CStateEvent ) : void {
        super.onEnterState( event );
        m_pAeroData = event.argList[ 1 ] || null;
        _makeStop();
    }

    private function _doFade() : void {

        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( m_pAeroData.DeadSFXName != null || m_pAeroData.DeadSFXName != '' ) {
            pAnimation.pushState( CMissileStateValue.EXLORSION_1 );
            pMissileDisplay.boStateValueChange = true;

            var pfightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            pfightTrigger.addEventListener( CFightTriggleEvent.MISSILE_ANIMATION_END, _animationEndCallBack )
        }

        var audioName : String = m_pAeroData.DeadSound ;
        if( audioName != null && audioName != '')
        {
            var audioFacade : CAudioMediator = owner.getComponentByClass( CAudioMediator , false) as CAudioMediator;
            if( audioFacade )
                    audioFacade.playAudioByName( audioName );
        }
    }

    private function _animationEndCallBack( e : CFightTriggleEvent ) : void {
        var pfightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        pfightTrigger.removeEventListener( CFightTriggleEvent.MISSILE_ANIMATION_END, _animationEndCallBack )

        //清楚子弹的效果
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster ,true  )as CSkillCaster;
        if( pSkillCaster ) {
            pSkillCaster.cancelSkill();
        }

        pfightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_DEAD, null ) );
    }

    final private function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    private function _makeStop() : void {
        var theMovement : CMovement = owner.getComponentByClass( CMovement, true ) as CMovement;
        theMovement.movable = false;
    }

    protected override function onExitState(event : CStateEvent)  :Boolean{
        super.onExitState( event );
        return true;
    }

    private var m_pAeroData : Aero;
    private var m_bDeadSign : Boolean;

}
}
