//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.control {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.IDatabase;
import kof.game.common.view.control.CControlBase;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.CStreetFighterNetHandler;
import kof.game.streetFighter.CStreetFighterSystem;
import kof.game.streetFighter.CStreetFighterUIHandler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterHeroHpData;
import kof.table.InstanceType;
import kof.table.StreetFighterReward;

public class CStreetFighterControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CStreetFighterUIHandler {
        return _wnd.viewManagerHandler as CStreetFighterUIHandler;
    }
    [Inline]
    public function get system() : CStreetFighterSystem {
        return _system as CStreetFighterSystem;
    }
    [Inline]
    public function get netHandler() : CStreetFighterNetHandler {
        return (_system as CStreetFighterSystem).netHandler;
    }
    [Inline]
    public function get streetFighterData() : CStreetFighterData {
        return (_system as CStreetFighterSystem).data;
    }
    [Inline]
    public function get playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

    public function bestEmbattleReqeust() : void {
        if (!(streetFighterData.alreadyStartFight)) {
            var embattleSystem:CEmbattleSystem = _system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            embattleSystem.requestBestEmbattle(system.embattleType);
        }
    }

    public function get embattleMaxCount() : int {
        if (_embattleMaxCount != -1) {
            return _embattleMaxCount;
        }
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pTable : IDataTable = pDatabase.getTable( KOFTableConstants.INSTANCE_TYPE );
        var instanceType : InstanceType  = pTable.findByPrimaryKey( EInstanceType.TYPE_STREET_FIGHTER );
        return instanceType.embattleNumLimit;
    }
    private var _embattleMaxCount:int = -1;

    public function get embattleMinCount() : int {
        if (_embattleMinCount != -1) {
            return _embattleMinCount;
        }
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pTable : IDataTable = pDatabase.getTable( KOFTableConstants.INSTANCE_TYPE );
        var instanceType : InstanceType  = pTable.findByPrimaryKey( EInstanceType.TYPE_STREET_FIGHTER );
        return instanceType.embattleNumMin;
    }
    private var _embattleMinCount:int = -1;


    public function needRefight() : Boolean {
        if (!streetFighterData.alreadyStartFight) {
            return false;
        }

        var embattleCount:int = playerData.embattleManager.getHeroCountByType(EInstanceType.TYPE_STREET_FIGHTER);
        var needResetAlvieCount:int = embattleCount/2; // 小于等于这个数。需要重置

        var myHpList:Array = streetFighterData.myHeroHpList.list;
        var deadCount:int = 0;
        for each (var hpData:CStreetFighterHeroHpData in myHpList) {
            if (hpData && hpData.HP == 0) {
                deadCount++;
            }
        }
        var aliveCount:int = embattleCount - deadCount;
        var ret:Boolean = aliveCount <= needResetAlvieCount;
        return ret;
    }
    public function isAllDead() : Boolean {
        if (!streetFighterData.alreadyStartFight) {
            return false;
        }

        var embattleCount:int = playerData.embattleManager.getHeroCountByType(EInstanceType.TYPE_STREET_FIGHTER);
        var myHpList:Array = streetFighterData.myHeroHpList.list;
        var deadCount:int = 0;
        for each (var hpData:CStreetFighterHeroHpData in myHpList) {
            if (hpData && hpData.HP == 0) {
                deadCount++;
            }
        }
        var aliveCount:int = embattleCount - deadCount;
        var ret:Boolean = aliveCount <= 0;
        return ret;
    }

    public function canGetReward(record:StreetFighterReward) : Boolean {
        var curValue:int = streetFighterData.getCurValueByType(record.type);
        var targetValue:int = record.param[0];
        var finish:Boolean = curValue >= targetValue;
        if (finish) {
            var hasReward:Boolean = streetFighterData.rewardData.hasRewarded( record.ID );
            return !hasReward;
        }
        return false;
    }
}
}
