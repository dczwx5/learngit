//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/23.
 */
package kof.game.cultivate.imp {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.CResultRewardInfo;
import kof.game.cultivate.CCultivateSystem;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.data.cultivate.CCultivateLevelListData;
import kof.game.cultivate.data.cultivate.CCultivateResultData;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;

public class CCultivateResultDataProvider extends CAbstractHandler{
    public function CCultivateResultDataProvider()
    {
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

    public function getResultData() : CPVPResultData {
        var pPlayerSystem : CPlayerSystem = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem);
        var pPlayerData : CPlayerData = pPlayerSystem.playerData;
        var pvpResultData:CPVPResultData = new CPVPResultData();
        pvpResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        var obj:Object = {};
        obj[CPVPResultData.Result] = _cultivateResultData.win;
        obj[CPVPResultData.InstanceType] = EInstanceType.TYPE_CLIMP_CULTIVATE;

        // 奖励数据
        var rewardArr:Array = [];
        for each(var rewardInfo:Object in _cultivateResultData.rewardList)
        {
            var resultRewardInfo:CResultRewardInfo = new CResultRewardInfo();
            resultRewardInfo.itemId = rewardInfo["ID"];
            resultRewardInfo.itemNum = rewardInfo["num"];
            rewardArr.push(resultRewardInfo);
        }
        obj[CPVPResultData.Rewards] = rewardArr;

        // 己方数据
        obj[CPVPResultData.SelfRoleName] = pPlayerData.teamData.name;
//        obj[SelfValue] = redInfo["curRank"];
//        obj[SelfChangeValue] = redInfo["rankChange"];

        var selfHeroArr:Array = [];
        var embatleListData:CEmbattleListData = pPlayerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        for (var i:int = 0; i < embatleListData.list.length; i++) {
            var emData:CEmbattleData = embatleListData.list[i];
            var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = emData.prosession;
            selfHeroArr.push(resultHeroInfo);
        }
        obj[CPVPResultData.SelfHeroList] = selfHeroArr;

        // 通关后打的关是上一关
        var cultivateLevelData:CCultivateLevelData;
        var isWin:Boolean = _system.climpData.cultivateData.resultData.win > 0;
        var cultivateLevelList:CCultivateLevelListData = _system.climpData.cultivateData.levelList;
        if (isWin) {
            if (cultivateLevelList.curLevelData.isLastLevel && _system.climpData.cultivateData.resultData.index == 3) {
                cultivateLevelData = cultivateLevelList.curLevelData; // 最后一次通关
            } else {
                cultivateLevelData = cultivateLevelList.getLevel(cultivateLevelList.curLevelData.layer - 1);
            }
        } else {
            cultivateLevelData = cultivateLevelList.curLevelData;
        }

        // 敌方数据
        if(cultivateLevelData) {
            var heroDataList : Array = cultivateLevelData.getHeroListData();

            if ( heroDataList && heroDataList.length ) {
                obj[CPVPResultData.EnemyRoleName] = cultivateLevelData.name;
                var enemyHeroArr:Array = [];
                for each(var heroData:CPlayerHeroData in heroDataList)
                {
                    resultHeroInfo = new CResultHeroInfo();
                    resultHeroInfo.heroId = heroData.prototypeID;
                    enemyHeroArr.push(resultHeroInfo);
                }

                obj[CPVPResultData.EnemyHeroList] = enemyHeroArr;
            }
        }

        pvpResultData.updateDataByData(obj);
        return pvpResultData;
    }

    private function get _system() : CCultivateSystem {
        return system as CCultivateSystem;
    }

    private function get _cultivateResultData():CCultivateResultData
    {
        return _system.climpData.cultivateData.resultData;
    }

}
}
