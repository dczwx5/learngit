//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/10.
 */
package kof.game.cultivate.imp {

import kof.framework.IDatabase;
import kof.game.cultivate.CCultivateSystem;
import kof.framework.CAbstractHandler;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.instance.enum.EInstanceType;
import kof.game.loading.CPVPLoadingData;
import kof.game.loading.CPVPLoadingHeadData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;

public class CCultivateLoadingDataProvider extends CAbstractHandler {
    public function CCultivateLoadingDataProvider() {
        clear();
    }
    public override function dispose():void {
        super.dispose();

        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();

        return ret;
    }

    /**
     * 双方信息
     * @return
     */
    public function getLoadingData() : CPVPLoadingData {
        var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        var pPlayerData:CPlayerData = pPlayerSystem.playerData;

        // 自己的信息
        var selfLoadingHeadData:CPVPLoadingHeadData;
        selfLoadingHeadData = new CPVPLoadingHeadData();
        selfLoadingHeadData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        var embatleListData:CEmbattleListData = pPlayerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var embattleBattle:int = pPlayerData.embattleManager.getPowerByEmbattleType(EInstanceType.TYPE_CLIMP_CULTIVATE);

        var heroData:CPlayerHeroData;
        var selfHeroIdList:Array = new Array();
        var powerFullHeroData:CPlayerHeroData; // 最强战力格斗家
        for (var i:int = 0; i < embatleListData.list.length; i++) {
            var emData:CEmbattleData = embatleListData.list[i];
            heroData = pPlayerData.heroList.getHero(emData.prosession);
            selfHeroIdList.push(heroData.prototypeID);
            if (!powerFullHeroData) {
                powerFullHeroData = heroData;
            } else {
                if (heroData.battleValue > powerFullHeroData.battleValue) {
                    powerFullHeroData = heroData;
                }
            }
        }

        var selfDataObject:Object = CPVPLoadingHeadData.createObjectData(pPlayerData.teamData.useHeadID, powerFullHeroData.star, powerFullHeroData.quality, pPlayerData.teamData.name, "", "", "", "");
        selfLoadingHeadData.updateDataByData(selfDataObject);

        // enemy info
        var enemyLoadingHeadData:CPVPLoadingHeadData;
        var enemyHeroIdList:Array;

        var cultivateLevelData:CCultivateLevelData = (_system as CCultivateSystem).climpData.cultivateData.levelList.curLevelData;
        if(cultivateLevelData)
        {
            var heroDataList:Array = cultivateLevelData.getHeroListData();

            if(heroDataList && heroDataList.length)
            {
                // 头部
                heroData = heroDataList[0] as CPlayerHeroData;
                enemyLoadingHeadData = new CPVPLoadingHeadData();
                enemyLoadingHeadData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                var enemyDataObject:Object = CPVPLoadingHeadData.createObjectData(heroData.prototypeID, heroData.star, heroData.quality,
                        cultivateLevelData.name, "", "", "", "");
                enemyLoadingHeadData.updateDataByData(enemyDataObject);

                // 列表
                enemyHeroIdList = [];
                for each(var hero:CPlayerHeroData in heroDataList)
                {
                    enemyHeroIdList.push(hero.prototypeID);
                }
            }
        }

        if(selfLoadingHeadData && enemyLoadingHeadData && selfHeroIdList && enemyHeroIdList) {
            var loadingData:CPVPLoadingData = new CPVPLoadingData();
            loadingData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            var loadingDataObject:Object = CPVPLoadingData.createObjectData(selfLoadingHeadData, enemyLoadingHeadData, selfHeroIdList, enemyHeroIdList);
            loadingData.updateDataByData(loadingDataObject);
        }
        return loadingData;
    }

    [Inline]
    private function get _system() : CCultivateSystem {
        return system as CCultivateSystem;
    }
}
}
