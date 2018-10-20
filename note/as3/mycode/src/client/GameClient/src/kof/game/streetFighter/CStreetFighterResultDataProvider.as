//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.common.view.resultWin.CResultHeroInfo;
import kof.game.common.view.resultWin.EPVPResultType;
import kof.game.instance.enum.EInstanceType;
import kof.game.peakGame.enum.EPeakResultType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.data.settlement.CStreetFighterSettlementData;

public class CStreetFighterResultDataProvider extends CAbstractHandler{
    public function CStreetFighterResultDataProvider() {
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
        var peakResultData:CStreetFighterSettlementData = _system.data.settlementData;

        // 胜负
        var tempResult:int = 0;
        switch (peakResultData.result) {
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
        obj[CPVPResultData.InstanceType] = EInstanceType.TYPE_STREET_FIGHTER;

        // 己方数据
        obj[CPVPResultData.SelfRoleName] = pPlayerData.teamData.name;

        var selfHeroArr:Array = [];
        var resultHeroInfo:CResultHeroInfo = new CResultHeroInfo();
        resultHeroInfo.heroId = _system.data.loadingData.fightHeroID;
        selfHeroArr.push(resultHeroInfo);
        obj[CPVPResultData.SelfHeroList] = selfHeroArr;

        // 敌方数据
        var enemyHeroData:CPlayerHeroData = _system.data.loadingData.enemyHeroData;
        obj[CPVPResultData.EnemyRoleName] = _system.data.loadingData.enemyName;
        var enemyHeroArr:Array = [];
        resultHeroInfo = new CResultHeroInfo();
        resultHeroInfo.heroId = enemyHeroData.prototypeID;
        enemyHeroArr.push(resultHeroInfo);
        obj[CPVPResultData.EnemyHeroList] = enemyHeroArr;


        // 变化 积分
        obj[CPVPResultData.SelfChangeValue] = peakResultData.updateScore;
        obj[CPVPResultData.EnemyChangeValue] = peakResultData.enemyUpdateScore;

        // 当前积分
        obj[CPVPResultData.SelfValue] = _system.data.score;
        obj[CPVPResultData.FightUUID] = peakResultData.fightUUID;

        pvpResultData.updateDataByData(obj);
        return pvpResultData;
    }

    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }

    private function get _resultData() : CStreetFighterSettlementData {
        return _system.data.settlementData;
    }

}
}
