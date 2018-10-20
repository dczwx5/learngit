//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import flash.events.Event;

import kof.game.core.CGameObject;

/**
 * 角色事件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterEvent extends Event {

    static public const START_MOVE : String                = "character_startMove";
    static public const STOP_MOVE : String                 = "character_stopMove";
    static public const DIRECTION_CHANGED : String         = "character_directionChanged";
    static public const FORCE_RESET_DIRECTEION : String     = "character_reset_direction";
    static public const ANIMATION_TIME_END : String        = "character_animationTimeEnd";
    static public const CHARACTER_PROPERTY_UPDATE : String = "character_property_update";
    static public const STATE_VALUE_UPDATE : String        = "character_stateValue_update";
    static public const TARGET_CHANGED : String            = "character_target_changed";
    static public const READY : String                     = "character_ready";
    static public const INIT : String                      = "character_init";
    static public const REMOVED : String                   = "character_removed";
    static public const DODGE_BEGIN : String               = "character_dodge_begin";
    static public const DODGE_FAILED : String              = "character_dodge_failed";
    static public const DODGE_END : String                 = "character_dodge_end";
    static public const BLOCK_IN_SCENE: String             = "character_block_in_scene";
    static public const APPEAR_END : String                = "character_appear_end";
    static public const ANIMATION_RESUME : String          = "character_animation_resume";
    // Only available on hero.
    static public const SWITCH_HERO : String               = "character_switch_hero";

    // 看到新的角色时触发
    static public const EYESHOT_ADD : String               = "character_eyeshot_add";
    // 有角色从可视范围消失时触发
    static public const EYESHOT_REMOVED : String           = "character_eyeshot_removed";
    static public const BE_IN_VIEW : String                = "character_in_view";
    static public const OUT_OF_VIEW : String               = "character_out_of_view";
    static public const DIE : String                       = "character_die";
    static public const INSTANCE_STARTED : String          = "character_instance_statted";
    public static const DISPLAY_READY : String             = "character_display_ready";
    public static const SKILL_COMP_READY : String          = "character_skill_comp_ready";
    static public const SKILL_ANIMATION_TAG_CHG:String     = "animation_tag_change";
    public static const COLLISION_READY : String           = "character_collision_ready";

    private var m_pCharacter : CGameObject;

    public function CCharacterEvent( type : String, character : CGameObject, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
        this.m_pCharacter = character;
    }

    [Inline]
    final public function get character() : CGameObject {
        return m_pCharacter;
    }

}
}
