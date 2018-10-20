//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.impression.util {

/**
 * 好感度操作锁定状态类
 */
public class CImpressionState {

    public static var isInLevelUpgrade:Boolean;// 是否正在升级中

    public function CImpressionState() {
    }

    public static function rest():void
    {
        isInLevelUpgrade = false;
    }
}
}
