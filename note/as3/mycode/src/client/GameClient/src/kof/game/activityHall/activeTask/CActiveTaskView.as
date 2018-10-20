//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-5-28.
 */
package kof.game.activityHall.activeTask {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallHandler;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.ui.master.ActivityHall.ActiveTaskItemUI;
import kof.ui.master.ActivityHall.ActiveTaskUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * @author Ender
 * @date 2018-5-28
 */
public class CActiveTaskView {
    private var m_pSystem : CAppSystem;
    private var m_ui : ActiveTaskUI;
    private var m_activityInfo : CActivityHallActivityInfo;

    private var m_deadLine : Number = 0;

    public function CActiveTaskView( system : CAppSystem, ui : ActiveTaskUI ) {
        m_pSystem = system;
        m_ui = ui;
        m_ui.itemList.renderHandler = new Handler( onRenderItem );
    }

    public function updateCDTime() : void {
        if ( m_ui.visible ) {
            var currTime : Number = CTime.getCurrServerTimestamp();
            var leftTime : Number = m_deadLine - currTime;
            if ( leftTime > 0 ) {
                var days : int = leftTime / (24 * 3600 * 1000);
//                m_ui.leftDayClip.index = days;
                m_ui.leftDayClip.num = days;
                m_ui.leftDayClip.x = days >= 10 ? 445 : 467;
                leftTime = leftTime - days * 24 * 60 * 60 * 1000;
                m_ui.deadlineLabel.text = CTime.toDurTimeString( leftTime );
            }
        }
    }

    public function addDisplay( activityInfo : CActivityHallActivityInfo ) : void {
        m_activityInfo = activityInfo;
        if ( m_activityInfo.table.image ) {
            var tempArray : Array = m_activityInfo.table.image.split( "." );
            if ( tempArray && tempArray.length > 0 ) {
                m_ui.adImg.url = tempArray[ 1 ] + ".activityhall.ad." + tempArray[ 0 ];
            }
        }
        //活动描述
        m_ui.describeLabel.text = m_activityInfo.table.info;

        //计算开始——结束时间
        m_ui.timeLabel.text = activityHallDataManager.getYearMonthDateByTime( m_activityInfo.startTime ) + "-" + activityHallDataManager.getYearMonthDateByTime( m_activityInfo.endTime );
        m_deadLine = m_activityInfo.endTime + 2000;//加两秒避免时间同步问题
        if ( !m_ui.visible ) {
            m_pSystem.addEventListener( CActivityHallEvent.ActiveTaskResponse, updateView );
            m_pSystem.addEventListener( CActivityHallEvent.ActiveTaskRewardResponse, onReceivedReturn );
            m_pSystem.addEventListener( CActivityHallEvent.ActiveTaskUpdateEvent, updateView );

            (m_pSystem.getBean( CActivityHallHandler ) as CActivityHallHandler).onLivingTaskActivityDataRequest();
        }
    }

    public function removeDisplay() : void {
        m_pSystem.removeEventListener( CActivityHallEvent.ActiveTaskResponse, updateView );
        m_pSystem.removeEventListener( CActivityHallEvent.ActiveTaskRewardResponse, onReceivedReturn );
        m_pSystem.removeEventListener( CActivityHallEvent.ActiveTaskUpdateEvent, updateView );
        if ( m_ui.visible ) {
            m_ui.visible = false;
        }
    }

    private function onReceivedReturn( event : CActivityHallEvent ) : void {
        var id : int = event.data as int;
        var itemUI : ActiveTaskItemUI;
        var data : CActiveTaskData;
        var items : Vector.<Box> = m_ui.itemList.cells;
        var len : int = items.length;
        for ( var i : int = 0; i < len; i++ ) {
            itemUI = items[ i ] as ActiveTaskItemUI;
            data = itemUI.dataSource as CActiveTaskData;
            if ( data && data.config.ID == id ) {
                _flyItem( itemUI );
                updateView();
                return;
            }
        }
    }

    private function updateView( event : CActivityHallEvent = null ) : void {
        m_ui.visible = true;

        var itemUI : ActiveTaskItemUI;
        var items : Vector.<Box> = m_ui.itemList.cells;
        var len : int = items.length;
        for ( var i : int = 0; i < len; i++ ) {
            itemUI = items[ i ] as ActiveTaskItemUI;
            itemUI.getBtn.clickHandler = null;
            itemUI.gotoBtn.clickHandler = null;
        }
        //排序算法
        activityHallDataManager.sortActiveTaskData();
        m_ui.itemList.dataSource = activityHallDataManager.getActiveTaskInfos();
        m_ui.itemList.scrollBar.scrollSize = 8;
    }

    private function onRenderItem( item : ActiveTaskItemUI, index : int ) : void {
        if ( item == null || item.dataSource == null )return;

        var data : CActiveTaskData = item.dataSource as CActiveTaskData;
        if ( data ) {
            item.describeLabel.text = data.config.desc;
            //进度
            item.numLabel.text = HtmlUtil.getHtmlText( data.currValue.toString(), "#ffdd00", 15 ) + "/" + data.config.targetVal;
            //按钮状态
            item.getBtn.visible = false;
            item.gotoBtn.visible = false;
            if ( data.state == 0 ) {
                item.gotoBtn.visible = true;
            }
            else if ( data.state == 1 ) {
                item.getBtn.visible = true;
                item.getBtn.disabled = false;
                item.getBtn.label = "领取";
            }
            else if ( data.state == 2 ) {
                item.getBtn.visible = true;
                item.getBtn.disabled = true;
                item.getBtn.label = "已领取";
            }
            //按钮点击侦听
            item.getBtn.clickHandler = new Handler( onClickToGetReward, [ data.config.activityId, data.config.ID ] );


            if (data.config.linkTarget && data.config.linkTarget.length > 0) {
                item.gotoBtn.clickHandler = new Handler( onClickGoto, [ data.config.linkTarget ] );
            } else {
                item.gotoBtn.visible = false;
            }

            item.rewardItemList.renderHandler = new Handler( CItemUtil.getItemRenderFunc( m_pSystem ) );
            //构造奖励List
            var rewardList : Array = [];
            var rewardItem0 : Object = {ID : data.config.itemID0, num : data.config.itemNumber0};
            var rewardItem1 : Object = {ID : data.config.itemID1, num : data.config.itemNumber1};
            var rewardItem2 : Object = {ID : data.config.itemID2, num : data.config.itemNumber2};
            var rewardItem3 : Object = {ID : data.config.itemID3, num : data.config.itemNumber3};
            rewardList.push( rewardItem0, rewardItem1, rewardItem2, rewardItem3 );
            var rewardListData : CRewardListData = CRewardUtil.createByList( m_pSystem.stage, rewardList );
            if ( rewardListData ) {
                item.rewardItemList.dataSource = rewardListData.list;
            }
        }
    }

    private function onClickToGetReward( activityId : int, id : int ) : void {
        (m_pSystem.getBean( CActivityHallHandler ) as CActivityHallHandler).onReceiveLivingTaskActivityRewardRequest( activityId, id );
    }

    private function onClickGoto( sysTag : String ) : void {
        //跳转
        var bundleCtx : ISystemBundleContext = m_pSystem.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( sysTag ) );
        bundleCtx.setUserData( bundle, "activated", true );
    }

    private function _flyItem( itemUI : ActiveTaskItemUI ) : void {
        var len : int = itemUI.rewardItemList.dataSource.length;
        for ( var i : int = 0; i < len; i++ ) {
            var item : Component = itemUI.rewardItemList.getCell( i ) as Component;
            CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), m_pSystem );
        }
    }

    private function get activityHallDataManager() : CActivityHallDataManager {
        return m_pSystem.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
