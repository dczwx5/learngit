//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/24.
 */
package kof.game.bag.data {

public class CBagConst {
    public function CBagConst() {
    }

    public static const TITLE_ARY:Array = ["展示","批量使用","批量出售","物品合成"];
    public static const MENU_ARY:Array = [SHOW_STR,USE_STR,SELL_STR,SYNTHESIS_STR];
    public static const TYPE_ARY:Array = ["","装备","材料","碎片","其他"];


    static public const SHOW_STR : String = '展示' ;
    static public const USE_STR : String = '使用' ;
    static public const SELL_STR : String = '出售' ;
    static public const SYNTHESIS_STR : String = '合成' ;
    /** 白 */
    public static const QUALITY_WHITE:int = 1;
    /** 绿 */
    public static const QUALITY_GREEN:int = 2;
    /** 蓝 */
    public static const QUALITY_BLUE:int = 3;
    /** 紫*/
    public static const QUALITY_VIOLET:int = 4;
    /** 橙 */
    public static const QUALITY_ORANGE:int = 5;
    /** 金 */
    public static const QUALITY_GOLDEN:int = 6;
    /** 红 */
    public static const QUALITY_RED:int = 7;

}
}
