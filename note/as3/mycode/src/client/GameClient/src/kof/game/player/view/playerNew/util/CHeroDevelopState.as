//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.player.view.playerNew.util {

/**
 * 格斗家培养操作锁定状态类
 */
public class CHeroDevelopState {

    public static var isInQualAdvance:Boolean;// 是否正在格斗家升品
    public static var isInLevelUpgrade:Boolean;// 是否正在格斗家升级
    public static var isInStarAdvance:Boolean;// 是否正在格斗家升星

    public function CHeroDevelopState()
    {
    }

    public static function reset():void
    {
        isInQualAdvance = false;
        isInLevelUpgrade = false;
        isInStarAdvance = false;
    }
}
}
