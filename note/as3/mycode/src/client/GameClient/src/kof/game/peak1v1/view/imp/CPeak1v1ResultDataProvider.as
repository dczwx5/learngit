//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/30.
 */
package kof.game.peak1v1.view.imp {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.hero.CCommonHeroData;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.CResultRewardInfo;
import kof.game.common.view.resultWin.EPVPResultType;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.data.CRewardData;
import kof.game.peak1v1.CPeak1v1System;
import kof.game.peak1v1.data.CPeak1v1ResultData;
import kof.game.peakGame.enum.EPeakResultType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;

public class CPeak1v1ResultDataProvider extends CAbstractHandler{
    public function CPeak1v1ResultDataProvider() {
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
        var peakResultData:CPeak1v1ResultData = _peakResultData;

        // 胜负
        var tempResult:int = 0;
        switch (_peakResultData.result) {
            case EPeakResultType.LOSE :
                tempResult = EPVPResultType.FAIL;
                break;
            case EPeakResultType.WIN :
                tempResult = EPVPResultType.WIN;
                break;
            case EPeakResultType.TIE :
                tempResult = EPVPResultType.TIE; // 没平局
                break;
            case EPeakResultType.FULL_WIN :
                tempResult = EPVPResultType.FULL_WIN;
                break;
        }
        var obj:Object = {};
        obj[CPVPResultData.Result] = tempResult;
        obj[CPVPResultData.InstanceType] = EInstanceType.TYPE_PEAK_1V1;

        // 奖励数据
        var rewardArr:Array = [];
        for each(var rewardInfo:CRewardData in peakResultData.rewardData.list) {
            var resultRewardInfo:CResultRewardInfo = new CResultRewardInfo();
            resultRewardInfo.itemId = rewardInfo.ID;
            resultRewardInfo.itemNum = rewardInfo.num;
            rewardArr.push(resultRewardInfo);
        }
        obj[CPVPResultData.Rewards] = rewardArr;

        // 己方数据
        obj[CPVPResultData.SelfRoleName] = pPlayerData.teamData.name;

        var selfHeroArr:Array = [];
        var embatleListData:CEmbattleListData = pPlayerData.embattleManager.getByType(EInstanceType.TYPE_PEAK_1V1);
        for (var i:int = 0; i < embatleListData.list.length; i++) {
            var emData:CEmbattleData = embatleListData.list[i];
            var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = emData.prosession;
            selfHeroArr.push(resultHeroInfo);
        }
        obj[CPVPResultData.SelfHeroList] = selfHeroArr;

        // 敌方数据 只有一个
        var pEnemyHeroData:CCommonHeroData = _system.data.matchData.enemyHeroData;
        if (pEnemyHeroData) {
            obj[CPVPResultData.EnemyRoleName] = _system.data.matchData.enemyName;
            var enemyHeroArr:Array = [];
            resultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = pEnemyHeroData.prototypeID;
            enemyHeroArr.push(resultHeroInfo);
            obj[CPVPResultData.EnemyHeroList] = enemyHeroArr;
        }

        // 变化 积分
        obj[CPVPResultData.SelfChangeValue] = peakResultData.updateScore;
        obj[CPVPResultData.EnemyChangeValue] = peakResultData.enemyUpdateScore;

        // 当前积分
        obj[CPVPResultData.SelfValue] = _system.data.score;

        obj[CPVPResultData.AlwaysWinScore] = _system.data.resultData.alwaysWinScore;// 连胜积分
        obj[CPVPResultData.RebelKillScore] = _system.data.resultData.rebelKillScore;// 反杀积分
        obj[CPVPResultData.DamageScore] = _system.data.resultData.damageScore;// 伤害积分

        obj[CPVPResultData.FightUUID] = peakResultData.fightUUID;// 战斗唯一ID

        pvpResultData.updateDataByData(obj);
        return pvpResultData;
    }

    private function get _system() : CPeak1v1System{
        return system as CPeak1v1System;
    }

    private function get _peakResultData() : CPeak1v1ResultData {
        return _system.data.resultData;
    }

}
}
