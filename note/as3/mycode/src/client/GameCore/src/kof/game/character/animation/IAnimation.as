//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import QFLib.Collision.CCollisionBound;
import QFLib.Collision.common.ICollision;
import QFLib.Framework.CCharacter;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.game.core.IGameComponent;

/**
 * 动画组件接口
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IAnimation extends IGameComponent, IUpdatable {

    //--------------------------------------------------------------------------
    // Animation native state value handles.
    //
    /** Returns the current state mark value. */
    function get stateValue() : int;

    /** Determines whether the specified <code>stateValue</code> is being activated. */
    function isStateActive( stateValue : int ) : Boolean;

    function pushState( stateValue : int ) : int;

    function popState( stateValue : int ) : int;

    /** Determines whether the current animation is looping. */
    function get currentAnimationLoop() : Boolean;

    function set currentAnimationLoop( value : Boolean ) : void;

    /** Returns the current animation state. */
    function get currentAnimationState() : String;

    function setCurrentAnimationTag( value : String , subSequenceTab : String ) : void ;
    function get currentAnimationTag() : String;
    function get currentAnimationTagParam() : String;

    /** return the animation time*/
    function getAnimationTime( animtionState : String ) : Number

    //--------------------------------------------------------------------------
    // Animation handle
    //
    function get modelDisplay() : CCharacter;
    function showQuaq(quad : DisplayObject , show: Boolean) : void;
    function setEnableCollision( value : Boolean ) : void;
    function get direction() : int;
    /** Play the specified animation state. */
    function playAnimation( animationState : String, bForceReplay : Boolean = false, bLoop : Boolean = false, iTrackIdx : int = 0 ) : void;

    function continuePlayAnimation( animationState : String ):void;

    function get lastFrameMode() : Boolean;
    function set lastFrameMode( value : Boolean ) : void;
    function set lastFrameModeTimeLeft( value : Number) : void;

    function get boSkillPlaying( ) : Boolean;
    function set boSkillPlaying( value : Boolean ) : void;


    function get inTurnning() : Boolean;
    function set inTurnning( value : Boolean ) : void;

    function shake( fIntensity : Number, fTimeDuration : Number ) : void;

    function shakeXY( fIntensityX : Number, fIntensityY : Number, fTimeDuration
            : Number , fPeriodTime : Number = 0.02) : void;

    /** Pause the current animation state. */
    function pauseAnimation() : void;

    /** Resume the current animation state. */
    function resumeAnimation() : void;

    /**Speed up the current animation state .*/
    function speedUpAnimation( speed : Number ) : void;

    /** Add a callback function which call when the animation tick. */
    function addAnimationTickCallback( pfnCallback : Function ) : void;

    /** Removes the specific callback function which call when the animation tick. */
    function removeAnimationTickCallback( pfnCallback : Function ) : void;

    /** Removes all callbacks. */
    function clearAnimationTickCallbacks() : void;

    //--------------------------------------------------------------------------
    // Animation Frozen functions.
    //

    /** Frozen current animtaion by the specified duration time. */
    function frozenAnimation( fTimeDuration : Number, pfnCallback : Function = null, ... args ) : void;

    function popFrozenAnimationCallback( pfnCallback : Function ) : void;

    function clearFrozenAnimationCallbacks() : void;

    /** Pause the current frame state. */
    function pauseFrame() : void;

    /** Resume frame state */
    function resumeFrame() : void;

    function frozenFrame( fTimeDuration : Number, pfnCallback : Function = null, ... args ) : void;

    function setFrozenDirty( fTimeDuration : Number , pfnCallback : Function = null , ... args ) : void;

    function popFrozenFrameCallback( pfnCallback : Function ) : void;

    function clearFrozenFrameCallbacks() : void;

    function tickFrozenTime( delta : Number ) : void;
    //--------------------------------------------------------------------------
    // Animation Offsets.
    //

    function get animationOffset() : CVector2;

    function get animationOffsetEnabled() : Boolean;

    function set animationOffsetEnabled( value : Boolean ) : void;

    function get physicsEnabled() : Boolean;

    function set physicsEnabled( value : Boolean ) : void;

    function get noPhysicsAndAnimationOffset() : Boolean;

    function set noPhysicsAndAnimationOffset( value : Boolean ) : void;

    function get bAnimationBanFrozen() : Boolean;

    function set bAnimationBanFrozen( value : Boolean ) : void

    //--------------------------------------------------------------------------
    // Animation for Skill dynamically ld/st.
    //

    function addSkillAnimationState( sStateName : String, sAnimationName : String ) : void;

    function removeSkillAnimationState( sStateName : String ) : void;

    function emit( fHeight : Number ) : void;

    function emitWithExtraVelocity( fHeight : Number, velocity : CVector3 = null ) : void;

    function emitWithExtraVelocityXYZ( fHeight : Number, x : Number, y : Number, z : Number, clear : Boolean = false ) : void;

    function emitWithVelocityXYZ( veloX : Number, veloY : Number, veloZ : Number ) : void;

    function setCharacterGravityAcc( acc : Number ) : void ;
    function setDefaultCharacterGravityAcc( acc : Number ) : void;

    function resetCharacterGravityAcc() : void;

//    function get physicsEnabled() : Boolean;
//
//    function set physicsEnabled( physicsEnabled : Boolean ) : void;
    function get animationSpeed() : Number;

    function get isFrameFrozen() : Boolean;

    function get stepHeight() : Number;

    function set stepHeight( value : Number ) : void;

    function stateWithAnimation( statName : String , AnimationName : String ) : void;


    /**
    function createCharacterCollision( type : int , box : CAABBox3 , ownerData : Object ) : CCollisionBound;
    function destroyCharacterCollision( bound : ICollision ) : void;*/

}
}
