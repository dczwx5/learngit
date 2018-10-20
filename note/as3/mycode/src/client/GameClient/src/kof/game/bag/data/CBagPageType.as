//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/22.
 */
package kof.game.bag.data {

public class CBagPageType {

    /** 全部（有部分不显示在背包） */
    public static const BAG_SHOW_ALL:int = 0;

    /** 装备 */
    public static const BAG_EQUIP:int = 1;

    /** 材料 */
    public static const BAG_MATERIAL:int = 2;

    /** 碎片 */
    public static const BAG_CHIP:int = 3;

    /** 其他 */
    public static const BAG_OTHER:int = 4;

    /** 不在背包显示*/
    public static const BAG_NOT_SHOW:int = -1;


    public function CBagPageType() {
    }
}
}
