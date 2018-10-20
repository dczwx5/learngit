//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import kof.game.character.CEventMediator;
import kof.game.character.animation.CAnimationStateEvent;
import kof.game.character.movement.CMovement;
import kof.game.core.CSubscribeBehaviour;

/**
 * 角色动作状态校验逻辑
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAnimationStateValidator extends CSubscribeBehaviour {

    public function CAnimationStateValidator() {
        super( null );
    }


    override protected virtual function onEnter() : void {
        super.onEnter();
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CAnimationStateEvent.ENTER_ANIMATION_STATE, _onEnterAnimationState, false );
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CAnimationStateEvent.ENTER_ANIMATION_STATE, _onEnterAnimationState );
        }
    }

    /** @private 当角色被动进行切换动作状态时触发 */
    final private function _onEnterAnimationState( event : CAnimationStateEvent ) : void {
        // 移动状态逻辑
        var pMovement : CMovement = getComponent( CMovement ) as CMovement;
        if ( pMovement ) {
            if ( pMovement.moving ) {
                // 移动中屏蔽所有状态
                event.preventDefault(); // 取消切换
            }
        }
    }

}
}
