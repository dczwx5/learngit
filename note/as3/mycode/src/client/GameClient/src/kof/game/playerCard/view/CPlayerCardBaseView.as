//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/15.
 */
package kof.game.playerCard.view {

import QFLib.Interface.IDisposable;

import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.CLang;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.playerCard.view.CPlayerCardActiveViewHandler;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

import morn.core.components.Button;

import morn.core.components.View;

public class CPlayerCardBaseView implements IDisposable{

    protected var m_pViewUI:View;
    protected var m_iViewType:int;
    protected var m_pSystem:CAppSystem;

    public function CPlayerCardBaseView(system:CAppSystem)
    {
        m_pSystem = system;
    }

    public function addListeners():void
    {
        if(m_pViewUI)
        {
            var tipBtn:Button = m_pViewUI.getChildByName("btn_tip") as Button;
            tipBtn.addEventListener(MouseEvent.CLICK, _onTipBtnClickHandler);
        }

        if(m_pSystem.stage.getSystem(CBagSystem))
        {
            (m_pSystem.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }
    }

    public function removeListeners():void
    {
        if(m_pViewUI)
        {
            var tipBtn:Button = m_pViewUI.getChildByName("btn_tip") as Button;
            tipBtn.removeEventListener(MouseEvent.CLICK, _onTipBtnClickHandler);
        }

        if(m_pSystem.stage.getSystem(CBagSystem))
        {
            (m_pSystem.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }
    }

    private function _onTipBtnClickHandler(e:MouseEvent):void
    {
        var poolView:CPlayerCardPoolViewHandler = m_pSystem.getHandler(CPlayerCardPoolViewHandler) as CPlayerCardPoolViewHandler;
        switch (m_iViewType)
        {
            case ECardViewType.Type_Common:
                poolView.cardPoolType = ECardPoolType.Type_Common;
                break;
            case ECardViewType.Type_Better:
                poolView.cardPoolType = ECardPoolType.Type_Better;
                break;
            case ECardViewType.Type_Active:
                poolView.cardPoolType = ECardPoolType.Type_Active;
                break;
        }

        poolView.addDisplay();
    }

    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            updateTicketState();
        }
    }

    protected function initializeView():void
    {
    }

    /**
     * 更新拥有酒券状态
     */
    protected function updateTicketState():void
    {
    }

    /**
     * 更新底部提示信息
     */
    protected function updateTipInfo():void
    {
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    protected function _showTipInfo(str:String, type:int):void
    {
        (m_pSystem.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    /**
     * 快速购买
     */
    protected function _showQuickBuyShop(itemId:int,buyNum:int = 1,isShowRecharge:Boolean = false):void
    {
        var shopData:CShopItemData = CPlayerCardUtil.getShopData(itemId);
        if(shopData == null)
        {
            _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
            return;
        }

        var buyViewHandler:CShopBuyViewHandler = m_pSystem.stage.getSystem(CShopSystem).getHandler(CShopBuyViewHandler)
                as CShopBuyViewHandler;
        buyViewHandler.show(0,shopData,buyNum,isShowRecharge);
    }

    public function updateDisplay():void
    {
    }

    public function updateNumInfo():void
    {

    }

    public function set viewUI(value:View):void
    {
        m_pViewUI = value;
    }

    public function get viewUI():View
    {
        return m_pViewUI;
    }

    public function set viewType(value:int):void
    {
        m_iViewType = value;

        initializeView();
    }

    public function dispose() : void
    {
    }
}
}
