//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.guildWar {

import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.enums.EActivityState;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubConst;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.enum.EEnergyRewardType;
import kof.game.guildWar.enum.EStationType;
import kof.table.ClubPosition;
import kof.table.GuildWarBuff;
import kof.table.GuildWarReport;
import kof.table.GuildWarReward;
import kof.table.GuildWarSpaceTable;
import kof.table.GuildWarSpaceTable;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

public class CGuildWarHelpHandler extends CAbstractHandler {
    public function CGuildWarHelpHandler() {
        super();
    }

    public function isInActivityTime():Boolean
    {
        return getActivityState() == EActivityState.Type_Processing;
    }

    public function getActivityState():int
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            var currTime:Number = CTime.getCurrServerTimestamp();
            if(currTime < _guildWarData.baseData.startTime)
            {
                return EActivityState.Type_NotStart;
            }
            else if(currTime < _guildWarData.baseData.endTime)
            {
                return EActivityState.Type_Processing;
            }
            else
            {
                return EActivityState.Type_HasEnd;
            }
        }
        else
        {
            return EActivityState.Type_NotStart;
        }
    }

    /**
     * 当前是否在开服的那一周
     * @return
     */
    public function isInServerOpenWeek():Boolean
    {
        var serverOpenDate:Date = new Date(CTime.serverOpenTimestamp);
        var day:int = serverOpenDate.day == 0 ? 7 : serverOpenDate.day;
        var serverOpenDay:int = CTime.serverOpenDayNum;
        var leftDay:int = 8 - day;
        return serverOpenDay <= leftDay;
    }

    /**
     * 是否在开服第二天的公会战活动前
     * @return
     */
    public function isBeforeFirstActivity():Boolean
    {
        var serverOpenDate:Date = new Date(CTime.serverOpenTimestamp);
        CDateUtil.setZeroDate(serverOpenDate);
        serverOpenDate.date += 2;

        return CTime.getCurrServerTimestamp() <= serverOpenDate.time;
    }

    public function isSameWeek():Boolean
    {
        if(!(_guildWarData && _guildWarData.baseData))
        {
            return false;
        }

        var currDate:Date = new Date(CTime.getCurrServerTimestamp());
        var startDate:Date = new Date(_guildWarData.baseData.startTime);

        var diff:int = Math.abs(currDate.day - startDate.day);
        if(diff == 0 && currDate.date == startDate.date)
        {
            return true;
        }

        if(currDate.time < startDate.time)
        {
            var day1:int = currDate.day == 0 ? 7 : currDate.day;
            var day2:int = startDate.day == 0 ? 7 : startDate.day;
            var dayDiff:int = day2 - day1;

            currDate.date += dayDiff;

            if(currDate.month == startDate.month && currDate.date == startDate.date)
            {
                return true;
            }
        }

        return false;
    }

    /**
     * 活动开启前24小时内
     * @return
     */
    public function isBefore48h():Boolean
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            if(getActivityState() == EActivityState.Type_NotStart)
            {
                var diff:Number = _guildWarData.baseData.startTime - CTime.getCurrServerTimestamp();
                return Math.ceil(diff/1000/3600) <= 48;
            }
        }

        return false;
    }

    /**
     * 活动结束后3分钟内
     * @return
     */
    public function isInEnd3Min():Boolean
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            if(getActivityState() == EActivityState.Type_HasEnd)
            {
                var endTime:Number = _guildWarData.baseData.endTime + 3*60*1000;
                return (endTime - CTime.getCurrServerTimestamp()) > 0;
            }
        }

        return false;
    }

    public function getSpaceTableData(stationId:int):GuildWarSpaceTable
    {
        return _guildWarSpaceTable.findByPrimaryKey(stationId) as GuildWarSpaceTable;
    }

    public function getSpaceTableDataByType(spaceType:int):GuildWarSpaceTable
    {
        var arr:Array = _guildWarSpaceTable.findByProperty("spaceType", spaceType);
        if(arr && arr.length)
        {
            return arr[0] as GuildWarSpaceTable;
        }

        return null;
    }

    public function getStationNameById(stationId:int):String
    {
        var tableData:GuildWarSpaceTable = getSpaceTableData(stationId);
        if(tableData)
        {
            return tableData.spaceName;
        }

        return "";
    }

    /**
     * 空间站奖励(每日奖励、宝箱奖励)
     */
    public function getStationRewards():Array
    {
        var resultArr:Array = [];
        var high:GuildWarSpaceTable = getSpaceTableDataByType(EStationType.Type_High);
        if(high)
        {
            resultArr.push(high);
        }

        var mid:GuildWarSpaceTable = getSpaceTableDataByType(EStationType.Type_Mid);
        if(mid)
        {
            resultArr.push(mid);
        }

        var low:GuildWarSpaceTable = getSpaceTableDataByType(EStationType.Type_Low);
        if(low)
        {
            resultArr.push(low);
        }

        return resultArr;
    }

    /**
     * 能源奖励(个人、俱乐部)
     * @return
     */
    public function getEnergyRewardsByType(type:int):Array
    {
        var arr:Array = _guildWarReward.findByProperty("type", type) as Array;
        if(arr)
        {
            return arr;
        }
        else
        {
            return [];
        }
    }

    /**
     * 俱乐部能源奖励领取状态
     * @param rewardData
     * @return
     */
    public function getClubRewardTakeState(rewardData:GuildWarReward):int
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            var hasTakeRewards:Array = _guildWarData.baseData.clubTotalScoreRewardIDs;
            if(hasTakeRewards.indexOf(rewardData.ID) != -1)
            {
                return ERewardTakeState.HasTake;
            }
            else
            {
                if(_guildWarData.baseData.clubTotalScore >= rewardData.score)
                {
                    return ERewardTakeState.CanTake;
                }
                else
                {
                    return ERewardTakeState.CannotTake;
                }
            }
        }

        return ERewardTakeState.CannotTake;
    }

    /**
     * 个人能源奖励领取状态
     * @param rewardData
     * @return
     */
    public function getRoleRewardTakeState(rewardData:GuildWarReward):int
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            var hasTakeRewards:Array = _guildWarData.baseData.roleTotalScoreRewardIDs;
            if(hasTakeRewards.indexOf(rewardData.ID) != -1)
            {
                return ERewardTakeState.HasTake;
            }
            else
            {
                if(_guildWarData.baseData.totalScore >= rewardData.score)
                {
                    return ERewardTakeState.CanTake;
                }
                else
                {
                    return ERewardTakeState.CannotTake;
                }
            }
        }

        return ERewardTakeState.CannotTake;
    }

    public function getStationTypeById(id:int):int
    {
        switch (id)
        {
            case 1:
                return EStationType.Type_High;
            case 2:
            case 3:
                return EStationType.Type_Mid;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
                return EStationType.Type_Low;
        }

        return 0;
    }

    /**
     * 战报文本内容格式
     * @param id
     * @return
     */
    public function getFightReportContent(id:int):String
    {
        var tableData:GuildWarReport = _guildWarReport.findByPrimaryKey(id) as GuildWarReport;
        if(tableData)
        {
            return tableData.content;
        }

        return "";
    }

    public function getBuffTableData(type:int):GuildWarBuff
    {
        return _guildWarBuff.findByPrimaryKey(type) as GuildWarBuff;
    }

    /**
     * 公会职位名
     * @param position
     * @return
     */
    public function getGuildPositionName(position:int):String
    {
        var tableData:ClubPosition = _clubPositionTable.findByPrimaryKey(position) as ClubPosition;
        if(tableData)
        {
            return tableData.position;
        }

        return "";
    }

    /**
     * 是否已加入公会
     * @return
     */
    public function isJoinClub():Boolean
    {
        if(!((system.stage.getSystem(CClubSystem) as CClubSystem).getHandler(CClubManager) as CClubManager).isInClub)
        {
            return false;
        }

        return true;
    }

    /**
     * 是否会长
     * @return
     */
    public function isChairman():Boolean
    {
        var position:int = ((system.stage.getSystem(CClubSystem) as CClubSystem).getHandler(CClubManager) as CClubManager).clubPosition;
        return position == CClubConst.CLUB_POSITION_4;
    }

    /**
     * 是否为自己的俱乐部
     * @return
     */
    public function isSelfClub(clubId:String):Boolean
    {
        return ((system.stage.getSystem(CClubSystem) as CClubSystem).getHandler(CClubManager) as CClubManager).clubID == clubId;
    }

    /**
     * 是否有奖励领
     * @return
     */
    public function hasRewardTake():Boolean
    {
        var clubRewards:Array = getEnergyRewardsByType(EEnergyRewardType.Type_Club);
        if(clubRewards && clubRewards.length)
        {
            for each(var data:GuildWarReward in clubRewards)
            {
                if(data && getClubRewardTakeState(data) == ERewardTakeState.CanTake)
                {
                    return true;
                }
            }
        }

        var roleRewards:Array = getEnergyRewardsByType(EEnergyRewardType.Type_Role);
        if(roleRewards && roleRewards.length)
        {
            for each(var data2:GuildWarReward in roleRewards)
            {
                if(data2 && getRoleRewardTakeState(data2) == ERewardTakeState.CanTake)
                {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * 是否已占领的空间站
     * @param stationId
     * @return
     */
    public function isOccupyStation(stationId:int):Boolean
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            return _guildWarData.baseData.winnerSpaceIds.indexOf(stationId) != -1;
        }

        return false;
    }

    /**
     * 空间站首占奖励
     * @param spaceType
     * @return
     */
    public function getFirstOccupyRewardInfo(spaceType:int):Array
    {
        return _firstOccupyRewardTable.findByProperty("spaceType", spaceType);
    }

//==========================================get/set==================================================
    private function get _guildWarData():CGuildWarData
    {
        return (system.getHandler(CGuildWarManager) as CGuildWarManager).data;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _guildWarBuff():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GuildWarBuff);
    }

    private function get _guildWarReward():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GuildWarReward);
    }

    private function get _guildWarSpaceTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GuildWarSpaceTable);
    }

    private function get _guildWarReport():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GuildWarReport);
    }

    private function get _clubPositionTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.CLUBPOSITION);
    }

    private function get _firstOccupyRewardTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.FirstOccupyReward);
    }
}
}
