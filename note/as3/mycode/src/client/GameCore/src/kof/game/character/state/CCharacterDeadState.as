//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.CMonsterProperty;

/**
 * 死亡状态
 * 1. 如果是地面站立进入死亡状态，该状态与受击状态一致，不同在于动作更换为死亡动作
 * 2. 如果是空中进入死亡状态，不执行任何动作逻辑
 *
 * @author Jeremy (jeremy@qifan.com)
 */
public class CCharacterDeadState extends CCharacterState {

    public function CCharacterDeadState() {
        super( CCharacterActionStateConstants.DEAD );
    }

    final protected function get isOnGround() : Boolean {
        return stateBoard.getValue( CCharacterStateBoard.ON_GROUND );
    }

    override protected virtual function onEvaluate( event : CStateEvent ) : Boolean {
        var ret : Boolean = super.onEvaluate( event );
        if ( ret ) {
            // 准备进入死亡状态，进行死亡标识
            const pStateBoard : CCharacterStateBoard = this.stateBoard;
            if ( pStateBoard ) {
                pStateBoard.setValue( CCharacterStateBoard.DEAD_SIGNED, true );
            }

            fsm.addEventListener( CStateEvent.TRANSITION_CANCELLED, _onTransitionDone, false, CEventPriority.DEFAULT, true );
        }
        return ret;
    }

    /** @private */
    private function _onTransitionDone( event : CStateEvent = null ) : void {
        if ( event ) {
            fsm.removeEventListener( event.type, _onTransitionDone );
        }

        const pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.DEAD_SIGNED );
        }
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        super.onStateChange( event );

        var fFrozenDuration : Number = NaN || 0.5;

        // 移除死亡标记状态
        this._onTransitionDone();

        var isBlockObj : Boolean;
        var pMonsterProperty : CMonsterProperty = owner.getComponentByClass( CMonsterProperty , false ) as CMonsterProperty;
        if( pMonsterProperty)
            isBlockObj = pMonsterProperty.style == 1;

        if (isBlockObj || (isOnGround && event.from != CCharacterActionStateConstants.KNOCK_UP && event.from != CCharacterActionStateConstants.HURT )) {
            this.setMovable( false );
            this.setDirectionPermit( false );
            this.makeStop();
            _playDeadAnimation( fFrozenDuration );
        }


        if ( !isOnGround && event.from != CCharacterActionStateConstants.KNOCK_UP && event.from != CCharacterActionStateConstants.HURT ) {
            this.setMovable( false );
            this.setDirectionPermit( false );

            eventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );
        }
    }

    private function _playDeadAnimation( fFrozenDuration : Number = 0.5 ) : void {
        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.animationOffsetEnabled = true;
            pAnimation.playAnimation( CAnimationStateConstants.DEAD );
            pAnimation.frozenFrame( fFrozenDuration );
        }
    }

    private function _onGround( e : Event ) : void {

        var pStateBoard : CCharacterStateBoard = stateBoard;
        if ( pStateBoard ) {
            if ( pStateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) && pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                if ( eventMediator )
                    eventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onGround );
                _playDeadAnimation();
            }
        }
    }

    override protected virtual function onAfterState( event : CStateEvent ) : void {
        super.onAfterState( event );
    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        this.clearSubscribeAnimationEnds();
        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.animationOffsetEnabled = false;
        }
        return super.onExitState( event );


    }

}
}
