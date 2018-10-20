//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/3/30.
 */
package kof.game.ActivityNotice {

import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.enums.EActivityState;
import kof.game.KOFSysTags;
import kof.game.player.CPlayerSystem;
import kof.game.switching.CSwitchingSystem;
import kof.table.ActivitySchedule;

public class CActivityNoticeHelpHandler extends CAbstractHandler {
    public function CActivityNoticeHelpHandler() {
        super();
    }

    public function getActivityDatas():Array
    {
        var arr:Array = _activitySchedule.toArray();
        arr.sort(_sortByProcess);

        return arr;
    }

    private function _sortByProcess(a:ActivitySchedule, b:ActivitySchedule):int
    {
        var state1:int = getActivityState(a);
        var state2:int = getActivityState(b);
        if(state1 != state2)
        {
            return state1 - state2;
        }
        else
        {
            return _sortByLevel(a, b);
        }
    }

    private function _sortByLevel(a:ActivitySchedule, b:ActivitySchedule):int
    {
        var levelA:int = int(a.openCondition.split("&")[0]);
        var levelB:int = int(b.openCondition.split("&")[0]);

        var teamLevel:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;

        if(levelA <= teamLevel && levelB > teamLevel)
        {
            return -1;
        }
        else if(levelA > teamLevel && levelB <= teamLevel)
        {
            return 1;
        }
        else
        {
            return _sortByTime(a, b);
        }
    }

    private function _sortByTime(a:ActivitySchedule, b:ActivitySchedule):int
    {
        var dateA:Date = CDateUtil.getDateByFullTimeString( a.startTime);
        var dateB:Date = CDateUtil.getDateByFullTimeString( b.startTime);

        if(dateA.time != dateB.time)
        {
            return dateA.time - dateB.time;
        }
        else
        {
            return _sortByPriority(a, b);
        }
    }

    private function _sortByPriority(a:ActivitySchedule, b:ActivitySchedule):int
    {
        if( a.priority < b.priority)
        {
            return -1;
        }
        else if( a.priority > b.priority)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    public function getActivityState(info:ActivitySchedule):int
    {
        if(info)
        {
            if(!isActivityInDate(info))
            {
                return EActivityState.Type_NotStart;
            }

            var currTime:Number = CTime.getCurrServerTimestamp();
            var currDate:Date = new Date(currTime);
            var startDate:Date = CDateUtil.getDateByFullTimeString(info.startTime);
            var endDate:Date = CDateUtil.getDateByFullTimeString(info.endTime);
            startDate.setFullYear(currDate.fullYear, currDate.month, currDate.date);
            endDate.setFullYear(currDate.fullYear, currDate.month, currDate.date);

            if(currTime < startDate.time)
            {
                return EActivityState.Type_NotStart;
            }
            else if(currTime >= startDate.time && currTime <= endDate.time)
            {
                return EActivityState.Type_Processing;
            }
            else
            {
                return EActivityState.Type_HasEnd;
            }
        }

        return EActivityState.Type_HasEnd;
    }

    public function getUpercaseNum(numStr:String):String
    {
        switch (numStr)
        {
            case "1":
                return "一";
            case "2":
                return "二";
            case "3":
                return "三";
            case "4":
                return "四";
            case "5":
                return "五";
            case "6":
                return "六";
            case "0":
                return "日";
        }

        return "";
    }

    /**
     * 活动开启等级
     * @param info
     * @return
     */
    public function getActOpenLevel(info:ActivitySchedule):int
    {
        if(info)
        {
            var arr:Array = info.openCondition.split("&");
            if(arr && arr.length)
            {
                return int(arr[0]);
            }
        }

        return 0;
    }

    /**
     * 是否达到活动开启等级
     * @return
     */
    public function isReachActOpenLevel(info:ActivitySchedule):Boolean
    {
        var teamLevel:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;

        return teamLevel >= getActOpenLevel(info);
    }

    /**
     * 活动是否在开启日期
     */
    public function isActivityInDate(info:ActivitySchedule):Boolean
    {
        if(info.sysTag == KOFSysTags.GUILDWAR)
        {
            if(CTime.serverOpenDayNum == 2)
            {
                return true;
            }
        }

        var arr:Array = info.openCondition.split("&");
        if(arr)
        {
            if(arr.length == 1)
            {
                return true;
            }
            else
            {
                var dateStr:String = arr[1];
                var currDate:Date = new Date(CTime.getCurrServerTimestamp());
                var day:String = currDate.getDay().toString();
                return dateStr.indexOf(day) != -1;
            }
        }

        return true;
    }

    public function isSystemOpen(sysTag:String):Boolean
    {
        return (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(sysTag);
    }

    /**
     * 得提示类型
     * @param act
     * @return
     */
    public function getNoticeType(act:ActivitySchedule):int
    {
        var types:int;
        if(act && act.noticeType)
        {
            var arr1:Array = act.noticeType.split("&");
            if(arr1 && arr1.length)
            {
                for each(var str:String in arr1)
                {
                    var arr2:Array = str.split("#");
                    if(arr2 && arr2.length)
                    {
                        var type:int = int(arr2[0]);
                        types = (types | type);
                    }
                }
            }
        }

        return types;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _activitySchedule():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ActivitySchedule);
    }
}
}
