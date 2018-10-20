//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/22.
 */
package kof.game.player.data.property {

import kof.game.character.property.CBasePropertyData;
import kof.game.character.property.interfaces.ICalcNextProperty;
import kof.game.character.property.interfaces.ICalcProperty;
import kof.game.player.data.CHeroEquipData;


public class CHeroEquipPropertyCale implements ICalcNextProperty, ICalcProperty {
    public function CHeroEquipPropertyCale(equipData:CHeroEquipData) {
        _equipData = equipData;
    }


    // =================================================属性计算================================================================
    // 单个装备
    // 下一级
    public function calcNextLevelProperty() : CBasePropertyData {
        return _calcProperty(_equipData.level+1, _equipData.quality, _equipData.star);
    }
    // 下一品质
    public function calcNextQualityProperty() : CBasePropertyData {
        return _calcProperty(_equipData.level, _equipData.quality+1, _equipData.star);
    }
    // 下一星级
    public function calcNextStarProperty() : CBasePropertyData {
        return _calcProperty(_equipData.level, _equipData.quality, _equipData.star+1);
    }
    // 当前属性
    public function calcProperty() : CBasePropertyData {
        return _calcProperty(_equipData.level, _equipData.quality, _equipData.star);
    }

    private function _calcProperty(level:int, quality:int, star:int) : CBasePropertyData {
        var data:CHeroEquipProperty = new CHeroEquipProperty();
        var upgradeData:UpgradeData = new UpgradeData(_equipData, level, quality, star);
        data.HP = _calcHp(upgradeData);
        data.Attack = _calcAtk(upgradeData);
        data.Defense = _calcDef(upgradeData);
        data.PercentEquipHP = _calcHpPercent(upgradeData);
        data.PercentEquipATK = _calcAtkPercent(upgradeData);
        data.PercentEquipDEF = _calcDefPercent(upgradeData);
        return data;
    }

    private function _calcHp(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initHP, upgradeData.equipBase.templateHP);
    }
    private function _calcAtk(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initATK, upgradeData.equipBase.templateATK);
    }
    private function _calcDef(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initDEF, upgradeData.equipBase.templateDEF);
    }
    private function _calcHpPercent(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initPercentHP, upgradeData.equipBase.templatePercentHP);
    }
    private function _calcAtkPercent(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initPercentATK, upgradeData.equipBase.templatePercentATK);
    }
    private function _calcDefPercent(upgradeData:UpgradeData) : Number {
        return _calcEquipPropertyValue(upgradeData, upgradeData.equipBase.initPercentDEF, upgradeData.equipBase.templatePercentDEF);
    }
    private static function _calcEquipPropertyValue(upgradeData:UpgradeData, baseValue:Number, templeValue:Number) : Number{
        return _calcEquipPropertyValueB(baseValue, templeValue, upgradeData.levelK, upgradeData.qualityK, upgradeData.starK);
    }

    // 计算公式： 装备初始值 + 模板值*星级系数*（品质倍数+等级倍数）
    // 等级倍数 = 当前等级阶段上限倍数-（当前等级等级段上限-当前等级）* 当前等级段每级增加倍数值
    // 计算装备的某个属性值, 通用
    // templeValue 百倍值 templateValue/100 = 正常值
    private static function _calcEquipPropertyValueB(baseValue:Number, templeValue:Number, levelRate:Number, qualityRate:Number, starRate:Number) : Number {
        return baseValue + templeValue/100 * starRate * (qualityRate + levelRate);
    }
    // 计算公式： 装备初始值 + 模板值*星级系数*（品质倍数+等级倍数）
    // 等级倍数 = 当前等级阶段上限倍数-（当前等级等级段上限-当前等级）* 当前等级段每级增加倍数值
//        float starCoefficient = 0.0f;
//        float qualityMultiple = 0.0f;
//        float levelMultiple = 0.0f;//等级倍数 = 当前等级阶段上限倍数-（当前等级等级段上限-当前等级）* 当前等级段每级增加倍数值
//        EquipUpgrade equipUpgrade = ConfigManager.getInstance().getOnlyData(EquipUpgrade.class, levelMappingID);
//        if (equipUpgrade != null){
//            levelMultiple = equipUpgrade.multiple - (equipUpgrade.levelMax - getLevel()) * equipUpgrade.addmultiple;
//        }
//
//        EquipUpQuality equipUpQuality = ConfigManager.getInstance().getOnlyData(EquipUpQuality.class, qualityMappingID);
//        if (equipUpQuality != null) qualityMultiple = equipUpQuality.multiple;
//
//        EquipAwaken equipUpStar = ConfigManager.getInstance().getOnlyData(EquipAwaken.class, starMappingID);
//        if (equipUpStar != null) starCoefficient = equipUpStar.coefficient;
    //
    // calCurrentValue(equipBase.initHP, equipBase.templateHP, starCoefficient, qualityMultiple, levelMultiple)
//      private int calCurrentValue(int initValue, int baseValue, float starCoefficient, float qualityMultiple, float levelMultiple) {
//          return (int) (initValue + baseValue * starCoefficient * (qualityMultiple + levelMultiple));
//      }

//    int max_hp = 0, atk = 0, def = 0, hp_percent = 0, atk_percent = 0, def_percent = 0;
//    for (Equipment equipment : equipments.values()) {
//    max_hp += equipment.getPropertyCompent().getStatValue(PropertyType.MAX_HP.getKey());
//    atk += equipment.getPropertyCompent().getStatValue(PropertyType.ATK.getKey());
//    def += equipment.getPropertyCompent().getStatValue(PropertyType.DEF.getKey());
//
//    hp_percent += equipment.getPropertyCompent().getStatValue(PropertyType.HP_PERCENT.getKey());
//    atk_percent += equipment.getPropertyCompent().getStatValue(
//            PropertyType.ATK_PERCENT.getKey());
//    def_percent += equipment.getPropertyCompent().getStatValue(PropertyType.DEF_PERCENT.getKey());
//}
//
//    atk = (int) (atk * (1 + atk_percent / 10000f));
//    def = (int) (def * (1 + def_percent / 10000f));
//    max_hp = (int) (max_hp * (1 + hp_percent / 10000f));
//
//    propertyCompent.setStatValue(PropertyType.ATK.getKey(), atk);
//    propertyCompent.setStatValue(PropertyType.DEF.getKey(), def);
//    propertyCompent.setStatValue(PropertyType.MAX_HP.getKey(), max_hp);

    private var _equipData:CHeroEquipData;
}
}

import kof.game.player.data.CHeroEquipData;
import kof.table.EquipAwaken;
import kof.table.EquipBase;
import kof.table.EquipUpQuality;
import kof.table.EquipUpgrade;

class UpgradeData {
    public function UpgradeData(equipData:CHeroEquipData, level:int, quality:int, star:int) {
        equipBase = equipData.equipBaseRecord;
        if (equipData.level == level) {
            levelK = getLevelPropertyK(equipData.levelUpRecord, level);
        } else {
            var levelRecord:EquipUpgrade = equipData.getLevelUpData(level);
            levelK = getLevelPropertyK(levelRecord, level);

        }
        if (equipData.quality == quality) {
            qualityK = getQualityPropertyK(equipData.qualityUpRecored);
        } else {
            var qualityRecord:EquipUpQuality = equipData.getQualityUpRecord(quality);
            qualityK = getQualityPropertyK(qualityRecord);
        }
        if (equipData.star == star) {
            starK = getStarPropertyK(equipData.equipAwakenRecord);
        } else {
            var awakenRecord:EquipAwaken = equipData.getEquipAwakenRecord(star);
            starK = getStarPropertyK(awakenRecord);
        }
    }
    private function getLevelPropertyK(levelUpRecord:EquipUpgrade, level:int) : Number {
        return levelUpRecord.multiple - (levelUpRecord.levelMax - level) * levelUpRecord.addmultiple;
    }
    private function getQualityPropertyK(qualityUpRecored:EquipUpQuality) : Number { return qualityUpRecored.multiple; }
    private function getStarPropertyK(equipAwakenRecord:EquipAwaken) : Number { return equipAwakenRecord.coefficient; }

    public var equipBase:EquipBase;
    public var levelK:Number;
    public var qualityK:Number;
    public var starK:Number;

}

