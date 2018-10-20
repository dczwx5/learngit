//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/28.
 */
package kof.game.player.view.event {

public class EPlayerViewEventType {
    // 格斗家列表
    public static const EVENT_EQUIP_UP_CLICK:String = "equip_up_click";
    public static const EVENT_HERO_UP_CLICK:String = "hero_up_click";
    public static const EVENT_HERO_ICON_CLICK:String = "hero_icon_click";
    public static const EVENT_HERO_HIRE_CLICK:String = "hero_hire_click";
    public static const EVENT_HERO_SEARCH_PIECE_CLICK:String = "hero_find_piece_click";

    // 格斗家详细界面
    public static const EVENT_LIST_SELECT_HERO:String = "list_select_hero";

    // 战队列表
    public static const EVENT_CHANGE_ICON_CLICK:String = "change_icon_click";
    public static const EVENT_CHANGE_NAME_CLICK:String = "change_name_click";
    public static const EVENT_CHANGE_ROLE_MODEL_CLICK:String = "change_role_mo_click";

    // 战队改名
    public static const EVENT_RANDOM_NAME_CLICK:String = "random_name_click";

    //格斗家培养，升级、升品、升星
    public static const EVENT_HERO_TRAIN_STAR:String = "heroTrainStar";
    public static const EVENT_HERO_TARIN_QUALITY:String = "heroTrainQuality";
    public static const EVENT_HERO_TRAIN_LEVELUP:String = "heroTrainLevelUP";
    public static const EVENT_HERO_TRAIN_SHOWTIP:String = "heroTrainShowTip";
    //批量使用
    public static const EVENT_BATCH_USE_ITEM:String = "batchUseItem";
    public static const EVENT_BATCH_USE_CHANGE_ITEM_NUM:String = "batchUseChangeItemNum";
    public static const EVENT_BATCH_USE_OK:String = "batchUseOK";
    //装备培养
    public static const EVENT_EQUIP_TRAIN_LEVELUP:String = "equipTrainLevelUp";
    public static const EVENT_EQUIP_TRAIN_ONEKEY_LEVELUP:String = "equipTrainOneKeyLevelUp";
    public static const EVENT_EQUIP_TRAIN_QUALITY:String = "equipTrainQuality";
    public static const EVENT_EQUIP_TRAIN_STAR:String = "equipTrainStar";

    public static const EVENT_EQUIP_STONE:String="equipStone";
}
}
