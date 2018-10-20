//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/24.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Interface.IUpdatable;

import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.core.CGameObject;
import kof.table.ActionSeq.EType;

/**
 * the controller of an Animation for skill
 */
public class CSkillAnimationController implements IUpdatable {

    public function CSkillAnimationController() {
        m_audio = new CSkillAudioSupportDemo();
    }

    public function update( delta : Number ) : void {
        if ( m_pControllerEntity is IUpdatable ) {

            (m_pControllerEntity as IUpdatable).update( delta );
        }
    }
    //remove the mode entity and always return to IDLE state
    public function reset() : void {
        if ( m_pControllerEntity )
            m_pControllerEntity.dispose();
        m_pControllerEntity = null;

        pAnimation.resumeAnimation();
    }

    public function dispose() : void {
        if ( m_pControllerEntity )
            m_pControllerEntity.dispose();
        m_pControllerEntity = null;
        m_pAnimation = null;
    }

    public function set owner( value : CGameObject ) : void {
        m_audio.owner = value;
        m_owner = value;
    }

    final public function set pAnimation( value : IAnimation ) : void {
        m_pAnimation = value;
    }

    final public function get pAnimation() : IAnimation {
        return m_pAnimation;
    }

    public function castControllerEntity( animationName : String, mode : int, durationTime : Number = 0 ) : void {
        //resume the animation first
        pAnimation.resumeAnimation();

        //destruct the old mode Entity
        if ( m_pControllerEntity ) {
            m_pControllerEntity.dispose();
        }
        //create new mode entity
        var pskillCaster : CSkillCaster = m_owner.getComponentByClass( CSkillCaster , true )as CSkillCaster;
        var skillSpeed : Number = pskillCaster.skillSpeed;

        m_pControllerEntity = getModeEntityByType( mode );
        m_pControllerEntity.playAnimation( animationName, durationTime ,skillSpeed );
        m_audio.playMotion( animationName );
    }

    private function getModeEntityByType( type : int ) : IAnimationMode {
        var aMode : IAnimationMode;
        switch ( type ) {
            case EType.LAST_FRAME:
                aMode = new CFrozenMode();
                break;
            case EType.LOOP:
                aMode = new CLoopMode();
                break;
            case EType.STRETCH:
                aMode = new CSpeedMode();
                break;
            default:
                aMode = new CSpeedMode();
        }
        if ( aMode )
            aMode.pAnimation = pAnimation;

        return aMode;
    }

    private var m_pAnimation : IAnimation;
    private var m_pControllerEntity : IAnimationMode;
    private var m_audio : CSkillAudioSupportDemo;
    private var m_owner : CGameObject;
}
}

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.skill.CSkillDebugLog;

interface IAnimationMode extends IDisposable {
    function playAnimation( animationName : String, durationTime : Number = 0 , skillSpeed : Number = 1.0) : void

    function set playMode( value : int ) : void;

    function set pAnimation( value : IAnimation ) : void;
}
/**
 * Loop Mode
 */
class CLoopMode implements IAnimationMode,IUpdatable {
    public function playAnimation( animationName : String, durationTime : Number = 0 , skillSpeed : Number = 1.0) : void {
        m_totalTime = durationTime;
        m_animationName = animationName.toUpperCase();
        m_pAnimation.speedUpAnimation( skillSpeed );
        m_pAnimation.playAnimation( m_animationName, true, true );
        CSkillDebugLog.logTraceMsg( "循环模式播放动作：" + animationName );
    }

    public function set pAnimation( value : IAnimation ) : void {
        m_pAnimation = value;
    }

    public function dispose() : void {
        m_pAnimation = null;
    }

    public function set playMode( value : int ) : void {
        m_playMode = value;
    }

    final private function get animationPlayTime() : Number {
        return m_pAnimation.getAnimationTime( m_animationName );
    }

    public function update( delta : Number ) : void {
        if ( m_totalTime == 0 )
            return;

        //end if elapseTime > Duration Total Time
        if ( m_elapseTime >= m_totalTime ) {
            //dispatch end of play
            return;
        }

        m_elapseTime = m_elapseTime + delta;
    }

    private var m_playMode : int;
    private var m_pAnimation : IAnimation;
    private var m_totalTime : Number;
    private var m_elapseTime : Number = 0.0;
    private var m_animationName : String;
}
/**
 * Frozen at Last frame
 */
class CFrozenMode implements IAnimationMode, IUpdatable {
    public function playAnimation( animtionName : String, durantionTime : Number = 0 ,skillSpeed : Number = 1.0 ) : void {
        m_totalTime = durantionTime;
        m_animationName = animtionName.toUpperCase();
        m_pAnimation.speedUpAnimation( skillSpeed );
        m_pAnimation.playAnimation( m_animationName, true );
        m_pAnimation.lastFrameModeTimeLeft = durantionTime;
        m_pAnimation.lastFrameMode = true;
        CSkillDebugLog.logTraceMsg( "停在最后一针模式播放动作：" + m_animationName );
    }

    public function set pAnimation( value : IAnimation ) : void {
        m_pAnimation = value;
    }

    final private function get animationPlayTime() : Number {
        return m_pAnimation.getAnimationTime( m_animationName );
    }

    public function dispose() : void {
        if (m_pAnimation) {
            m_pAnimation.lastFrameMode = false;
        }
        m_pAnimation = null;
        m_animationName = null;
    }

    public function set playMode( value : int ) : void {
        m_playMode = value;
    }

    public function update( delta : Number ) : void {
        m_elapseTime = m_elapseTime + delta;
        if ( m_elapseTime >= m_totalTime ) {
            m_pAnimation.lastFrameMode = false;
        }
    }

    private var m_playMode : int;
    private var m_pAnimation : IAnimation;
    private var m_totalTime : Number;
    private var m_elapseTime : Number = 0.0;
    private var m_animationName : String;
}

/**
 * speed up mode
 */
class CSpeedMode implements IAnimationMode {
    public function playAnimation( animtionName : String, durantionTime : Number = 0 , skillSpeed : Number = 1.0 ) : void {
        m_totalTime = durantionTime;
        m_animationName = animtionName.toUpperCase();
        var fSpeed : Number = animationPlayTime / m_totalTime;
        if ( !isNaN(fSpeed) && fSpeed > 0.0 )
            m_pAnimation.speedUpAnimation( fSpeed * skillSpeed );
        m_pAnimation.playAnimation( m_animationName, true );
        CSkillDebugLog.logTraceMsg( "拉伸模式播放动作：" + m_animationName );
    }

    public function set pAnimation( value : IAnimation ) : void {
        m_pAnimation = value;
    }

    final private function get animationPlayTime() : Number {
        return m_pAnimation.getAnimationTime( m_animationName );
    }

    public function set playMode( value : int ) : void {

    }

    public function dispose() : void {
        m_pAnimation = null;
    }

    private var m_pAnimation : IAnimation;
    private var m_totalTime : Number;
    private var m_animationName : String;


}



