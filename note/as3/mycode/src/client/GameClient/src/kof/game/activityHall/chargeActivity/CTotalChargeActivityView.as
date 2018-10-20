//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/8/9.
 */
package kof.game.activityHall.chargeActivity {

import QFLib.Foundation.CTime;

import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLogUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.TotalCharge.TotalChargeItemUI;
import kof.ui.master.TotalCharge.TotalChargeUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CTotalChargeActivityView {

    private var m_pSystem:CAppSystem;
    private var m_ui:TotalChargeUI;
    private var m_activityInfo:CActivityHallActivityInfo;

    private var m_deadLine:Number = 0;

    public function CTotalChargeActivityView( system:CAppSystem, ui:TotalChargeUI) {
        m_pSystem = system;
        m_ui = ui;

        m_ui.chargeBtn.clickHandler = new Handler(_onCzBtnClick);
        m_ui.itemList.renderHandler = new Handler(onRenderItem);
    }

    /**
     * 点击充值按钮
     */
    private function _onCzBtnClick():void {
        var activityHall:ISystemBundleContext = m_pSystem.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = activityHall.getSystemBundle(SYSTEM_ID(KOFSysTags.ACTIVITY_HALL));
        activityHall.setUserData(systemBundle, CBundleSystem.ACTIVATED, false);

        var bundleCtx:ISystemBundleContext = m_pSystem.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        systemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

        CLogUtil.recordLinkLog(m_pSystem, 10024);
    }

    public function updateCDTime():void
    {
        if(m_ui.visible)
        {
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_deadLine-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
//                m_ui.leftDayClip.index = days;
                m_ui.leftDayClip.num = days;
                m_ui.leftDayClip.x = days >= 10 ? 406 : 446;
                leftTime = leftTime-days*24*60*60*1000;
                m_ui.deadlineLabel.text = CTime.toDurTimeString(leftTime);
            }
        }
    }

    public function addDisplay(activityInfo:CActivityHallActivityInfo):void
    {
        m_activityInfo = activityInfo;
        if(m_activityInfo.table.image)
        {
            var tempArray:Array = m_activityInfo.table.image.split(".");
            if(tempArray && tempArray.length>0)
            {
//                m_ui.adImg.url = tempArray[1]+".activityhall.ad."+tempArray[0];
            }
        }
        //计算开始——结束时间
        m_ui.timeLabel.text = activityHallDataManager.getYearMonthDateByTime(m_activityInfo.startTime)+"-"+activityHallDataManager.getYearMonthDateByTime(m_activityInfo.endTime);
        m_deadLine = m_activityInfo.endTime+2000;//加两秒避免时间同步问题
//        if(!m_ui.visible)
//        {
            activityHallSystem.addEventListener(CActivityHallEvent.TotalRechargeResponse, updateView);
            activityHallSystem.addEventListener(CActivityHallEvent.TotalRechargeRewardResponse, onReceivedReturn);

            (activityHallSystem.getBean(CActivityHallHandler) as CActivityHallHandler).onChargeActivityRequest();
//        }
    }

    public function removeDisplay():void
    {
        activityHallSystem.removeEventListener(CActivityHallEvent.TotalRechargeResponse, updateView);
        activityHallSystem.removeEventListener(CActivityHallEvent.TotalRechargeRewardResponse, onReceivedReturn);
//        if(m_ui.visible)
//        {
//            m_ui.visible = false;
//        }
    }

    private function onReceivedReturn(event:CActivityHallEvent):void
    {
        var diamond:int = event.data as int;
        var itemUI:TotalChargeItemUI;
        var data:CTotalChargeData;
        var items:Vector.<Box> = m_ui.itemList.cells;
        var len:int = items.length;
        for(var i:int=0; i<len; i++)
        {
            itemUI = items[i] as TotalChargeItemUI;
            data = itemUI.dataSource as CTotalChargeData;
            if(data && data.config.rechargeValue==diamond)
            {
                _flyItem(itemUI);
                updateView();
                return;
            }
        }
    }

    private function updateView(event:CActivityHallEvent=null):void
    {
        m_ui.visible = true;

        m_ui.diamondLabel.text = activityHallDataManager.chargeDiamond.toString();

        var itemUI:TotalChargeItemUI;
        var items:Vector.<Box> = m_ui.itemList.cells;
        var len:int = items.length;
        for(var i:int=0; i<len; i++)
        {
            itemUI = items[i] as TotalChargeItemUI;
            itemUI.getBtn.clickHandler = null;
            itemUI.getBtn.disabled = false;
        }
        m_ui.itemList.dataSource = activityHallDataManager.getTotalChargeConfigs(m_activityInfo.table.ID);
        m_ui.itemList.scrollBar.scrollSize = 8;
    }

    private function onRenderItem(item:TotalChargeItemUI, index:int):void {
        if ( item == null || item.dataSource == null )return;

        var data:CTotalChargeData = item.dataSource as CTotalChargeData;
        if(data)
        {
            item.nameLabel.text = data.config.rechargeValue.toString();
            item.getBtn.clickHandler = new Handler(onClickToGetReward, [data.config.rechargeValue, data.config.ID]);

//            item.rewardItemList.renderHandler = new Handler( _renderRewardItem );
            item.rewardItemList.renderHandler = new Handler( CItemUtil.getItemRenderFunc(m_pSystem) );
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(m_pSystem.stage, data.config.prize);
            if(rewardListData)
            {
                item.rewardItemList.dataSource = rewardListData.list;
            }
            _onRenderItem(item, data);
        }
    }

    private function _onRenderItem(item:TotalChargeItemUI, data:CTotalChargeData):void
    {
        item.desLabel.text = "可累计领 #num1/#num2 次".replace("#num1",data.leftTimes).replace("#num2",data.config.limit);
        if(data.leftTimes>0)
        {
            item.getBtn.label = "领取";
        }
        else if(activityHallDataManager.chargeDiamond>=data.config.rechargeValue)
        {
            item.getBtn.label = "已领取";
        }
        else
        {
            item.getBtn.label = "未达成";
        }
        if(data.config.limit <= 1)
        {
            item.getBtn.y = 23;
            item.desLabel.text = "";
        }
        else
        {
            item.getBtn.y = 13;
        }
        item.getBtn.disabled = data.leftTimes==0? true:false;
    }

    private function _renderRewardItem(item:RewardItemUI, index:int):void
    {
        if ( item == null || item.dataSource == null )return;

        item.mouseChildren = false;
        item.mouseEnabled = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if(null != itemData)
        {
            if(itemData.num >= 1)
            {
                item.num_lable.text = itemData.num.toString();
            }

            item.icon_image.url = itemData.iconSmall;
            item.bg_clip.index = itemData.quality;
            item.box_eff.visible = itemData.effect;
            item.clip_eff.autoPlay = itemData.effect;
        }
        else
        {
            item.num_lable.text = "";
            item.icon_image.url = "";
        }

        item.toolTip = new Handler( _showTips, [item] );
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:RewardItemUI):void
    {
        (m_pSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    private function onClickToGetReward(diamond:int, id:int):void
    {
        (activityHallSystem.getBean(CActivityHallHandler) as CActivityHallHandler).onReceiveChargeActivityRequest(diamond, id);
    }

    private function _flyItem(itemUI:TotalChargeItemUI):void
    {
        var len:int = itemUI.rewardItemList.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  itemUI.rewardItemList.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), m_pSystem);
        }
    }

    private function get activityHallDataManager() : CActivityHallDataManager
    {
        return activityHallSystem.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }

    private function get activityHallSystem():CActivityHallSystem
    {
        return m_pSystem.stage.getSystem(CActivityHallSystem ) as CActivityHallSystem;
    }
}
}

