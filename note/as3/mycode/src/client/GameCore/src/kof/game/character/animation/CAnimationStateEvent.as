//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import flash.events.Event;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CAnimationStateEvent extends Event {

    public static const ENTER_ANIMATION_STATE : String = "ENTER_ANIMATION_STATE";

    public var fromAnimation : String;
    public var toAnimation : String;

    public function CAnimationStateEvent( eventName : String, fromAnimation : String, toAnimation : String ) {
        super( eventName, false, true );

        this.fromAnimation = fromAnimation;
        this.toAnimation = toAnimation;
    }

}
}

// vim:ft=as3 tw=120
