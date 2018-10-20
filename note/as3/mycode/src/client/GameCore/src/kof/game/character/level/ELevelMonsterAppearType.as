//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.level {

/**
 * 怪物出场方式类型
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class ELevelMonsterAppearType {

    public static const NORMAL : int = 0; // 直接出现
    public static const WALK : int = 1; // 走
    public static const RUN : int = 2; // 跑
    public static const FALL : int = 3; // 天上掉下来
    public static const SKILL : int = 4; // 放个技能出来
    public static const GENERAL : int = 5; // 通用（后面都是用这个）

    public function ELevelMonsterAppearType() {
    }

}
}
