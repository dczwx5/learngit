//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/8/10.
 */
package kof.game.activityHall.discountShop {

import QFLib.Utils.HtmlUtil;

import flash.events.Event;

import kof.SYSTEM_ID;

import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.currency.enum.ECurrencyType;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.shop.CShopSystem;
import kof.table.Currency;
import kof.table.DiscounterActivityConfig;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.shop.ShopBuyUI;
import kof.util.CQualityColor;

import morn.core.components.TextInput;
import morn.core.handlers.Handler;

public class CDiscountShopActivityBuyView extends ShopBuyUI{

    private var m_system:CAppSystem;
    private var m_config:DiscounterActivityConfig;

    private var _curBuyNum:int = 1;//当前购买的数量
    private var _curCanBuyMax:int = 1;//当前能购买的最大数量
    public static const MAX_VALUE:int = 999;//购买上限值

    public function CDiscountShopActivityBuyView() {

        btn_left.clickHandler = new Handler( _onBtnLeftClick, [lab_num] );
        btn_right.clickHandler = new Handler( _onBtnRightClick, [lab_num] );
        lab_num.addEventListener( Event.CHANGE, _onTxtInputChange );

        btn_buy.clickHandler = new Handler( _onBtnBuyClick );
    }

    public function initShow(system:CAppSystem, discountConfig:DiscounterActivityConfig):void
    {
        m_system = system;
        m_config = discountConfig;

        _curBuyNum = 1;
        if(m_config.type == CActivityHallActivityType.SERVER_LIMIT)
        {
            //全服限购一次买一个
            _curCanBuyMax = 1;
        }
        else if(m_config.type == CActivityHallActivityType.NO_LIMIT)
        {
            _curCanBuyMax = 999;
        }
        else
        {
            var buyTimes:int = activityHallDataManager.getCanBuyTimesInShop(discountConfig.type, discountConfig.goodsID);
            _curCanBuyMax = buyTimes;
        }

        var itemTable:Item = shopSysTem.getItemTableByID(discountConfig.goodsID);
        itemUI.clip_bg.index = itemTable.quality;//品质框
        itemUI.img.url = itemTable.bigiconURL + ".png";//资源路径
        itemUI.txt_num.text = "1";//数量

        var typeName : String = "unknown";
        if (CLang.hasKey("item_page_" + itemTable.page)) {
            typeName = CLang.Get("item_page_" + itemTable.page);
        } else {
            typeName = CLang.Get("item_page_4");
        }
        lab_type.text = "[" + typeName + "]";

        var bagData : CBagData = (bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(itemTable.ID);
        var num : int;
        if (bagData) {
            num = bagData.num;
        }

        lab_have.text = CLang.Get("item_has_num", {v1:num});//拥有数量
        box_zk.visible = false;//折扣标签
//        clip_z.frame = _curShopItem.discount;//折扣
        lab_name.text = HtmlUtil.getHtmlText(itemTable.name,CQualityColor.getColorByQuality(itemTable.quality-1),16) ;//名称
        lab_dic.text = itemTable.literatureDescription;//物品描述
        lab_num.text = _curBuyNum.toString();

        var currencyTable:Currency = shopSysTem.getCurrencyTableByID(discountConfig.currencyType);
        if(currencyTable){
            img_priceIcon.url = shopSysTem.getIconPath(currencyTable.source);//货币类型图标
        }

        this.box_bottom.y = this.lab_dic.y + this.lab_dic.height + 6;
        this.img_bg.height = this.box_bottom.y + this.box_bottom.height + 20;

        _updatePriceTxt();
    }

    private function _onBtnLeftClick( txtInput:TextInput ) : void {
        _curBuyNum--;
        if( _curBuyNum < 1)_curBuyNum = 1;
        txtInput.text = _curBuyNum.toString();
        _updatePriceTxt();
    }

    private function _onBtnRightClick( txtInput:TextInput ) : void {
        _curBuyNum++;
        if( _curBuyNum > _curCanBuyMax ){
            _curBuyNum = _curCanBuyMax;
            uiSysTem.showMsgAlert(CLang.LANG_00012 + _curBuyNum);
        }
        if(_curBuyNum >= MAX_VALUE){
            _curBuyNum = MAX_VALUE;
        }
        txtInput.text = _curBuyNum.toString();
        _updatePriceTxt();
    }

    private function _onTxtInputChange( event : Event ) : void {
        var txt:TextInput = event.currentTarget as TextInput;
        _curBuyNum = int(txt.text);
        if(_curBuyNum > MAX_VALUE){
            _curBuyNum = MAX_VALUE;
            txt.text = _curBuyNum.toString();
        }
        _updatePriceTxt();
    }

    private function _updatePriceTxt() : void {
        lab_buyNum.text = _curBuyNum + CLang.LANG_00013;//总件数
        lab_priceTotal.text = Math.ceil(m_config.discountPrice*_curBuyNum).toString();//总价
    }

    /**
     * 点击购买按钮
     */
    private function _onBtnBuyClick() : void {
        if( _curBuyNum > _curCanBuyMax ){
            _curBuyNum = _curCanBuyMax;
            lab_num.text = _curBuyNum.toString();
            _updatePriceTxt();
            uiSysTem.showMsgAlert(CLang.LANG_00012 + _curBuyNum);
        }
        else{
            var totalCost:int = Math.ceil(m_config.discountPrice*_curBuyNum);

            if(m_config.currencyType == ECurrencyType.BIND_DIAMOND){
//                var purpleDiamond:int = playSystem.playerData.currency.purpleDiamond;
                (m_system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( totalCost, _buy );

//                if(totalCost > purpleDiamond)
//                {
//                    var haveDiamond:int = playSystem.playerData.currency.purpleDiamond + playSystem.playerData.currency.blueDiamond;
//                    if(haveDiamond >= totalCost)
//                    {
//                        recippcalTem.showCostBdDiamondMsgBox(totalCost,function():void{
//                            (m_system.getBean(CActivityHallHandler) as CActivityHallHandler).onBuyDiscountGoodsRequest(m_config.activityID, m_config.goodsID, m_config.type, _curBuyNum);
//                            close();
//                        });
//                        return;
//                    }
//                }
            }
            else if(m_config.currencyType == ECurrencyType.DIAMOND)
            {
                var playerSystem:CPlayerSystem = m_system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var haveDiamond : int = playerSystem.playerData.currency.blueDiamond;
                //钻石跟绑钻都不足的时候，弹出充值界面
                if(totalCost > haveDiamond)
                {
                    var bundleCtx:ISystemBundleContext = m_system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                    var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                    bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                    (m_system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("很抱歉，您的钻石不足，请前往获得");
                }
                else
                {
                    _buy();
                }
            }

            close();
        }
    }

    private function _buy():void
    {
        (m_system.getBean(CActivityHallHandler) as CActivityHallHandler).onBuyDiscountGoodsRequest(m_config.activityID, m_config.goodsID, m_config.type, _curBuyNum);
    }

    override public function close(type:String = null):void {
        super.close(type);

//        m_system = null;
//        m_config = null;
    }

    private function get uiSysTem() : CUISystem {
        return m_system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get bagSystem() : CBagSystem {
        return m_system.stage.getSystem(CBagSystem) as CBagSystem;
    }

    private function get shopSysTem() : CShopSystem {
        return m_system.stage.getSystem(CShopSystem) as CShopSystem;
    }

    private function get recippcalTem() : CReciprocalSystem {
        return m_system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
    }

    private function get playSystem() : CPlayerSystem {
        return m_system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get activityHallDataManager() : CActivityHallDataManager
    {
        return m_system.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
