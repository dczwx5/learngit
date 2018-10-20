//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import kof.framework.fsm.CStateEvent;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.fight.skill.CSkillMotionAssembly;

/**
 * 角色躺地状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterLyingState extends CCharacterState implements IUpdatable {

    private var m_fLyingTime : Number;
    private var m_motionFacade : CSkillMotionAssembly;

    public function CCharacterLyingState() {
        super( CCharacterActionStateConstants.LYING );
    }

    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        if ( event.from == CCharacterActionStateConstants.HURT ||
                event.from == CCharacterActionStateConstants.KNOCK_UP ) {
            return true;
        }
        return false;
    }

    override protected virtual function onEnterState( event : CStateEvent ) : void {
        super.onEnterState( event );

        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        if( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.IN_CONTROL , false );
            pStateBoard.setValue( CCharacterStateBoard.LYING, true );
        }
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        this.setMovable( false ); // 可以不可以主动移动
        this.setDirectionPermit( false ); // 不可以转身镜像

        // 获取状态转入参数中的状态Duration, 如果没有默认为0.5
        this.m_fLyingTime = Number( event.argList[ 1 ] ) || this.m_fLyingTime;
        this.m_motionFacade = this.m_motionFacade || event.argList[ 2 ] as CSkillMotionAssembly;

        CONFIG::debug {
            Foundation.Log.logTraceMsg( "Lying delta time: " + m_fLyingTime.toString() );
        }

        if ( isNaN( this.m_fLyingTime ) ) {
            this._onLyingEnd();
            return;
        }

        var v_pAnimation : IAnimation = this.animation;
        if ( v_pAnimation ) {
            v_pAnimation.playAnimation( CAnimationStateConstants.LYING, true );
        }
    }

    override protected virtual function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );
        this.reset();
//        if ( event.to != CCharacterActionStateConstants.HURT ) {
//            var pStateBoard : CCharacterStateBoard = this.stateBoard;
//            if( pStateBoard )
//                    pStateBoard.resetValue( CCharacterStateBoard.LYING );
//        }
    }

    final private function _onLyingEnd() : void {
        this.reset();

        fsm.on( CCharacterActionStateConstants.EVENT_GETUP_BEGAN );
    }

    public function reset() : void {
        if ( m_motionFacade )
            m_motionFacade.dispose();
        m_motionFacade = null;

        m_fLyingTime = NaN;

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.LYING );
            pStateBoard.resetValue( CCharacterStateBoard.IN_CONTROL );
        }
    }

    override protected function onExitState( event : CStateEvent ) : Boolean{
        return true;
    }

    public function update( delta : Number ) : void {
        if ( m_motionFacade ) {
            if ( m_motionFacade.isRunning )
                m_motionFacade.update( delta );
            else
                m_motionFacade = null;
        }

        if ( !isNaN( this.m_fLyingTime ) ) {
            this.m_fLyingTime -= delta;
            if ( this.m_fLyingTime <= 0 ) {
                this.m_fLyingTime = NaN;

                this._onLyingEnd();
            }
        }
    }

}
}

// vim:ft=as3 tw=0 ts=4 sw=4 et
