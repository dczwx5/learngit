//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import QFLib.Framework.CAnimationState;
import QFLib.Framework.CCharacterAnimationController;

/**
 * @see CBasicSetAnimationController
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFSetAnimationController extends CCharacterAnimationController {

    public function CKOFSetAnimationController( theDefaultState : CAnimationState, fnOnStateChanged : Function = null ) {
        super( theDefaultState, fnOnStateChanged );
    }

    override protected virtual function initStates() : void {
//        this.addState( new CAnimationState( CAnimationStateConstants.WALK, "Walk_1", true ) );
        this.addState( new CAnimationState( CAnimationStateConstants.RUN, "Move_1", true ) );
        this.addState( new CAnimationState( CAnimationStateConstants.JUMP, "Jump_1", false, true, true ) );
        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_INAIR, "Jump_Fall_1", false ) );
        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_DOWN, "Jump_Land_1", false ) );
//        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD, "Jump_2", false, true, true ) );
//        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD_INAIR, "Jump_Fall_2", true ) );
//        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD_DOWN, "Jump_Land_2", false ) );

        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD, "Jump_1", false, true, true ) );
        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD_INAIR, "Jump_Fall_1", false ) );
        this.addState( new CAnimationState( CAnimationStateConstants.JUMP_FORWARD_DOWN, "Jump_Land_1", false ) );

        this.addState( new CAnimationState( CAnimationStateConstants.AERO_DEFAULT, "Aero_1", false, true, true ) );
        this.addState( new CAnimationState( CAnimationStateConstants.AERO_FALL, "Aero_Fall_1", false ) );
        this.addState( new CAnimationState( CAnimationStateConstants.AERO_LAND, "Aero_Land_1", false ) );
    }

    override protected virtual function initStateRelationships() : void {
        this.addStateRelationship( CAnimationStateConstants.IDLE, CAnimationStateConstants.JUMP, _any2Jump, 0.0 );
        this.addStateRelationship( CAnimationStateConstants.WALK, CAnimationStateConstants.JUMP, _any2Jump, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.RUN, CAnimationStateConstants.JUMP, _any2Jump, 0.1 );

        this.addStateRelationship( CAnimationStateConstants.JUMP, CAnimationStateConstants.JUMP_INAIR, _any2JumpInAir, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_INAIR, CAnimationStateConstants.JUMP_DOWN, _jumpInAir2JumpDown, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_DOWN, CAnimationStateConstants.JUMP, _any2Jump, 0.0 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_DOWN, CAnimationStateConstants.IDLE, _jumpDown2Idle, 0.0 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_DOWN, CAnimationStateConstants.RUN, _any2Run, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_DOWN, CAnimationStateConstants.WALK, _any2Walk, 0.1 );

        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD, CAnimationStateConstants.JUMP_FORWARD_INAIR, _any2JumpInAir, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD_INAIR, CAnimationStateConstants.JUMP_FORWARD_DOWN, _jumpInAir2JumpDown, 0.1 );

        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD_DOWN, CAnimationStateConstants.JUMP, _any2Jump, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD_DOWN, CAnimationStateConstants.IDLE, _jumpDown2Idle, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD_DOWN, CAnimationStateConstants.RUN, _any2Run, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.JUMP_FORWARD_DOWN, CAnimationStateConstants.WALK, _any2Walk, 0.1 );

        this.addStateRelationship( CAnimationStateConstants.AERO_DEFAULT, CAnimationStateConstants.AERO_FALL, _any2JumpInAir, 0.1 );
        this.addStateRelationship( CAnimationStateConstants.AERO_FALL, CAnimationStateConstants.AERO_LAND, _jumpInAir2JumpDown, 0.1 );
    }

}
}

// vim:ft=as3 tw=200
