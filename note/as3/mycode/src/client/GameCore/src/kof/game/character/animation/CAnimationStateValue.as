//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

/**
 * AnimationState的状态值常量类
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CAnimationStateValue {

    static public const IDLE : int = 1;
    static public const TURN : int = 1 << 1;
    static public const RUN : int = 1 << 2;

    static public const SKILL : int = 1 << 5;
    static public const SKILL_3 : int = 1 << 6;
    static public const SKILL_4 : int = 1 << 7;
    static public const SKILL_5 : int = 1 << 8;
    static public const SKILL_6 : int = 1 << 9;
    public static const DEAD : int = 1 << 10;
    public static const DEAD_SIGN : int = 1 << 11;

    public function CAnimationStateValue() {
    }
}
}
