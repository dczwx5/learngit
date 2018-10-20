//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/23.
 */
package kof.game.player.data {

    import kof.data.CObjectData;
    import kof.data.KOFTableConstants;
    import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bag.data.CBagData;
    import kof.util.CQualityColor;
    import kof.game.player.data.property.CHeroEquipProperty;
    import kof.game.player.data.property.CHeroEquipPropertyCale;
    import kof.table.EquipAwaken;
    import kof.table.EquipAwakenTemplate;
    import kof.table.EquipBase;
    import kof.table.EquipQuality;
    import kof.table.EquipUpQuality;
    import kof.table.EquipUpgrade;

    public class CHeroEquipData extends CObjectData {
    public function CHeroEquipData() {
        _calcProperty = new CHeroEquipPropertyCale(this);
        _propertyData = new CEquipPropertyData();

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty("fightProperty")) {
            _propertyData.updateDataByData(data["fightProperty"]);
        }
    }
    [Inline]
    public function get propertyData() : CEquipPropertyData { return _propertyData; }

    public function get equipID() : Number { return _data[_equipID]; }
    public function get baseID() : int { return _data[_baseID]; }
    public function get level() : int { return _data[_level]; }
    public function get quality() : int { return _data[_quality]; }
    public function get star() : int { return _data[_star]; }
    public function get attackPercent() : int { return _data[_attackPercent]; }
    public function get defencePercent() : int { return _data[_defencePercent]; }
    public function get hpPercent() : int { return _data[_hpPercent]; }
    public function get exp() : int { return _data[_exp]; }//  经验

    public static const _equipID:String = "equipID"; // 唯一ID
    public static const _baseID:String = "baseID"; // 配置表ID, 装备ID
    public static const _level:String = "level"; // 等级
    public static const _quality:String = "quality"; // 品质
    public static const _star:String = "star"; // 星级
    public static const _attackPercent:String = "attackPercent"; // 攻击万分值
    public static const _defencePercent:String = "defencePercent"; // 防御万分值
    public static const _hpPercent:String = "hpPercent"; // 生命万分值
    public static const _exp:String = "exp"; // 生命万分值

    public static const _part:String = "part"; // 部位

    public function isEquip() : Boolean {
        return (false == isBook()) && (false == isBadges());
    }
    public function isWeapon() : Boolean {
        return POS_WEAPON == part;
    }
    public function isClothes() : Boolean {
        return POS_CLOTHES == part;
    }
    public function isTrousers() : Boolean {
        return POS_TROUSERS == part;
    }
    public function isShoes() : Boolean {
        return POS_SHOES == part;
    }
    public function isBadges() : Boolean {
        return POS_BADGES == part;
    }
    public function isBook() : Boolean {
        return POS_BOOK == part;
    }

    public static function GetSysTag(part:int) : String {
        var sysTag:String;
        switch (part) {
            case POS_WEAPON :
                sysTag = KOFSysTags.EQP_SWORD;
                break;
            case POS_CLOTHES :
                sysTag = KOFSysTags.EQP_CLOTHES;
                break;
            case POS_TROUSERS :
                sysTag = KOFSysTags.EQP_TROUSERS;
                break;
            case POS_SHOES :
                sysTag = KOFSysTags.EQP_SHOES;
                break;
            case POS_BADGES :
                sysTag = KOFSysTags.EQP_ATTSTRONG;
                break;
            case POS_BOOK :
                sysTag = KOFSysTags.EQP_HPSTRONG;
                break;
            default :
                sysTag = KOFSysTags.EQP_SWORD;
                break;
        }
        return sysTag;
    }
    public function getSysTag() : String {
        return GetSysTag(part);
    }

    //============ 基础表数据
        public function get eqpdis():String{
            return equipBaseRecord.eqpdis;
        }
    public function get name() : String {
        return equipBaseRecord.name;
    }
    public function get nameWithColor() : String {
        return "<font color='" + CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue] + "'>" + name + "</font>";
    }
    public function get nameQualityWithColor() : String {
        return "<font color='" + CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue] + "'>" + name + " +" + qualityLevelSubValue + "</font>";
    }
    public function get nameNextQualityWithColor():String{
        return "<font color='" + CQualityColor.QUALITY_COLOR_ARY[nextQualityLevelValue] + "'>" + name + " +" + (nextQualityLevelSubValue) + "</font>";
    }
    public function get part() : int {
        return equipBaseRecord.part;
    }
    // 所属格斗家ID
    public function get belongHero() : int {
        return equipBaseRecord.heroID;
    }
    // 对应格斗家的资质, 与格斗家表里的资质是一样的
    public function get heroQuality() : int {
        return equipBaseRecord.heroQuality;
    }
    // 装备是否能觉醒
    public function get isCanAwaken() : Boolean {
        return equipBaseRecord.canAwaken == 1;
    }
    public function get smallIcon() : String {
        return equipBaseRecord.smalliconURL+".png";
    }
    public function get bigIcon() : String {
        return equipBaseRecord.bigiconURL+".png";
    }

    // ===============================升级
    // 当前等级属性数据, 下一级的升级消耗数据
    public function get levelUpRecord() : EquipUpgrade {
        if (_equipLevelUpgradeRecord == null || level < _equipLevelUpgradeRecord.levelMin || level > _equipLevelUpgradeRecord.levelMax) {
            _equipLevelUpgradeRecord = getLevelUpData(level);
        }
        return _equipLevelUpgradeRecord;
    }
    // 当前品质等级限制
    public function get levelLimit() : int {
        // 当前品质最多可以升到的等级, 品质与等级相互限制
        var levelLimit:int = qualityUpRecored.equipLevelLimit;
        return levelLimit;
    }
    // 是否能升级
    public function isCanLevelUp() : Boolean {
        return level < levelLimit;
    }

    // 下一级需要消耗的金币数 1-6部位
    public function get nextLevelGoldCost() : int {
        return levelUpRecord.consumeGolds;
    }
    // 下一级需要消耗的额外的货币类型 5-6部位
    public function get nextLevelOtherCurrencyType() : int {
        return levelUpRecord.consumeCurrencyType;
    }
    // 下一级需要消耗的额外的货币数量 5-6部位
    public function get nextLevelOtherCurrencyCost() : int {
        return levelUpRecord.consumeCurrencyCount;
    }
    // vector.<itemID>  5-6部位
    public function get nextLevelExtendsItemListCost() : Vector.<int> {
        var record:EquipUpgrade = levelUpRecord;
        var ret:Vector.<int> = new Vector.<int>();
        if (record.itemID1 > 0) ret.push(record.itemID1);
        if (record.itemID2 > 0) ret.push(record.itemID2);
        if (record.itemID3 > 0) ret.push(record.itemID3);
        // if (record.itemID4 > 0) ret.push(record.itemID4);
        return ret;
    }
    // 下一级的表数据, 非消耗
    public function get nextLevelUpPropertyData() : EquipUpgrade {
        var curLvTable:EquipUpgrade = getLevelUpData(level);
        var nu:int=curLvTable.levelMax-curLvTable.levelMin+1;
        if(level%nu==0)
        {
            return getLevelUpData(level);
        }
        else
        {
            return getLevelUpData(level+1);
        }

    }
    public function getLevelUpData(level:int) : EquipUpgrade {
        var part:int = this.part;
        var heroQuality:int = this.heroQuality;
        var list:Vector.<Object> = this.equipLevelTable.toVector();
        for each (var data:EquipUpgrade in list) {
            if (data.part == part && level >= data.levelMin && level <= data.levelMax && heroQuality >= data.qualityMin && heroQuality <= data.qualityMax) {
                return data;
            }
        }
        return null;
    }

    // ==========================升品
        // 是否处于升品状态
    public function get isUpgradeQualityState() : Boolean {
        return level >= levelLimit;
    }

    // 是否可以升到下一品
    public function get isCanUpgradeQuality() : Boolean {
        return level >= levelLimit && (_rootData as CPlayerData).teamData.level >= nextQualityTeamLevelNeed;
    }
    // 当前品质对应表数据
    public function get qualityUpRecored() : EquipUpQuality {
        if (_equipQualitRecord == null || quality != _equipQualitRecord.quality) {
            _equipQualitRecord = getQualityUpRecord(quality);
        }
        return _equipQualitRecord;
    }
    // 升一品质, 战队等级需要
    public function get nextQualityTeamLevelNeed() : int {
        return qualityUpRecored.teamLevelLimit;
    }
    // 下一级品质需要的道具列表 1-4部位需要
    public function get nextQualityItemCost() : Vector.<CBagData> {
        var record:EquipUpQuality = qualityUpRecored;

        var vec:Vector.<CBagData>;
        var bagData:CBagData = null;
        var bagObjectData:Object;
        var ITEM_COUNT:int = 4;
        for (var i:int = 0; i < ITEM_COUNT; i++) {
            var itemID:int = record["item" + (i+1)];
            var num:int = record["count" + (i+1)];
            if (itemID > 0 && num > 0) {
                bagData = new CBagData();
                bagObjectData = CBagData.createObjectData(1, itemID, num);
                bagData.updateDataByData(bagObjectData);
                if (vec == null) vec = new Vector.<CBagData>();
                vec.push(bagData);
            }
        }
        return vec;
    }
    // 下一级品质需要金币数 1-6部位
    public function get nextQualityGoldCost() : int {
        return qualityUpRecored.consumeGolds;
    }
    // 下一级消耗额外货币类型 5-6部位
    public function get nextQualityOtherCurrencyType() : int {
        return qualityUpRecored.consumeCurrencyType;
    }
    // 下一级消耗额外数量 5-6部位
    public function get nextQualityOtherCurrencyCost() : int {
        return qualityUpRecored.consumeCurrencyCount;
    }
    public function getQualityUpRecord(quality:int) : EquipUpQuality {
        var part:int = this.part;
        var heroQuality:int = this.heroQuality;
        var list:Vector.<Object> = this.equipQualityTable.toVector();
        for each (var data:EquipUpQuality in list) {
            if (quality == data.quality && data.part == part && heroQuality >= data.qualityMin && heroQuality <= data.qualityMax) {
                return data;
            }
        }
        return null;
    }

    // =============品质表数据
    // 根据当前quality等级, 获得品质表数据
    public function getQualityLevel(quality:int) : EquipQuality {
        var qualityLevel:EquipQuality = equipQualityLevelTable.findByPrimaryKey(quality);
        return qualityLevel;
    }
    // 当前品质表数据
    public function get qualityLevel() : EquipQuality {
        if (_equipQualityLevel == null || quality != _equipQualityLevel.ID) {
            _equipQualityLevel = getQualityLevel(this.quality);
        }
        return _equipQualityLevel;
    }
    // 当前品质级别, 0-6, 白绿蓝...
    public function get qualityLevelValue() : int {
        return int(qualityLevel.qualityColour);
    }
    public function get nextQualityLevelValue() : int {
        return (int)(getQualityLevel(quality+1).qualityColour);
    }

    //  当前品质 + X
    public function get qualityLevelSubValue() : int {
        return _getQualitLevelSubValueB(quality, qualityLevelValue);
    }
    public function get nextQualityLevelSubValue() : int {
        var curQuality:int = quality + 1;
        var curQualityLevelValue:int = (int)(getQualityLevel(curQuality).qualityColour);
        return _getQualitLevelSubValueB(curQuality, curQualityLevelValue);
    }
    private function _getQualitLevelSubValueB(curQuality:int, curQualityLevelValue:int) : int {
        var qualityList:Vector.<Object> = equipQualityLevelTable.toVector();
        var firstSameLevelQuality:EquipQuality;
        for (var i:int = 0; i < qualityList.length; i++) {
            var tempQuality:EquipQuality = (qualityList[i] as EquipQuality);
            if (int(tempQuality.qualityColour) == curQualityLevelValue) {
                if (firstSameLevelQuality == null) {
                    firstSameLevelQuality = tempQuality;
                } else {
                    if (firstSameLevelQuality.ID > tempQuality.ID) {
                        firstSameLevelQuality = tempQuality;
                    }
                }
            }
        }
        var firstQuality:int = firstSameLevelQuality.ID;
        var subValue:int = curQuality - firstQuality;
        return subValue;
    }

    ///////////////////////////////==

    // =======================升星, 觉醒
    // 觉醒蒙版
    public function get equipAwakenTemplateRecord() : EquipAwakenTemplate {
        if (null == _equipAwakenTemplateRecord) _equipAwakenTemplateRecord = _databaseSystem.getTable(KOFTableConstants.EquipAwakenTemplate).findByPrimaryKey(equipBaseRecord.awakenTemplateID);
        return _equipAwakenTemplateRecord;
    }
    // 觉醒名字
    public function get awakenName() : String {
        return equipAwakenTemplateRecord.avakenName;
    }
    // 是否专属装备(策划已去掉)
    public function get isExclusive() : Boolean {
        return equipAwakenTemplateRecord.exclusiveTemplate == 1;
    }
    // 觉醒需要的魂魄ID, 只有专属装备需要
    public function get awakenSoulID() : int {
        return equipAwakenTemplateRecord.soulID;
    }
    // 觉醒后的资源ID, 现在不用处理
    public function get awakenIconID() : int {
        return equipAwakenTemplateRecord.resourceID;
    }
    public function get equipAwakenRecord() : EquipAwaken {
        if (null == _equipAwakenRecord || _equipAwakenRecord.star != star) {
            _equipAwakenRecord = getEquipAwakenRecord(star);
        }
        return _equipAwakenRecord;
    }
    // 下一级需要战队等级
    public function get nextAwakenTeamLevelNeed() : int {
        return equipAwakenRecord.teamLevelLimit;
    }
    // 下一级需要消耗魂魄数量, 注意, 如果不是专属装备, 不需要处理
    public function get nextAwakenSoulCost() : int {
        return equipAwakenRecord.consumeSoul;
    }
    // 下一级需要消耗觉醒石ID
    public function get nextAwakenStoneType() : int {
        return equipAwakenRecord.AwakenStoneid;
    }
    // 下一级需要消耗觉醒石数量
    public function get nextAwakenStoneCost() : int {
        return equipAwakenRecord.consumeAwakenStone;
    }
    // 下一级需要消耗金币数量
    public function get nextAwakenGoldCost() : int {
        return equipAwakenRecord.consumeGolds;
    }
    // 下一级需要消耗货币类型
    public function get nextAwakenCurrencyType() : int {
        return equipAwakenRecord.consumeCurrencyType;
    }
    // 下一级需要消耗货币数量
    public function get nextAwakenCurrencyCount() : int {
        return equipAwakenRecord.consumeCurrencyCount;
    }
    // 下一级需要成功率
    public function get nextAwakenSuccessRate() : Number {
        return equipAwakenRecord.displaySuccessPercent/10000;
    }
    public function getEquipAwakenRecord(star:int) : EquipAwaken {
        var heroQuality:int = this.heroQuality;
        var list:Vector.<Object> = this.equipAwakenTable.toVector();
        for each (var data:EquipAwaken in list) {
            if (star == data.star && heroQuality >= data.qualityMin && heroQuality <= data.qualityMax && data.part == part) {
                return data;
            }
        }
        return null;
    }

    // ==================================================calc property
    public function get currentProperty() : CHeroEquipProperty {
        return _calcProperty.calcProperty() as CHeroEquipProperty; // 其实也可以直接使用当前的数据
    }
    public function get nextLevelProperty() : CHeroEquipProperty {
        return _calcProperty.calcNextLevelProperty() as CHeroEquipProperty;
    }
    public function get nextQualityProperty() : CHeroEquipProperty {
        return _calcProperty.calcNextQualityProperty() as CHeroEquipProperty;
    }
    public function get nextAwakenProperty() : CHeroEquipProperty {
        return _calcProperty.calcNextStarProperty() as CHeroEquipProperty;
    }

    // 内部表格数据
    public function get equipBaseRecord() : EquipBase {
        if (null == _equipBaseRecord) _equipBaseRecord = _databaseSystem.getTable(KOFTableConstants.EQUIP_BASE).findByPrimaryKey(baseID);
        return _equipBaseRecord;
    }
    private function get equipLevelTable() : IDataTable {
        if (null == _equipLevelTable) _equipLevelTable = _databaseSystem.getTable(KOFTableConstants.EquipUpgrade);
        return _equipLevelTable;
    }
    private function get equipQualityTable() : IDataTable {
        if (null == _equipQualityTable) _equipQualityTable = _databaseSystem.getTable(KOFTableConstants.EquipUpQuality);
        return _equipQualityTable;
    }
    private function get equipAwakenTable() : IDataTable {
        if (null == _equipAwakenTable) _equipAwakenTable = _databaseSystem.getTable(KOFTableConstants.EquipAwaken);
        return _equipAwakenTable;
    }
    public function get equipQualityLevelTable() : IDataTable {
        if (_equipQualityLevelTable == null) _equipQualityLevelTable = _databaseSystem.getTable(KOFTableConstants.EQUIP_QUALITY_LEVEL);
        return _equipQualityLevelTable;
    }

    public static const POS_WEAPON:int = 1;
    public static const POS_CLOTHES:int = 2;
    public static const POS_TROUSERS:int = 3;
    public static const POS_SHOES:int = 4;
    public static const POS_BADGES:int = 5;
    public static const POS_BOOK:int = 6;

    /**装备最大等级*/
    public static const EQUIP_MAX_LEVEL:int = 150;
    /**低级祝福石id*/
    public static const LOW_WISH_STONE_ID:int = 30400001;
    /**中级祝福石id*/
    public static const MIDDLE_WISH_STONE_ID:int = 30400002;
    /**高级祝福石id*/
    public static const HIGH_WISH_STONE_ID:int = 30400003;

    private var _equipBaseRecord:EquipBase;
    private var _equipAwakenTemplateRecord:EquipAwakenTemplate;
    private var _equipLevelUpgradeRecord:EquipUpgrade;
    private var _equipQualitRecord:EquipUpQuality;
    private var _equipAwakenRecord:EquipAwaken;
    private var _equipQualityLevel:EquipQuality;

    private var _equipLevelTable:IDataTable;
    private var _equipQualityTable:IDataTable;
    private var _equipAwakenTable:IDataTable;
    private var _equipQualityLevelTable:IDataTable;

        private var _propertyData:CEquipPropertyData;

    // component
    private var _calcProperty:CHeroEquipPropertyCale;

    }
}
