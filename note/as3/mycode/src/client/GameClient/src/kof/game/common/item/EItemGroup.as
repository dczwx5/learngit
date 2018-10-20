//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/25.
 */
package kof.game.common.item {

/**
 * 物品一级分类枚举
 */
public class EItemGroup {

    /** 能力道具 */
    public static const AbilityProp:int = 1;
    /** 功能道具 */
    public static const FunctionProp:int = 2;
    /** 能力材料 */
    public static const Stuff:int = 3;
    /** 合成碎片 */
    public static const Chip:int = 4;
    /** 消耗品 */
    public static const Consumables:int = 5;
    /** 礼包 */
    public static const GiftPack:int = 6;
    /** 其他 */
    public static const Other:int = 7;

    public function EItemGroup() {
    }
}
}
