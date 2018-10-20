//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

/**
 * 角色动作状态常量集
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CCharacterActionStateConstants {

    static public const IDLE : String = "idle";
    static public const RUN : String = "run";
    static public const ATTACK : String = "attack";
//    static public const GUARD : String = "guard";
    static public const HURT : String = "hurt";
    static public const KNOCK_UP : String = "KnockUp";
    static public const E_ROLL : String = "eRoll";
    static public const LYING : String = "lying";
    static public const GETUP : String = "getup";
    static public const DEAD : String = "dead";
    static public const BE_CATCH : String = "beCatch";

    // Transit to "IDLE" generally.
    static public const EVENT_POP : String = "pop2root";

    static public const EVENT_RUN : String = "run";
    static public const EVENT_STOP : String = "stop";

    static public const EVENT_ATTACK_BEGAN : String = "attackBegan";
    static public const EVENT_ATTACK_END : String = "attackEnd";

    static public const EVENT_DODGE_BEGAN : String = "dodgeStart";

    static public const EVENT_GUARD_BEGAN : String = "guardBegin";

    static public const EVENT_HURT_BEGAN : String = "hurtBegan";

    static public const EVENT_KNOCK_UP_BEGAN : String = "knockUpBegan";

    static public const EVENT_LYING_BEGAN : String = "lyingBegan";

    static public const EVENT_LYING_HURT_BEGAN : String = "lyingHurtBegan";
    static public const EVENT_LYING_HURT_END : String = "lyingHurtEnd";

    static public const EVENT_GETUP_BEGAN : String = "getupBegan";

    static public const EVENT_CATCH_BEGIN : String = "catchBegan";
    static public const EVENT_CATCH_END : String = "catchEnd";

    public static const EVENT_DEAD : String = "dead";

    public function CCharacterActionStateConstants() {
    }
}
}
