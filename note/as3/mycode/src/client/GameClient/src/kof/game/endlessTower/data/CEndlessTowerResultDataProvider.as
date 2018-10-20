//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/13.
 */
package kof.game.endlessTower.data {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.CResultRewardInfo;
import kof.game.endlessTower.CEndlessTowerManager;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.data.CRewardData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;

public class CEndlessTowerResultDataProvider extends CAbstractHandler {
    public function CEndlessTowerResultDataProvider()
    {
        super();
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

    public function getResultData() : CPVPResultData
    {
        var pvpResultData:CPVPResultData = new CPVPResultData();
        pvpResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        var resultData:CEndlessTowerResultData = getEndlessTowerResultData();

        if(resultData)
        {
            var obj:Object = {};
            obj[CPVPResultData.Result] = resultData.isWin;
            obj[CPVPResultData.InstanceType] = EInstanceType.TYPE_ENDLESS_TOWER;

            // 奖励数据
            var rewardArr:Array = [];
            if(resultData.rewardList && resultData.rewardList.itemList)
            {
                for each(var rewardInfo:CRewardData in resultData.rewardList.itemList)
                {
                    var resultRewardInfo:CResultRewardInfo = new CResultRewardInfo();
                    resultRewardInfo.itemId = rewardInfo.ID;
                    resultRewardInfo.itemNum = rewardInfo.num;
                    rewardArr.push(resultRewardInfo);
                }

                for each(rewardInfo in resultData.rewardList.currencyList)
                {
                    resultRewardInfo = new CResultRewardInfo();
                    resultRewardInfo.itemId = rewardInfo.ID;
                    resultRewardInfo.itemNum = rewardInfo.num;
                    rewardArr.push(resultRewardInfo);
                }
            }

            obj[CPVPResultData.Rewards] = rewardArr;

            // 己方数据
            var pPlayerSystem : CPlayerSystem = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem);
            var pPlayerData : CPlayerData = pPlayerSystem.playerData;
            obj[CPVPResultData.SelfRoleName] = pPlayerData.teamData.name;

            var selfHeroArr:Array = [];
            var embatleListData:CEmbattleListData = pPlayerData.embattleManager.getByType(EInstanceType.TYPE_ENDLESS_TOWER);
            for (var i:int = 0; i < embatleListData.list.length; i++)
            {
                var emData:CEmbattleData = embatleListData.list[i];
                var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
                resultHeroInfo.heroId = emData.prosession;
                selfHeroArr.push(resultHeroInfo);
            }
            obj[CPVPResultData.SelfHeroList] = selfHeroArr;


            // 敌方数据
            var heroIdList : Array = resultData.heroIdList;

            if(heroIdList && heroIdList.length)
            {
                var heroName:String = (pPlayerSystem.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler).getHeroName(heroIdList[0]);
                obj[CPVPResultData.EnemyRoleName] = resultData.robotName;

                var enemyHeroArr:Array = [];
                for each(var heroId:int in heroIdList)
                {
                    resultHeroInfo = new CResultHeroInfo();
                    resultHeroInfo.heroId = heroId;
                    enemyHeroArr.push(resultHeroInfo);
                }

                obj[CPVPResultData.EnemyHeroList] = enemyHeroArr;
            }

            obj[CPVPResultData.IsFirstPass] = resultData.isFirstPass;

            pvpResultData.updateDataByData(obj);
        }

        return pvpResultData;
    }

    private function getEndlessTowerResultData():CEndlessTowerResultData
    {
        return (system.getHandler(CEndlessTowerManager) as CEndlessTowerManager).resultData;
    }
}
}
