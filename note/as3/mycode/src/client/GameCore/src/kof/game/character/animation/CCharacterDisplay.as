//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import QFLib.Foundation.CURLJson;
import QFLib.Framework.CAnimationState;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Math.CAABBox2;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.util.CAssertUtils;
import kof.game.character.fight.skill.ISkillInfoRes;


/**
 * 角色显示组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterDisplay extends CBaseAnimationDisplay {

    static private function getDefaultAnimationStates() : Array {
        return [
            // new CAnimationState(BORN, "Born_1", false),
            new CAnimationState( CAnimationStateConstants.IDLE, "Idle_1", true ),
            new CAnimationState( CAnimationStateConstants.CLICK_BEGIN, "Dianji_1", false, false ),
            new CAnimationState( CAnimationStateConstants.CLICK_LAST, "Dianji_2", true, false ),
            new CAnimationState( CAnimationStateConstants.CLICK_END, "Turn_2", false, false ),
//            new CAnimationState( CAnimationStateConstants.BACK_TO_IDLE, "Back_to_Idle", false ),
            new CAnimationState( CAnimationStateConstants.RUN, "Move_1", true ),
            new CAnimationState( CAnimationStateConstants.TURN, "Turn_1", false ),
            new CAnimationState( CAnimationStateConstants.E_ROLL, "E_Roll_1", false ),
            new CAnimationState( CAnimationStateConstants.GUARD_BY_STAND, "Guard_1", false ),
            new CAnimationState( CAnimationStateConstants.GUARD_BY_UPDOWN, "Guard_2", false ),
            new CAnimationState( CAnimationStateConstants.HURT_MILD, "Hurt_1", false ),
            new CAnimationState( CAnimationStateConstants.HURT_SEVERE, "Hurt_2", false ),
            new CAnimationState( CAnimationStateConstants.HURT_LYING, "Lying_Hurt_1", false ),
            new CAnimationState( CAnimationStateConstants.LYING, "Lying_1", false ),
            new CAnimationState( CAnimationStateConstants.GETUP, "Getup_1", false ),
            new CAnimationState( CAnimationStateConstants.DEAD, "Dead_1", false ),
            new CAnimationState( CAnimationStateConstants.WIN, "Win_1", false ),
            new CAnimationState( CAnimationStateConstants.FAINT, "Faint_1", false )
        ];
    }

    static private function getCatchAnimationStates() : Array {
        return [
            new CAnimationState( CAnimationStateConstants.BE_CATCH_1, "BeCatch_1", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_2, "BeCatch_2", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_3, "BeCatch_3", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_4, "BeCatch_4", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_5, "BeCatch_5", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_6, "BeCatch_6", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_7, "BeCatch_7", false ),
            new CAnimationState( CAnimationStateConstants.BE_CATCH_8, "BeCatch_8", false ),
        ];
    }

    /** Create a new CCharacterDisplay. */
    public function CCharacterDisplay( theFramework : CFramework ) {
        super();

        var listAnimations : Array = getDefaultAnimationStates();
        listAnimations = listAnimations.concat( getCatchAnimationStates() );

        const pAnimationController : CKOFSetAnimationController = new CKOFSetAnimationController( listAnimations[ 0 ] );

        for each ( var state : CAnimationState in listAnimations ) {
            if ( state == listAnimations[ 0 ] )
                continue;

            if ( !pAnimationController.findState( state.stateName ) )
                pAnimationController.addState( state );
        }

        // Priority hold.
        // pAnimationController.addStateRelationship(BORN, IDLE, _born2Idle);
        pAnimationController.addStateRelationship(CAnimationStateConstants.CLICK_BEGIN, CAnimationStateConstants.CLICK_LAST,null);
        pAnimationController.addStateRelationship( CAnimationStateConstants.CLICK_END, CAnimationStateConstants.IDLE, null );

        pAnimationController.addStateRelationship( CAnimationStateConstants.IDLE, CAnimationStateConstants.TURN, idle2Turn );
        pAnimationController.addStateRelationship( CAnimationStateConstants.TURN, CAnimationStateConstants.IDLE, turn2Idle );
        pAnimationController.addStateRelationship( CAnimationStateConstants.TURN, CAnimationStateConstants.RUN, turn2Run );
//        pAnimationController.addStateRelationship( CAnimationStateConstants.IDLE, CAnimationStateConstants.RUN, idle2Run, 0.1 );
//        pAnimationController.addStateRelationship( CAnimationStateConstants.RUN, CAnimationStateConstants.IDLE, run2Idle, 0.1 );
        pAnimationController.addStateRelationship( CAnimationStateConstants.IDLE, CAnimationStateConstants.RUN, idle2Run );
        pAnimationController.addStateRelationship( CAnimationStateConstants.RUN, CAnimationStateConstants.IDLE, run2Idle );

        // To dead.
        pAnimationController.addStateRelationship( CAnimationStateConstants.GUARD_BY_STAND, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.GUARD_BY_UPDOWN, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.E_ROLL, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_MILD, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_SEVERE, CAnimationStateConstants.DEAD, timeLeft2Dead );

        pAnimationController.addStateRelationship( CAnimationStateConstants.LYING, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_LYING, CAnimationStateConstants.DEAD, timeLeft2Dead );
        pAnimationController.addStateRelationship( CAnimationStateConstants.GETUP, CAnimationStateConstants.DEAD, timeLeft2Dead );

        // To Idle.
        pAnimationController.addStateRelationship( CAnimationStateConstants.GUARD_BY_STAND, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );
        pAnimationController.addStateRelationship( CAnimationStateConstants.GUARD_BY_UPDOWN, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );
        pAnimationController.addStateRelationship( CAnimationStateConstants.E_ROLL, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_MILD, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_SEVERE, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );
//        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_LYING, CAnimationStateConstants.IDLE, timeLeft2Idle );

//        pAnimationController.addStateRelationship( CAnimationStateConstants.LYING, CAnimationStateConstants.GETUP, timeLeft2Idle );
        pAnimationController.addStateRelationship( CAnimationStateConstants.HURT_LYING, CAnimationStateConstants.LYING, timeLeft2Idle );
        pAnimationController.addStateRelationship( CAnimationStateConstants.GETUP, CAnimationStateConstants.IDLE, timeLeft2Idle, 0.1 );

        {
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_1, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_2, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_3, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_4, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_5, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_6, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_7, CAnimationStateConstants.IDLE, timeLeft2Idle );
            pAnimationController.addStateRelationship( CAnimationStateConstants.BE_CATCH_8, CAnimationStateConstants.IDLE, timeLeft2Idle );
        }

        var pCharacter : CCharacter = new CCharacter( theFramework, pAnimationController );
        pCharacter.castShadow = true;

        this.setDisplay( pCharacter );
    }

    override public function getCharacterBaseURI() : String {
        return "assets/character/";
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    override protected function onResReady() : void {
        super.onResReady();

        if ( modelDisplay ) {
            var pAnimationState : CAnimationState = this.animationController.findState( CAnimationStateConstants.IDLE ) as CAnimationState;
            CAssertUtils.assertNotNull( pAnimationState, "No IDLE animation state binding when ready." );
            var bound : CAABBox2 = modelDisplay.getBound( pAnimationState.animationName, pAnimationState.animationExtractOffset );
            this.defaultBound = bound.clone();
        }

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.DISPLAY_READY, owner ) );
        }
    }

    override protected function onCollisionReady() : void{
        super.onResReady();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.COLLISION_READY, owner ) );
        }
    }

}
}

// vim:ft=as3 tw=200
