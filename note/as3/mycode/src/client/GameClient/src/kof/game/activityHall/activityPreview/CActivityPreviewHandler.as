//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/26.
 */
package kof.game.activityHall.activityPreview {

import QFLib.Foundation.CTime;

import kof.SYSTEM_TAG;

import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.CActivityHallViewHandler;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.data.CActivityState;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.CLogUtil;
import kof.game.switching.CSwitchingJump;
import kof.table.ActivityPreviewData;
import kof.ui.master.ActivityHall.ActivityPreviewUI;
import kof.ui.master.ActivityHall.PreviewItemUI;

import morn.core.components.Box;

import morn.core.handlers.Handler;

public class CActivityPreviewHandler {
    private var m_pSystem : CAppSystem;
    private var m_ui : ActivityPreviewUI;
    private var _selectIndex : int = 0;
    private var _listData : Array = [];
    public function CActivityPreviewHandler( system : CAppSystem, ui : ActivityPreviewUI ) {
        m_pSystem = system;
        m_ui = ui;
        m_ui.list_activity.renderHandler = new Handler( onRenderItem );
        m_ui.btn_left.clickHandler = new Handler( _pageDown );
        m_ui.btn_right.clickHandler = new Handler( _pageUp );
    }

    public function addDisplay( value : Array ) : void {
        activityHallDataManager.isFirstOpenPreview = false;//打开过一次就隐藏红点
        m_pSystem.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ACTIVITYPREVIEWDATA ) );
        m_ui.visible = true;
        //活动填充
        _listData = value;
        m_ui.list_activity.dataSource = _listData;
        m_ui.btn_left.disabled = true;
        m_ui.btn_right.disabled = _listData.length <= 5 ? true : false;
        m_ui.list_activity.startIndex = 0;
    }

    public function removeDisplay() : void {
        if ( m_ui.visible ) {
            m_ui.visible = false;
            _selectIndex = 0;
            _listData = [];
        }
    }

    private function onRenderItem(item : PreviewItemUI, idx : int) : void
    {
        if(!item || !item.dataSource) return;
        var activityInfo : Object = item.dataSource as Object;
        var configData : ActivityPreviewData = activityHallDataManager.getPreviewDataByType(-1,activityInfo.sysID);
        if(!configData) return;
        item.lb_name.text = configData.name;
        item.img_icon.skin = configData.url;
        item.lb_desc.text = configData.desc;
        var endtime : Number = activityInfo.endTime;
        if(configData.activityType == 1)//type 为1显示当前倒计时，超过1天显示剩余天数，低于显示具体秒数
        {
            var lefttime : Number = endtime - CTime.getCurrServerTimestamp();
            if(lefttime <= 0)
            {
                item.lb_time.text = "剩余时间：00:00:00";
            }
            else
            {
                var day : Number = lefttime/1000/3600/24;
                var timeStr : String = day > 1 ? Math.ceil(day) + "天" : CTime.toDurTimeString(lefttime);
                item.lb_time.text = "剩余时间：" + timeStr;
            }
        }
        else
        {
            item.lb_time.text = configData.prop;
        }
        if(configData.type == 0)//无type的活动，1开启2关闭
        {
            if(activityInfo.state == 1)
            {
                item.btn_join.visible = true;
                item.img_end.visible = false;
                item.btn_join.clickHandler = new Handler(_gotoJoin,[configData.sysID]);
            }
            else
            {
                item.btn_join.visible = false;
                item.img_end.visible = true;
            }
       }
        else//有type的活动，23开启4关闭
        {
            if(activityInfo.state == CActivityState.ACTIVITY_START || activityInfo.state == CActivityState.ACTIVITY_COMPLETE)
            {
                item.btn_join.visible = true;
                item.img_end.visible = false;
                item.btn_join.clickHandler = new Handler(_gotoJoin,[configData.sysID]);
            }
            else if(activityInfo.state == CActivityState.ACTIVITY_END)
            {
                item.btn_join.visible = false;
                item.img_end.visible = true;
            }
        }


    }
    public function updateCDTime() : void {
        if ( m_ui.visible ) {
            var items:Vector.<Box> = m_ui.list_activity.cells;
            var info : Object;
            var remainTime:Number;
            for each(var item:Object in items){
                info = item.dataSource as Object;
                if(!info) return;
                remainTime = info.endTime - CTime.getCurrServerTimestamp();
                if(remainTime < 1000*60*60*24 && remainTime > 0)
                {
                    item.lb_time.text = "剩余时间：" + CTime.toDurTimeString(remainTime);
                }
            }
        }
    }
    /**
     * 活动跳转
     * @param parm tagID
     */
    private function _gotoJoin( ...parm ) : void
    {
        if(!parm || !parm[0]) return;
        var tag : String = SYSTEM_TAG(parm[0]);
        CSwitchingJump.jump(m_pSystem,tag);

        switch (tag)
        {
            case KOFSysTags.INVEST:
                CLogUtil.recordLinkLog(m_pSystem, 10017);
                break;
            case KOFSysTags.RECHARGEREBATE:
                CLogUtil.recordLinkLog(m_pSystem, 10020);
                break;
            case KOFSysTags.DIAMOND_ROULETTE:
                CLogUtil.recordLinkLog(m_pSystem, 10027);
                break;
            case KOFSysTags.INVEST:
                CLogUtil.recordLinkLog(m_pSystem, 10017);
                break;
        }
    }

    private function _pageDown() : void
    {
        _selectIndex --;
        if(_selectIndex < 0)
        {
            _selectIndex = 0;
            m_ui.btn_left.disabled = true;
        }
        else
        {
            m_ui.btn_left.disabled = false;
        }
        m_ui.btn_right.disabled = false;
        m_ui.list_activity.startIndex = _selectIndex;
    }
    private function _pageUp() : void
    {
        _selectIndex ++;
        if(_selectIndex >= _listData.length - 5)
        {
            _selectIndex = _listData.length - 5;
            m_ui.btn_right.disabled = true;
        }
        else
        {
            m_ui.btn_right.disabled = false;
        }
        m_ui.btn_left.disabled = false;
        m_ui.list_activity.startIndex = _selectIndex;
    }

    private function get activityHallDataManager() : CActivityHallDataManager {
        return m_pSystem.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
