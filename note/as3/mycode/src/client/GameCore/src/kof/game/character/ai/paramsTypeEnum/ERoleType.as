//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/5.
 * Time: 12:00
 */
package kof.game.character.ai.paramsTypeEnum {

    public class ERoleType {
        /**小兵*/
        public static const SOLDIER : String = "Soldier";
        /**精英*/
        public static const ELITE : String = "Elite";
        /**boss*/
        public static const BOSS : String = "Boss";
        /**玩家*/
        public static const PLAYER : String = "Player";
        /**全类型*/
        public static const ALL : String = "All";
        /**根据boss到小怪的顺序，优先选择高等怪物*/
        public static const BOSS_TO_SOLDIER : String = "BossToSoldier";
    }
}
