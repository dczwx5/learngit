//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/29.
 */
package kof.game.peakGame.imp {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.CResultRewardInfo;
import kof.game.common.view.resultWin.CSegmentData;
import kof.game.common.view.resultWin.EPVPResultType;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameSettlementData;
import kof.game.peakGame.enum.EPeakResultType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroListData;
import kof.table.PeakScoreLevel;

public class CPeakResultDataProvider extends CAbstractHandler{
    public function CPeakResultDataProvider() {
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
        var peakResultData:CPeakGameSettlementData = _system.peakGameData.settlementData;

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
        obj[CPVPResultData.InstanceType] = _system.instanceType;

        // 奖励数据
        var rewardArr:Array = [];
        for each(var rewardInfo:Object in peakResultData.rewards) {
            var resultRewardInfo:CResultRewardInfo = new CResultRewardInfo();
            resultRewardInfo.itemId = rewardInfo["ID"];
            resultRewardInfo.itemNum = rewardInfo["num"];
            rewardArr.push(resultRewardInfo);
        }
        obj[CPVPResultData.Rewards] = rewardArr;

        // 己方数据
        obj[CPVPResultData.SelfRoleName] = pPlayerData.teamData.name;

        var selfHeroArr:Array = [];
        var embatleListData:CEmbattleListData = pPlayerData.embattleManager.getByType(_system.embattleType);
        for (var i:int = 0; i < embatleListData.list.length; i++) {
            var emData:CEmbattleData = embatleListData.list[i];
            var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
            resultHeroInfo.heroId = emData.prosession;
            selfHeroArr.push(resultHeroInfo);
        }
        obj[CPVPResultData.SelfHeroList] = selfHeroArr;

        // 敌方数据
        var pEnmeyHeroListData:CPlayerHeroListData = _system.peakGameData.matchData.heroList;
        if ( pEnmeyHeroListData && pEnmeyHeroListData.list && pEnmeyHeroListData.list.length > 0 ) {
            obj[CPVPResultData.EnemyRoleName] = _system.peakGameData.matchData.enemyName;
            var enemyHeroArr:Array = [];
            for each(var heroData:CPlayerHeroData in pEnmeyHeroListData.list) {
                resultHeroInfo = new CResultHeroInfo();
                resultHeroInfo.heroId = heroData.prototypeID;
                enemyHeroArr.push(resultHeroInfo);
            }
            obj[CPVPResultData.EnemyHeroList] = enemyHeroArr;
        }

        // 额外奖励
        var externsReward:Array = new Array();
        if (peakResultData.noDamageToWin) {
            externsReward.push(0);
        }
        if (peakResultData.fullWin) {
            externsReward.push(1);
        }
        if (peakResultData.comboHitMan) {
            externsReward.push(2);
        }

        obj[CPVPResultData.ExtraRewards] = externsReward;

        // 两边的段位
        var selfLevelData:CSegmentData = new CSegmentData();
        var selfLevelScoreRecord:PeakScoreLevel = _system.peakGameData.getLevelRecordByID(peakResultData.scoreLevelID);
        var selfObjectData:Object = CSegmentData.createObjectData(selfLevelScoreRecord.levelId, selfLevelScoreRecord.subLevelId, selfLevelScoreRecord.levelName, true);
        selfLevelData.updateDataByData(selfObjectData);
        obj[CPVPResultData.SelfSegment] = selfLevelData;


        var enemyLevelData:CSegmentData = new CSegmentData();
        var enemyLevelScoreRecord:PeakScoreLevel = _system.peakGameData.getLevelRecordByID(peakResultData.enemyScoreLevelID);
        var enemyObjectData:Object = CSegmentData.createObjectData(enemyLevelScoreRecord.levelId, enemyLevelScoreRecord.subLevelId, enemyLevelScoreRecord.levelName, true);
        enemyLevelData.updateDataByData(enemyObjectData);
        obj[CPVPResultData.EnemySegment] = enemyLevelData;

        // 变化 积分
        obj[CPVPResultData.SelfChangeValue] = peakResultData.updateScore;
        obj[CPVPResultData.EnemyChangeValue] = peakResultData.enemyUpdateScore;

        // 当前积分
        obj[CPVPResultData.SelfValue] = _system.peakGameData.score;

        obj[CPVPResultData.FightUUID] = _peakResultData.fightUUID;

        obj[CPVPResultData.SCORE_ACTIVITY_START] = _peakResultData.scoreActivityStart;
        obj[CPVPResultData.SCORE_ACTIVITY_MULTIPLE] = _peakResultData.scoreActivityBaseMultiple;


        pvpResultData.updateDataByData(obj);
        return pvpResultData;
    }

    private function get _system() : CPeakGameSystem {
        return system as CPeakGameSystem;
    }

    private function get _peakResultData() : CPeakGameSettlementData {
        return _system.peakGameData.settlementData;
    }

}
}
