//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{

import QFLib.Math.CVector3;

public class CCharacterAnimationController extends CAnimationController
{
    public function CCharacterAnimationController( theDefaultState : CAnimationState, fnOnStateChanged : Function = null )
    {
        super( theDefaultState, fnOnStateChanged );
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    protected override function initStates() : void
    {
        addState( new CAnimationState( "Walk", "Move_1", true ) );
        addState( new CAnimationState( "Run", "Move_1", true, false, true, true ) );
        addState( new CAnimationState( "Stop", "Idle_1", false, true ) );
        //addState( new CAnimationState( "Walk", "Walk_1", true ) );
        //addState( new CAnimationState( "Run", "Run_1", true, false, true, true ) );
        //addState( new CAnimationState( "Stop", "stop_1", false, true ) );
        addState( new CAnimationState( "Jump", "Jump_1", false, true, true ) );
        addState( new CAnimationState( "JumpInAir", "Jump_Fall_1", false ) );
        addState( new CAnimationState( "JumpDown", "Jump_Land_1", false ) );
        addState( new CAnimationState( "JumpForward", "Jump_1", false, true, true ) );
        addState( new CAnimationState( "JumpForwardInAir", "Jump_Fall_1", false ) );
        addState( new CAnimationState( "JumpForwardDown", "Jump_Land_1", false ) );
    }

    protected override function initStateRelationships() : void
    {
        const fBlendTime : Number = 0.1;
        addStateRelationship( "Idle", "Jump", _any2Jump, fBlendTime );
        addStateRelationship( "Idle", "Run", _any2Run, fBlendTime );
        addStateRelationship( "Idle", "Walk", _any2Walk, fBlendTime );
        addStateRelationship( "Walk", "Jump", _any2Jump, fBlendTime );
        addStateRelationship( "Walk", "Idle", _walk2Idle, fBlendTime );
        addStateRelationship( "Walk", "Run", _any2Run, fBlendTime );
        addStateRelationship( "Run", "JumpForward", _any2Jump, fBlendTime );
        addStateRelationship( "Run", "Stop", _run2Stop, fBlendTime );
        addStateRelationship( "Run", "Walk", _any2Walk, fBlendTime );
        addStateRelationship( "Stop", "Jump", _any2Jump, fBlendTime );
        addStateRelationship( "Stop", "Idle", _stop2Idle, fBlendTime );
        addStateRelationship( "Stop", "Run", _any2Run, fBlendTime );
        addStateRelationship( "Stop", "Walk", _any2Walk, fBlendTime );
        addStateRelationship( "Jump", "JumpInAir", _any2JumpInAir, fBlendTime );
        addStateRelationship( "JumpInAir", "JumpDown", _jumpInAir2JumpDown, fBlendTime );
        addStateRelationship( "JumpDown", "Jump", _any2Jump, fBlendTime );
        addStateRelationship( "JumpDown", "Idle", _jumpDown2Idle, fBlendTime );
        addStateRelationship( "JumpDown", "Run", _any2Run, fBlendTime );
        addStateRelationship( "JumpDown", "Walk", _any2Walk, fBlendTime );
        addStateRelationship( "JumpForward", "JumpForwardInAir", _any2JumpInAir, fBlendTime );
        addStateRelationship( "JumpForwardInAir", "JumpForwardDown", _jumpInAir2JumpDown, fBlendTime );
        addStateRelationship( "JumpForwardDown", "Jump", _any2Jump, fBlendTime );
        addStateRelationship( "JumpForwardDown", "Idle", _jumpDown2Idle, fBlendTime );
        addStateRelationship( "JumpForwardDown", "Run", _any2Run, fBlendTime );
        addStateRelationship( "JumpForwardDown", "Walk", _any2Walk, fBlendTime );
    }

    public function get movement() : CVector3
    {
        return m_theMovement;
    }

    //
    protected override function _onLoadCharacterFinished() : void
    {
        super._onLoadCharacterFinished();

        if( m_theCharacterObjectRef != null )
        {
            m_theCharacterObjectRef.clearExtractAnimationOffsetBones();
            m_theCharacterObjectRef.addExtractAnimationOffsetBone( "OffsetX" );
            m_theCharacterObjectRef.addExtractAnimationOffsetBone( "OffsetY" );
            m_theCharacterObjectRef.extractAnimationOffset = true;
        }
    }

    //
    //
    protected virtual function _any2Jump() : Boolean
    {
        if ( m_theCharacterRef.animationSpeed > 0 && m_theCharacterRef.inAir && m_theCharacterRef.velocity.y != 0)
            return true;
        else return false;
    }
    protected virtual function _any2Walk() : Boolean
    {
        if( m_theMovement.x == 0 && m_theMovement.z != 0 ) return true;
        else return false;
    }
    protected virtual function _any2Run() : Boolean
    {
        if( m_theMovement.x != 0 ) return true;
        else return false;
    }
    protected virtual function _walk2Idle() : Boolean
    {
        if( m_theMovement.x == 0 && m_theMovement.z == 0 ) return true;
        return false;
    }
    protected virtual function _run2Stop() : Boolean
    {
        if( m_theMovement.x == 0 && m_theMovement.z == 0 ) return true;
        else return false;
    }
    protected virtual function _stop2Idle() : Boolean
    {
        if( m_theMovement.x == 0 && m_theMovement.z == 0 ) return true;
        {
            if( m_theCharacterRef.currentAnimationClipTimeLeft <= 0.0 ) return true;
        }
        return false;
    }
    protected virtual function _any2JumpInAir() : Boolean
    {
        if( m_fPreYVelocity == m_theCharacterRef.velocity.y || boYVelocityChanged() )
            return false;
        if( m_theCharacterRef.velocity.y != 0 && m_fPreYVelocity == 0.0)
            m_fPreYVelocity = m_theCharacterRef.velocity.y;

        if( m_theCharacterRef.animationSpeed > 0 && m_theCharacterRef.velocity.y <= 0.0 ) {
            m_fPreYVelocity = 0.0;
            return true;
        }
        return false;
    }
    protected virtual function _jumpInAir2JumpDown() : Boolean
    {
        if ( m_theCharacterRef.animationSpeed > 0 && m_theCharacterRef.inAir == false )
            return true;
        return false;
    }
    protected virtual function _jumpDown2Idle() : Boolean
    {
        if ( m_theCharacterRef.currentAnimationClipTimeLeft <= 0.0 )
            return true;
        return false;
    }

    private function boYVelocityChanged() : Boolean
    {
        var yVelocity : Number = m_theCharacterRef.velocity.y;
        var boIgnoreChange : Boolean;
        if( yVelocity == 0.0 && m_fPreYVelocity != 0.0) {
            m_fPreYVelocity = 0.0;
            boIgnoreChange = true;
        }
        return  boIgnoreChange;
    }

    //
    protected var m_theMovement : CVector3 = new CVector3();
    protected var m_fPreYVelocity : Number = 0.0;
}
}
