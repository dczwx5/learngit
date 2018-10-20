//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/25.
 */
package kof.game.common.item {

/**
 * 物品二级分类枚举
 */
public class EItemCategory {

// 功能道具============================================================================================
    /** 喇叭 */
    public static const FuncProp_Speaker:int = 1;
    /** 副本扫荡券 */
    public static const FuncProp_CopyRaidNote:int = 2;
    /** 副本次数卷轴 */
    public static const FuncProp_CopyNumScroll:int = 3;


// 材料================================================================================================
    /** 角色升品材料 */
    public static const Stuff_HeroQuality:int = 1;
    /** 装备升品材料 */
    public static const Stuff_EquipQuality:int = 2;
    /** 装备觉醒石 */
    public static const Stuff_EquipAwakeStone:int = 3;
    /** 装备觉醒祝福石 */
    public static const Stuff_EquipAwakeBlessStone:int = 4;
    /** 装备武器觉醒魂魄 */
    public static const Stuff_EquipAwakeSoul:int = 5;


// 合成碎片=============================================================================================
    /** 英雄碎片 */
    public static const Chip_Hero:int = 1;
    /** 英雄万能碎片 */
    public static const Chip_HeroUniversal:int = 2;
    /** 魂魄碎片 */
    public static const Chip_Soul:int = 3;


// 消耗品===============================================================================================
    /** 体力 */
    public static const Consumables_Power:int = 1;
    /** 金币 */
    public static const Consumables_Gold:int = 2;
    /** 蓝钻 */
    public static const Consumables_BlueDiamond:int = 3;
    /** 紫钻 */
    public static const Consumables_PurpleDiamond:int = 4;
    /** vip经验 */
    public static const Consumables_VipExp:int = 5;
    /** 战队经验 */
    public static const Consumables_TeamExp:int = 6;
    /** 技能点 */
    public static const Consumables_SkillPoint:int = 7;
    /** 天赋点 */
    public static const Consumables_TalentPoint:int = 8;
    /** 角色经验 */
    public static const Consumables_RoleExp:int = 9;
    /** 秘籍经验 */
    public static const Consumables_CheatsExp:int = 10;
    /** 徽章经验 */
    public static const Consumables_BadgeExp:int = 11;


// 礼包===============================================================================================
    /** 活动礼包 */
    public static const GiftPack_Activity:int = 1;
    /** 充值礼包 */
    public static const GiftPack_Recharge:int = 2;

    public function EItemCategory() {
    }
}
}
