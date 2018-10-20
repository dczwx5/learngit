//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/1/3.
 */
package kof.game.player.data.property {

import kof.game.character.property.CBasePropertyData;
import kof.game.character.property.interfaces.ICalcNextProperty;
import kof.game.character.property.interfaces.ICalcProperty;
import kof.game.player.data.CPlayerHeroData;
import kof.table.PlayerStarConsume;

public class CPlayerHeroPropertyCale implements ICalcProperty, ICalcNextProperty {
    public function CPlayerHeroPropertyCale(heroData:CPlayerHeroData) {
        _heroData = heroData;
    }

    // =================================================属性计算================================================================
    //指定等级属性
    public function calcSpecialLevelProperty(lv:int) : CBasePropertyData {
        return _calcProperty(lv, _heroData.quality, _heroData.star);
    }
    // 下一级
    public function calcNextLevelProperty() : CBasePropertyData {
        return _calcProperty(_heroData.level+1, _heroData.quality, _heroData.star);
    }
    // 下一品质
    public function calcNextQualityProperty() : CBasePropertyData {
        return _calcProperty(_heroData.level, _heroData.quality+1, _heroData.star);
    }
    // 下一星级
    public function calcNextStarProperty() : CBasePropertyData {
        return _calcProperty(_heroData.level, _heroData.quality, _heroData.star+1);
    }
    // 当前属性
    public function calcProperty() : CBasePropertyData {
        return _calcProperty(_heroData.level, _heroData.quality, _heroData.star);
    }
    private function _calcProperty(level:int, quality:int, star:int): CBasePropertyData {
        var data:CPlayerHeroProperty = new CPlayerHeroProperty();
        var upgradeData:UpgradeData = new UpgradeData(_heroData, level, quality, star);
        data.HP = _calcHp(upgradeData);
        data.Attack = _calcAtk(upgradeData);
        data.Defense = _calcDef(upgradeData);

        // 装备 属性加上
        var equipData:CHeroEquipProperty = _heroData.equipList.getAllEquipProperty();
        data.add(equipData);

        return data;
    }

    private function _calcAtk(upgradeData:UpgradeData) : Number {

        return _calcPropertyValue(upgradeData, upgradeData.playerBase.Attack, upgradeData.playerBase.templateATK);
    }
    private function _calcHp(upgradeData:UpgradeData) : Number {
        return _calcPropertyValue(upgradeData, upgradeData.playerBase.HP, upgradeData.playerBase.templateHP);
    }
    private function _calcDef(upgradeData:UpgradeData) : Number {
        return _calcPropertyValue(upgradeData, upgradeData.playerBase.Defense, upgradeData.playerBase.templateDEF);
    }

    private function _calcPropertyValue(upgradeData:UpgradeData, baseValue:Number, templeValue:Number) : Number{
        var baseTemplateValue:Number = templeValue/100;
        var starRateRecord:PlayerStarConsume = upgradeData.starRate;
        var growValue:Number = baseTemplateValue * starRateRecord.starConsumeRatio * (upgradeData.levelRate + upgradeData.qualityRate + starRateRecord.starMultiple);
        var ret:Number = baseValue + growValue;
        return ret;
    }

    private var _heroData:CPlayerHeroData;
}
}

import kof.game.player.data.CPlayerHeroData;
import kof.table.PlayerBasic;
import kof.table.PlayerLevelConsume;
import kof.table.PlayerQualityConsume;
import kof.table.PlayerStarConsume;

class UpgradeData {
    public function UpgradeData(heroData:CPlayerHeroData, level:int, quality:int, star:int) {
        _pHeroData = heroData;
        playerBase = heroData.playerBasic;
        this.level = level;
        this.quality = quality;
        this.star = star;

    }

    public function get levelRate() : Number {
        var consume:PlayerLevelConsume = _pHeroData.getLevelConsume(level);
        return consume.consumLevelRatio;
    }

    public function get qualityRate() : Number {
        var consume:PlayerQualityConsume = _pHeroData.getQualityConsume(quality);
        return consume.qualityMultiple;
    }

    public function get starRate() : PlayerStarConsume {
        var consume:PlayerStarConsume = _pHeroData.getStarConsume(star);
        return consume;
    }

    public var playerBase:PlayerBasic;
    public var level:int;
    public var quality:int;
    public var star:int;

    private var _pHeroData:CPlayerHeroData;

}

