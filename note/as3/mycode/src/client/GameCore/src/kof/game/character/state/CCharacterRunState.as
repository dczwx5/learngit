//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import flash.geom.Point;

import kof.framework.fsm.CStateEvent;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.CAnimationStateValue;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;

/**
 * 角色Run状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterRunState extends CCharacterState {

    /** @private */
    private var m_bTurning : Boolean;

    /** Creates a new CCharacterRunState */
    public function CCharacterRunState() {
        super( CCharacterActionStateConstants.RUN );
    }

    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        // 空中不可用
        var pStageBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStageBoard ) {
            if ( pStageBoard.getValue( CCharacterStateBoard.ON_GROUND ) )
                return true;
        }
        return false;
    }

    /** @inheritDoc */
    override protected virtual function onStateChange( event : CStateEvent ) : void {
        this._doRun( event );
    }

    override protected final function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );
        if ( isRunning ) {
            this._doRun( event );
        }
    }

    final private function _doRun( event : CStateEvent ) : void {
        // 无论怎么滴，进入Run状态就是可以跑动

        var pDisplay : IDisplay = this.skin;
        var pAnimation : IAnimation = this.animation;
        var pInput : CCharacterInput = this.input;
        var bMovable : Boolean = true;
        var pStateBoard : CCharacterStateBoard = this.stateBoard;

        if ( event.from == CCharacterActionStateConstants.IDLE || event.from == CCharacterActionStateConstants.RUN ) {
            var iDirX : int = 0;
            if ( pStateBoard ) {
                var pDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                iDirX = pDir ? pDir.x : 0;
            }

            if ( pInput && pDisplay && pInput.isWheelDirty && iDirX != 0 ) {
                if ( pDisplay.direction != iDirX ) {
                    // Need turn transition.
                    if ( pAnimation ) {
                        pAnimation.pushState( CAnimationStateValue.TURN );
                        pAnimation.playAnimation( CAnimationStateConstants.TURN );
                    }

                    pInput.clearWheelDirty();

                    // 监听动作结束
                    this.subscribeAnimationEnd( onCurrentAnimationTimeEnd );

                    // 转身不可以移动哦
                    bMovable = false;
                    m_bTurning = true;

                    if ( pStateBoard ) {
                        pStateBoard.clearDirty( CCharacterStateBoard.MOVING );
                    }
                }
            }
        }

        this.setMovable( bMovable );
        if ( bMovable ) {
            makeRun();
        }

    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        // 如果转入攻击状态，转身中不可强切
        var bWaiting : Boolean = event.to == CCharacterActionStateConstants.ATTACK;

        if ( bWaiting && this.m_bTurning ) {
            // 转身动作还未结束，等待转身动作结束完成过渡
            this.subscribeAnimationEnd( onCurrentAnimationTimeEnd, event.argList, event.from, event.to );
            return false;
        } else if ( !bWaiting ) {
            // 强制切换
            // 结束Animation的结束监听
            this.clearSubscribeAnimationEnds();
            this.m_bTurning = false;
        }

        makeExit();
        return true;
    }

    final private function onCurrentAnimationTimeEnd( listArgs : Array = null, sFrom : String = null, sTo : String = null ) : void {
        if ( this.isRunning ) {
            this.setMovable( true );
            this.m_bTurning = false;

            var pInput : CCharacterInput = this.input;
            if ( pInput ) {
                pInput.makeWheelDirty();
            }

            if ( listArgs && sFrom && sTo ) {
                makeExit();
                fsm.dispatchEvent( new CStateEvent( CStateEvent.TRANSITION_COMPLETE, sFrom, sTo, listArgs ) );
            } else {
                makeRun();
            }
        }
    }

    final protected function makeRun() : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.MOVING, false );
            pStateBoard.setValue( CCharacterStateBoard.MOVING, true );
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION_PERMIT, true );
        }

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.pushState( CAnimationStateValue.RUN );
        }
    }

    final protected function makeExit() : void {
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.MOVING, false );
        }

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.popState( CAnimationStateValue.RUN );
        }

    }
}
}
