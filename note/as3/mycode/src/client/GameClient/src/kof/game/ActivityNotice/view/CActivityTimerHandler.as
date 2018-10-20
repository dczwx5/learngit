//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/4.
 */
package kof.game.ActivityNotice.view {

import QFLib.Foundation.CMap;
import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.CActivityNoticeHelpHandler;
import kof.game.ActivityNotice.data.CActivityNoticeData;
import kof.game.ActivityNotice.enums.EActivityNoticeType;
import kof.game.ActivityNotice.event.CActivityNoticeEvent;
import kof.table.ActivitySchedule;

/**
 * 活动计时器
 */
public class CActivityTimerHandler extends CViewHandler {

    private var m_pStateMap:CMap;
    private var m_pTimeMap:CMap;
    private var m_iDay:int;

    public function CActivityTimerHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function initialize():void
    {
        if(m_pStateMap == null)
        {
            m_pStateMap = new CMap();
        }

        if(m_pTimeMap == null)
        {
            m_pTimeMap = new CMap();
        }

        var currDate:Date = new Date(CTime.getCurrServerTimestamp());
        m_iDay = currDate.date;
        var dataArr:Array = _activitySchedule.toArray();
        for each(var info:ActivitySchedule in dataArr)
        {
            var startDate:Date = CDateUtil.getDateByFullTimeString(info.startTime);
            var endDate:Date = CDateUtil.getDateByFullTimeString(info.endTime);
            startDate.setFullYear(currDate.fullYear, currDate.month, currDate.date);
            endDate.setFullYear(currDate.fullYear, currDate.month, currDate.date);

            if(!info || !_isActCanNotice(info))
            {
                continue;
            }

            var timeInfo:Object = {};
            timeInfo["startDate"] = startDate;
            timeInfo["endDate"] = endDate;
            m_pTimeMap.add(info.ID, timeInfo);

            if(CDateUtil.isInDate(startDate, endDate))
            {
                m_pStateMap.add(info.ID, 1);
            }
            else
            {
                m_pStateMap.add(info.ID, 0);
            }
        }

        system.dispatchEvent(new CActivityNoticeEvent(CActivityNoticeEvent.ActivityIconInit, _getInitActData()));

        schedule(1, _onScheduleHandler);
    }

    private function _onScheduleHandler(delta : Number):void
    {
        for(var key:String in m_pTimeMap)
        {
            var id:int = int(key);
            var timeInfo:Object = m_pTimeMap[id];
            var startDate:Date = timeInfo["startDate"] as Date;
            var endDate:Date = timeInfo["endDate"] as Date;
            var newState:int = CDateUtil.isInDate(startDate, endDate) ? 1 : 0;
            var oldState:int = m_pStateMap[id] as int;
            if(newState != oldState)
            {
                m_pStateMap[id] = newState;
                var noticeData:CActivityNoticeData = new CActivityNoticeData();
                noticeData.id = id;
                noticeData.actData = _getActDataById(id);
                noticeData.openState = newState;
                noticeData.startTime = startDate;
                noticeData.endTime = endDate;
                if(noticeData.actData)
                {
                    system.dispatchEvent(new CActivityNoticeEvent(CActivityNoticeEvent.ActivityOpenStateChange, noticeData));
                }
            }
        }

        // 跨天
        var currDate:Date = new Date(CTime.getCurrServerTimestamp());
        if(m_iDay != currDate.date)
        {
            m_iDay = currDate.date;
            system.dispatchEvent(new CActivityNoticeEvent(CActivityNoticeEvent.ActivityCrossDay, null));
        }
    }

    /**
     * 登录时已开启的活动
     * @return
     */
    private function _getInitActData():Array
    {
        var arr:Array = [];
        for(var key:String in m_pTimeMap)
        {
            var id:int = int(key);
            var timeInfo:Object = m_pTimeMap[id];
            var startDate:Date = timeInfo["startDate"] as Date;
            var endDate:Date = timeInfo["endDate"] as Date;
            var oldState:int = m_pStateMap[id] as int;
            if(oldState == 1)
            {
                var noticeData:CActivityNoticeData = new CActivityNoticeData();
                noticeData.id = id;
                noticeData.actData = _getActDataById(id);
                noticeData.openState = oldState;
                noticeData.startTime = startDate;
                noticeData.endTime = endDate;

                arr.push(noticeData);
            }
        }

        return arr;
    }

    private function _isActCanNotice(info:ActivitySchedule):Boolean
    {
        return _helper.isReachActOpenLevel(info)
                && _helper.isActivityInDate(info);
    }

    private function _getActDataById(id:int):ActivitySchedule
    {
        var data:ActivitySchedule = _activitySchedule.findByPrimaryKey(id);
        if(data)
        {
            return data;
        }

        return null;
    }

    private function get _helper():CActivityNoticeHelpHandler
    {
        return system.getHandler(CActivityNoticeHelpHandler) as CActivityNoticeHelpHandler;
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
