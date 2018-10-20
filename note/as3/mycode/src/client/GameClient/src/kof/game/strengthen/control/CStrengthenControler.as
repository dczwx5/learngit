//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.control {

import kof.framework.IDatabase;
import kof.game.common.view.control.CControlBase;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEquipPropertyData;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.strengthen.CStrengthenSystem;
import kof.game.strengthen.CStrengthenUIHandler;
import kof.game.strengthen.data.CStrengthenData;
import kof.game.strengthen.enum.EStrengthenBattleValueGrewType;

public class CStrengthenControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CStrengthenUIHandler {
        return _wnd.viewManagerHandler as CStrengthenUIHandler;
    }
    [Inline]
    public function get system() : CStrengthenSystem {
        return _system as CStrengthenSystem;
    }
    [Inline]
    public function get strengthenData() : CStrengthenData {
        return (_system as CStrengthenSystem).data;
    }
    [Inline]
    public function get playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

    public function getBattleValueByType(type:int) : int {
        var ret:int = 0;
        var temp:int;
        var heroData:CPlayerHeroData;
        var heroList:Array = playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_MAIN);
        switch (type) {
            case EStrengthenBattleValueGrewType.TYPE_TEAM_LEVEL:
                for each (heroData in heroList) {
                    if (heroData) {
                        temp = strengthenData.calcBattleValueScore(type, heroData.level);
                        ret += temp;
                    }
                }
                break;
            case EStrengthenBattleValueGrewType.TYPE_EQUIP:
                    for each (heroData in heroList) {
                        if (heroData) {
                            var equipDataList:Array = heroData.equipList.list;
                            var totalPropertyData:CEquipPropertyData = new CEquipPropertyData();
                            totalPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                            for each (var equipData:CHeroEquipData in equipDataList) {
                                totalPropertyData.add(equipData.propertyData);
                            }
                            totalPropertyData.HP = totalPropertyData.HP * (1 + (totalPropertyData.PercentEquipHP/10000));
                            totalPropertyData.Attack = totalPropertyData.Attack * (1 + (totalPropertyData.PercentEquipATK/10000));
                            totalPropertyData.Defense = totalPropertyData.Defense * (1 + (totalPropertyData.PercentEquipDEF/10000));
                            temp = totalPropertyData.getBattleValue();
                            ret += temp;
                        }
                    }
                break;
            case EStrengthenBattleValueGrewType.TYPE_QUALITY:
                for each (heroData in heroList) {
                    if (heroData) {
                        temp = strengthenData.calcBattleValueScore(type, heroData.quality);
                        ret += temp;
                    }
                }
                break;
            case EStrengthenBattleValueGrewType.TYPE_SKILL:
                for each (heroData in heroList) {
                    if (heroData) {
                        var skillList:Array = heroData.skillList.list;
                        for each (var skillData:CSkillData in skillList) {
                            if (skillData) {
                                temp = strengthenData.calcBattleValueScore(type, skillData.skillLevel);
                                ret += temp;
                            }
                        }
                    }
                }
                break;
            case EStrengthenBattleValueGrewType.TYPE_STAR:
                for each (heroData in heroList) {
                    if (heroData) {
                        temp = strengthenData.calcBattleValueScore(type, heroData.star);
                        ret += temp;
                    }
                }
                break;
            case EStrengthenBattleValueGrewType.TYPE_ARTIFACT:
                temp = playerData.artifactProprtyData.getBattleValue();
                ret += temp;
                break;
            case EStrengthenBattleValueGrewType.TYPE_TALENT:
                temp = playerData.talentPropertyData.getBattleValue();
                ret += temp;
                break;
            case EStrengthenBattleValueGrewType.TYPE_HERO_COUNT:
                var allHeroList:Array = playerData.heroList.list;
                var heroCount:int = 0;
                for each (heroData in allHeroList) {
                    if (heroData && heroData.hasData) {
                        heroCount++;
                    }
                }
                temp = strengthenData.calcBattleValueScore(type, heroCount);
                ret += temp;
                break;
        }

        return ret;
    }
}
}
