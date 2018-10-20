//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/8.
 */
package kof.game.item {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.table.Item;
import kof.util.CQualityColor;

public class CItemData extends CObjectData {
    public function CItemData() {
    }

    public function get ID() : int { return _data[ITEM_ID]; }

    // table data
    public function get name() : String {
        return itemRecord.name;
    }
    public function get typeDisplay() : int {
        return itemRecord.typeDisplay;
    }
    public function get teamLevel() : int {
        return itemRecord.teamLevel;
    }
    public function get nameWithColor() : String {
        return "<font color='" + CQualityColor.QUALITY_COLOR_ARY[quality-1] + "'>" + name + "</font>"; // 物品和装备, 格斗家不一样, 品质是从1开始
    }
    public function get strokeColor() : String {
        return CQualityColor.QUALITY_COLOR_STROKE_ARY[quality-1];
    }
    public function get usageDesc() : String {
        return itemRecord.usageDescription;
    }
    public function get desc() : String {
        return itemRecord.literatureDescription;
    }
    // 1装备, 2材料, 3碎片, 99其他, 用于排序
    public function get priority() : int {
        return itemRecord.type;
    }
    // 同类型排序值
    public function get sortValueBySameType() : int {
        return itemRecord.sortID;
    }
    public function get quality() : int {
        return itemRecord.quality;
    }
    //祝福石概率
    public function get stoneProbability():Number{
        return Number(itemRecord.param5)*100/10000;
    }
    // 是否能叠加
    public function get isStackable() : Boolean {
        return itemRecord.canStackable > 0;
    }
    // 叠加数量
    public function get stackLimit() : int {
        return itemRecord.stackableLimit;
    }
    public function get canSell() : Boolean {
        return itemRecord.canSell > 0;
    }
    // only gold
    public function get sellPrice() : int {
        return itemRecord.sellPrice;
    }
    public function get iconBig() : String {
        return itemRecord.bigiconURL + ".png";
    }
    public function get iconSmall() : String {
        return itemRecord.smalliconURL + ".png";
    }
    // 1装备, 2材料, 3碎片, 4其他, -1不在背包显示
    public function get page() : int {
        return itemRecord.page;
    }
    public function get isEquipPage() : Boolean {
        return page == PAGE_EQUIP;
    }
    public function get isMaterialPage() : Boolean {
        return page == PAGE_MATERIAL;
    }
    public function get isPiecePage() : Boolean {
        return page == PAGE_PIECE;
    }
    public function get isOtherPage() : Boolean {
        return page == PAGE_OTHER;
    }
    public function get isNotInBagPage() : Boolean {
        return page == PAGE_NOT_IN_BAG;
    }

    //是否显示特效,新增数量条件
    public function get effect() : Boolean
    {
        //return itemRecord.effect;
        return itemRecord.effect > 0 ? (itemRecord.extraEffect == 0 || num >= itemRecord.extraEffect) : false;
    }

    // =========use
    public function get canUse() : Boolean {
        return itemRecord.useEffectScriptID > 0;
    }
    public function get isDropUsage() : Boolean {
        return itemRecord.useEffectScriptID == USE_DROP;
    }
    public function get isComboUsage() : Boolean {
        return itemRecord.useEffectScriptID == USE_COMBO;
    }
    public function get isJumpWindowUsage() : Boolean {
        return itemRecord.useEffectScriptID == USE_JUMP_TO_WND;
    }
    public function get isComposeUsage() : Boolean {
        return itemRecord.useEffectScriptID == USE_COMPOSE;
    }
    public function get isCurrencyUsage() : Boolean {
        return itemRecord.useEffectScriptID == USE_CURRENCY;
    }

    // =======use effect
    // 仅限 USE_CURRENCY与USE_JUMP_TO_WND
    // 获得货币类型
    public function get usageCurrencyType() : int {
        if (this.isCurrencyUsage) {
            return int(this.itemRecord.param1);
        }
        if (this.isJumpWindowUsage) {
            return int(this.itemRecord.param3);
        }
        return 0;
    }
    // 获得增加的值
    public function get usageCurrencyValue() : Number {
        if (this.isCurrencyUsage) {
            return Number(this.itemRecord.param2);
        }
        if (this.isJumpWindowUsage) {
            return Number(this.itemRecord.param4);
        }
        return 0;
    }

    // 仅限 USE_COMPOSE, 合成
    // 合成道具，需要的数量
    public function get usageComposeNumNeed() : Number {
        if (this.isComposeUsage) {
            return Number(this.itemRecord.param1);
        }
        return 0;
    }
    // 合成后变成的道具ID
    public function get usageComposeTargetID() : int {
        if (this.isComposeUsage) {
            return int(this.itemRecord.param2);
        }
        return 0;
    }

    // 仅限USE_JUMP_TO_WND
    // 跳转目标界面
    public function get usageJumpWindow() : String {
        if (this.isJumpWindowUsage) {
            return this.itemRecord.param1;
        }
        return null;
    }

    // 仅组合 : USE_COMBO
    // 获得组合列表
    public function get usageComboItemList() : Array {
        if (this.isComboUsage) {
            var record:Item = this.itemRecord;
            var objData:Object;
            var list:Array = new Array();
            for (var i:int = 0; i < 4; i++) {
                var itemID:int = (int)(record["param"+(i*2+1)]);
                var itemNum:Number = (Number)(record["param"+(i*2+2)]);
                if (itemID > 0 && itemNum > 0) {
                    objData = {itemID:itemID, num:itemNum};
                    list.push(objData);
                }
            }
            return list;
        }
        return null;
    }

    // 仅 USE_DROP
    // 掉落类型, 1掉落包, 2掉落组
    public function get usageDropType() : int {
        if (this.isDropUsage) { return (int)(itemRecord.param1); }
        return 0;
    }
    public function get isDropPackage() : Boolean {
        return usageDropType == 1;
    }
    public function get isDropGroup() : Boolean {
        return usageDropType == 2;
    }
    // 掉落的组或包ID
    public function get usageDropID() : int {
        if (this.isDropUsage) { return (int)(itemRecord.param2); }
        return 0;
    }

    public static const ITEM_ID:String = "ID";
    public static const NUM:String = "num";

    // page type
    public static const PAGE_EQUIP:int = 1;
    public static const PAGE_MATERIAL:int = 2; // 材料
    public static const PAGE_PIECE:int = 3;
    public static const PAGE_OTHER:int = 4;
    public static const PAGE_NOT_IN_BAG:int = -1;

    // use effect
    public static const USE_NONE:int = 0; // 不能使用
    public static const USE_DROP:int = 1; // 调用掉落功能（参数1：1为掉落包、2为掉落组；参数2 掉落包或者掉落组id）
    public static const USE_COMBO:int = 2; // 多选功能（参数1：物品1ID,参数2：数量；参数3：物品2ID,参数4：数量；参数5：物品3ID,参数6：数量；参数7：物品4ID,参数8：数量；）
    public static const USE_JUMP_TO_WND:int = 3; // 使用跳转到制定界面（参数1：界面程序名称；参数2：制定角色列表中角色ID??；参数3：货币类型；参数4：货币数量）
    public static const USE_COMPOSE:int = 4; // 使用多个道具合成另外一种道具1个（参数1：每次合成需要的数量；参数2：合成后变成的道具ID）
    public static const USE_CURRENCY:int = 5; // 使用道具获得一定数量的货币（参数1：货币类型；参数2：货币数量）


    /** 品质颜色 */
//    public static const QUALITY_COLOR_ARY:Array = ["","#d3d3d3","#48d441","#3fbfda","#cb53dd","#eb8726","#eb8726","#f03f3f"];
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

    public static function createObjectData(itemID:int) : Object {
        return {ID:itemID};
    }
    public function get itemRecord() : Item {
        if (_itemRecord == null) _itemRecord = _databaseSystem.getTable(KOFTableConstants.ITEM).findByPrimaryKey(ID);
        return _itemRecord;
    }

    public function set itemRecord( value:Item ) :void {
        _itemRecord = value;
    }
    private var _itemRecord:Item;

    public function get num():Number {return _data[NUM];}
    public function set num(value:Number):void
    {
        _data[NUM] = value;
    }
}
}
