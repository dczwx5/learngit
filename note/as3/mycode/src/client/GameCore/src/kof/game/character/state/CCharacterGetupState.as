//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import kof.framework.fsm.CStateEvent;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;

/**
 * 角色倒地起身状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterGetupState extends CCharacterState {

    public function CCharacterGetupState() {
        super( CCharacterActionStateConstants.GETUP );
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        this.setMovable( false ); // 可以不可以主动移动
        this.setDirectionPermit( false );

        var pAnimation : IAnimation = this.animation;
        if ( pAnimation ) {
            pAnimation.playAnimation( CAnimationStateConstants.GETUP, true );
            this.subscribeAnimationEnd( _onGetupAnimationEnd );
        }

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
        }
    }

    override protected virtual function onExitState( event : CStateEvent ) : Boolean {
        var ret : Boolean = super.onExitState( event );
        this.clearSubscribeAnimationEnds();

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_ATTACK );
            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_CATCH );
        }

        return ret;
    }

    final private function _onGetupAnimationEnd( sEventName : String = null, sFrom : String = null, sTo : String = null ) : void {
        fsm.on( nextStateEvent );
    }

}
}
