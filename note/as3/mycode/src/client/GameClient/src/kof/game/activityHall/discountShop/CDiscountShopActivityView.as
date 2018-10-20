//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/8/9.
 */
package kof.game.activityHall.discountShop {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import kof.framework.CAppSystem;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallHandler;
import kof.game.currency.enum.ECurrencyType;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.config.CPlayerPath;
import kof.table.DiscounterActivityConfig;
import kof.table.Item;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.DiscountShop.DiscountShopItemUI;
import kof.ui.master.DiscountShop.DiscountShopUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.handlers.Handler;

//折扣商店界面
public class CDiscountShopActivityView {

    private var m_pSystem:CAppSystem;
    private var m_shopUI:DiscountShopUI;
    private var m_activityInfo:CActivityHallActivityInfo;

    private var m_buyView:CDiscountShopActivityBuyView;

    private var m_deadLine:Number = 0;

    public function CDiscountShopActivityView(system:CAppSystem, ui:DiscountShopUI) {
        m_pSystem = system;
        m_shopUI = ui;

        m_shopUI.itemList.renderHandler = new Handler(onRenderItem);
    }

    public function updateCDTime():void
    {
        if(m_shopUI.visible)
        {
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_deadLine-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
//                m_shopUI.leftDayClip.index = days;
                m_shopUI.leftDayClip.num = days;
                m_shopUI.leftDayClip.x = days >= 10 ? 406 : 428;
                leftTime = leftTime-days*24*60*60*1000;
                m_shopUI.deadlineLabel.text = CTime.toDurTimeString(leftTime);
            }
        }
    }

    public function addDisplay(activityInfo:CActivityHallActivityInfo):void
    {
//        if(!m_shopUI.visible)
//        {
            m_activityInfo = activityInfo;
            if(m_activityInfo.table.image)
            {
                var tempArray:Array = m_activityInfo.table.image.split(".");
                if(tempArray && tempArray.length>0)
                {
//                    m_shopUI.adImg.url = tempArray[1]+".activityhall.ad."+tempArray[0];
                }
            }
            //计算开始——结束时间
            m_shopUI.timeLabel.text = activityHallDataManager.getYearMonthDateByTime(m_activityInfo.startTime)+"-"+activityHallDataManager.getYearMonthDateByTime(m_activityInfo.endTime);
            m_deadLine = m_activityInfo.endTime+2000;//加两秒避免时间同步问题
            m_shopUI.img_hero.url = CPlayerPath.getUIHeroFacePath(310);

            activityHallSystem.addEventListener(CActivityHallEvent.DiscounterResponse, updateView);
            activityHallSystem.addEventListener(CActivityHallEvent.BuyDiscountGoodsResponse, onBuyDone);

            (activityHallSystem.getBean(CActivityHallHandler) as CActivityHallHandler).onDiscounterRequest();
//        }
    }

    public function removeDisplay():void
    {
        activityHallSystem.removeEventListener(CActivityHallEvent.DiscounterResponse, updateView);
        activityHallSystem.removeEventListener(CActivityHallEvent.BuyDiscountGoodsResponse, onBuyDone);
//        if(m_shopUI.visible)
//        {
//            m_shopUI.visible = false;
//        }
    }

    private function updateView(event:CActivityHallEvent):void
    {
        m_shopUI.visible = true;

        var itemUI:DiscountShopItemUI;
        var items:Vector.<Box> = m_shopUI.itemList.cells;
        var len:int = items.length;
        for(var i:int=0; i<len; i++)
        {
            itemUI = items[i] as DiscountShopItemUI;
            itemUI.buyBtn.clickHandler = null;
            itemUI.buyBtn.disabled = false;
        }
        m_shopUI.itemList.dataSource = activityHallDataManager.getDiscountShopConfigs(m_activityInfo.table.ID);
    }

    private function onBuyDone(event:CActivityHallEvent):void
    {
        var id:int = event.data as int;
        var itemUI:DiscountShopItemUI;
        var config:DiscounterActivityConfig;
        var items:Vector.<Box> = m_shopUI.itemList.cells;
        var len:int = items.length;
        for(var i:int=0; i<len; i++)
        {
            itemUI = items[i] as DiscountShopItemUI;
            config = itemUI.dataSource as DiscounterActivityConfig;
            if(config && config.goodsID==id)
            {
                _onRenderItem(itemUI, config);
                return;
            }
        }
    }

    private function onRenderItem(item:DiscountShopItemUI, index:int):void
    {
        if( item == null || item.dataSource == null )return;

        var discountConfig:DiscounterActivityConfig = item.dataSource as DiscounterActivityConfig;
        var itemTable:Item = activityHallDataManager.getItemTableByID(discountConfig.goodsID);
        item.itemUi.toolTip = new Handler( _showItemTips, [ item.itemUi, itemTable.ID ]);
        item.nameLabel.text = HtmlUtil.getHtmlText(itemTable.name,CQualityColor.getColorByQuality(itemTable.quality-1),14) ;//名称
        item.oldPriceLabel.text = item.oldPriceLabel.text.replace(/\d+/,discountConfig.price);//原价
        item.nowPriceLabel.text = item.nowPriceLabel.text.replace(/\d+/,discountConfig.discountPrice);//现价
        var discount:int = Math.round(discountConfig.discountPrice/discountConfig.price*10);
        item.clip_z.frame = discount;//折扣
        item.itemUi.clip_bg.index = itemTable.quality;//品质框
        item.itemUi.img.url = itemTable.bigiconURL + ".png";//资源路径
        item.itemUi.txt_num.text = "1";//数量
        item.itemUi.box_effect.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || 1 >= itemTable.extraEffect) : false;
        item.itemUi.clip_effect.autoPlay = itemTable.effect;
        item.buyBtn.clickHandler = new Handler(_onClickToBuy, [discountConfig]);

        if(discountConfig.currencyType==ECurrencyType.DIAMOND)
        {
            //显示钻石图标
            item.oldImg.url = "png.common.img.bluediamond";
            item.nowImg.url = "png.common.img.bluediamond";
        }
        else
        {
            //显示绑钻图标
            item.oldImg.url = "png.common.img.violetdiamond";
            item.nowImg.url = "png.common.img.violetdiamond";
        }

        _onRenderItem(item, discountConfig);
    }

    private function _onRenderItem(item:DiscountShopItemUI, discountConfig:DiscounterActivityConfig):void
    {
        var buyTimes:int = activityHallDataManager.getCanBuyTimesInShop(discountConfig.type, discountConfig.goodsID);
        if(discountConfig.type == CActivityHallActivityType.SERVER_LIMIT)
        {
            //全服限购
            item.limitLabel.text = "全服限购：#num1/#num2".replace("#num1",buyTimes ).replace("#num2",discountConfig.limitCounts);
            item.buyBtn.disabled = buyTimes>0? false:true;
        }
        else if(discountConfig.type == CActivityHallActivityType.PERSON_LIMIT)
        {
            //个人限购
            item.limitLabel.text = "个人限购：#num1/#num2".replace("#num1",buyTimes ).replace("#num2",discountConfig.limitCounts);
            item.buyBtn.disabled = buyTimes>0? false:true;
        }
        else if(discountConfig.type == CActivityHallActivityType.NO_LIMIT)
        {
            //不限购
            item.limitLabel.text = "无数量限制";
            item.buyBtn.disabled = false;
        }
    }

    /**显示物品Tips*/
    private function _showItemTips(item:ItemUIUI, itemTable:int):void {
        (m_pSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item, [itemTable]);
    }

    private function _onClickToBuy(discountConfig:DiscounterActivityConfig):void{
        if(!m_buyView) m_buyView = new CDiscountShopActivityBuyView();
        m_buyView.popup();
        m_buyView.initShow(activityHallSystem, discountConfig);
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
