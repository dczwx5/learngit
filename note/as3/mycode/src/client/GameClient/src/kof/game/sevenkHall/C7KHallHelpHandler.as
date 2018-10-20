//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/18.
 */
package kof.game.sevenkHall {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CRewardUtil;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.item.data.CRewardListData;
import kof.game.platform.sevenK.C7KData;
import kof.game.platform.sevenK.E7kVipType;
import kof.game.player.CPlayerSystem;
import kof.game.sevenkHall.data.C7K7KRewardInfoData;
import kof.game.sevenkHall.data.C7KLevelRewardData;
import kof.table.LevelUpReward7k7k;
import kof.table.SevenKRewardConfig;

public class C7KHallHelpHandler extends CAbstractHandler {
    public function C7KHallHelpHandler()
    {
        super();
    }

    public function hasRewardToTake():Boolean
    {
        return hasEveryDayRewards() || hasNewRewards() || hasLevelRewards();
    }

    public function hasEveryDayRewards():Boolean
    {
        if(!isVip())
        {
            return false;
        }

        if(_sevenKData.vipType == E7kVipType.COMMON)
        {
            return _manager.rewardInfoData.everydayRewardState == ERewardTakeState.CanTake;
        }
        else if(_sevenKData.vipType == E7kVipType.YEAR)
        {
            return _manager.rewardInfoData.everydayRewardState == ERewardTakeState.CanTake
                    || _manager.rewardInfoData.yearVipEverydayRewardState == ERewardTakeState.CanTake;
        }

        return false;
    }

    public function hasNewRewards():Boolean
    {
        if(!isVip())
        {
            return false;
        }

        var rewardInfoData:C7K7KRewardInfoData = _manager.rewardInfoData;
        if(rewardInfoData)
        {
            return rewardInfoData.newPlayerRewardState == ERewardTakeState.CanTake;
        }

        return false;
    }

    public function hasLevelRewards():Boolean
    {
        if(!isVip())
        {
            return false;
        }

        var hasTakeArr:Array = [];
        var rewardInfoData:C7K7KRewardInfoData = _manager.rewardInfoData;
        if(rewardInfoData)
        {
            hasTakeArr = rewardInfoData.levelUpRewardState;
        }

        var teamLevel:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;

        var arr:Array = getLevelRewards();
        for each(var info:C7KLevelRewardData in arr)
        {
            if(info && teamLevel >= info.level && hasTakeArr.indexOf(info.level) == -1)
            {
                return true;
            }
        }

        return false;
    }

    /**
     * 每日奖励
     * @return
     */
    public function getEveryDayRewards(vipType:int):Array
    {
        var sevenKData:C7KData = _sevenKData;
        if(sevenKData)
        {
//            var vipType:int;
//            if(sevenKData.vipType == E7kVipType.COMMON || sevenKData.vipType == E7kVipType.NONE)
//            {
//                vipType = 1;
//            }
//            else if(sevenKData.vipType == E7kVipType.YEAR)
//            {
//                vipType = 2;
//            }

            var arr:Array = _sevenKRewardConfig.findByProperty("vipType", vipType);
            if(arr && arr.length)
            {
                var dropId:int = (arr[0] as SevenKRewardConfig).everydayReward;
                var rewardList:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, dropId);

                return rewardList.list;
            }
        }

        return [];
    }

    /**
     * 新手奖励
     * @return
     */
    public function getNewRewards():Array
    {
        var sevenKData:C7KData = _sevenKData;
        if(sevenKData)
        {
            var vipType:int;
            if(sevenKData.vipType == E7kVipType.COMMON || sevenKData.vipType == E7kVipType.NONE)
            {
                vipType = 1;
            }
            else if(sevenKData.vipType == E7kVipType.YEAR)
            {
                vipType = 2;
            }

            var arr:Array = _sevenKRewardConfig.findByProperty("vipType", vipType);
            if(arr && arr.length)
            {
                var dropId:int = (arr[0] as SevenKRewardConfig).newPlayerReward;
                var rewardList:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, dropId);

                return rewardList.list;
            }
        }

        return [];
    }

    /**
     * 等级奖励
     * @return 掉落包ID数组
     */
    public function getLevelRewards():Array
    {
        var resultArr:Array = [];
        var arr:Array = _levelUpReward7k7k.toArray();
        if(arr && arr.length)
        {
            for(var i:int = 0; i < arr.length; i++)
            {
                var tableData:LevelUpReward7k7k = arr[i] as LevelUpReward7k7k;
                var rewardData:C7KLevelRewardData = new C7KLevelRewardData();
                rewardData.level = tableData.level;
                rewardData.dropId = tableData.rewardID;
                resultArr.push(rewardData);
            }
        }

        return resultArr;
    }

    /**
     * 得某个等级奖励的领取状态
     * @param level
     * @return
     */
    public function getLevelRewardState(level:int):int
    {
        if(!isVip())
        {
            return ERewardTakeState.CannotTake;
        }

        var rewardInfoData:C7K7KRewardInfoData = _manager.rewardInfoData;
        if(rewardInfoData && rewardInfoData.levelUpRewardState)
        {
            if(rewardInfoData.levelUpRewardState.indexOf(level) == -1)
            {
                var teamLevel:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;
                if(teamLevel >= level)
                {
                    return ERewardTakeState.CanTake;
                }
                else
                {
                    return ERewardTakeState.CannotTake;
                }
            }
            else
            {
                return ERewardTakeState.HasTake;
            }
        }

        return ERewardTakeState.CannotTake;
    }

    public function isVip():Boolean
    {
        return _sevenKData && _sevenKData.vipType != E7kVipType.NONE;
    }

    //property===============================================================================
    private function get _sevenKData():C7KData
    {
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var data:C7KData = pPlayerSystem.platform.sevenKData;

        return data;
    }

    private function get _manager():C7KHallManager
    {
        return system.getHandler(C7KHallManager) as C7KHallManager;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _levelUpReward7k7k():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.LEVELUPREWARD7k7k);
    }

    private function get _sevenKRewardConfig():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SEVENKREWARDCONFIG);
    }
}
}
