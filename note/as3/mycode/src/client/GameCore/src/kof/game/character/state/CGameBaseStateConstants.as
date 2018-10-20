//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

/**
 * 游戏基础状态枚举
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CGameBaseStateConstants {

    // States
    static public const BORN : String = "born";
    static public const IDLE : String = "idle";
    static public const FIGHT : String = "fight";

    // Events
    static public const EVENT_BORN : String = BORN;
    static public const EVENT_FIGHT_BEGAN : String = "fightBegan";
    static public const EVENT_FIGHT_END : String = "fightEnd";

    public function CGameBaseStateConstants() {
    }
}
}
