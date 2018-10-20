//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/24.
 */
package kof.game.arena.data {

import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.CResultRewardInfo;
import kof.game.instance.enum.EInstanceType;

/**
 * 竞技场战斗结果数据
 */
public class CArenaResultData extends CPVPResultData {
    public function CArenaResultData()
    {
        super();
    }

    public function convertData(serverData:Object):void
    {
        var obj:Object = new Object();
        obj[Result] = serverData["result"];
        obj[InstanceType] = EInstanceType.TYPE_ARENA;

        // 奖励数据
        var rewardArr:Array = [];
        for each(var rewardInfo:Object in serverData["rewards"])
        {
            var resultRewardInfo:CResultRewardInfo = new CResultRewardInfo();
            resultRewardInfo.itemId = rewardInfo["ID"];
            resultRewardInfo.itemNum = rewardInfo["num"];
            rewardArr.push(resultRewardInfo);
        }
        obj[Rewards] = rewardArr;

        // 己方数据
        var redInfo:Object = serverData["redInfo"];
        obj[SelfRoleName] = redInfo["name"];
        obj[SelfValue] = redInfo["curRank"];
        obj[SelfChangeValue] = redInfo["rankChange"];

        var selfHeroArr:Array = [];
        for each(var info:Object in redInfo["heroesInfo"])
        {
            var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = info["heroId"];
            resultHeroInfo.battleValue = info["battleValue"];
            selfHeroArr.push(resultHeroInfo);
        }
        obj[SelfHeroList] = selfHeroArr;

        // 敌方数据
        var blueInfo:Object = serverData["blueInfo"];
        obj[EnemyRoleName] = blueInfo["name"];
        obj[EnemyValue] = blueInfo["curRank"];
        obj[EnemyChangeValue] = blueInfo["rankChange"];

        var enemyHeroArr:Array = [];
        for each(info in blueInfo["heroesInfo"])
        {
            resultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = info["heroId"];
            resultHeroInfo.battleValue = info["battleValue"];
            enemyHeroArr.push(resultHeroInfo);
        }
        obj[EnemyHeroList] = enemyHeroArr;

        this.updateDataByData(obj);
    }
}
}


