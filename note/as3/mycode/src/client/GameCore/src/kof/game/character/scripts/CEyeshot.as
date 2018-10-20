//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import kof.game.character.CEventMediator;
import kof.game.character.animation.CAnimationStateEvent;
import kof.game.character.movement.CMovement;
import kof.game.core.CSubscribeBehaviour;

/**
 * 角色视野
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CEyeshot extends CSubscribeBehaviour {

    /**
     * Creates a new CEyeshot.
     */
    public function CEyeshot() {
        super("eyeshot");
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected function onExit() : void {
        super.onExit();
    }

} // class CEyeshot
} // package kof.game.character.scripts
