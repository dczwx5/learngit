//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import flash.events.Event;

/**
 * 场景支持事件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSceneEvent extends Event {

    static public const HERO_CREATED : String = "HERO_CREATED";
    static public const HERO_INIT: String = "HERO_INIT";
    static public const HERO_READY : String = "HERO_READY";
    static public const HERO_REMOVED : String = "HERO_REMOVED";
    static public const MISSILE_REMOVE : String = "MISSIEL_REMOVE";

    static public const BOSS_APPEAR : String = "BOSS_APPEAR";
    static public const CHARACTER_READY : String ="character_ready";

    static public const CHARACTER_IN_VIEW : String = "character_in_view";
    static public const CHARACTER_OUT_VIEW : String = "character_out_view";

    public function CSceneEvent( type : String, value : * = null, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.value = value;
    }

    public var value : *;

}
}
