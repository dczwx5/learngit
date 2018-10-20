//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/9.
 */
package kof.game.playerCard.view {

import QFLib.Foundation.CMap;
import QFLib.Utils.Debug.Debug;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.playerCard.PlayerCardMainViewUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.Image;

import morn.core.handlers.Handler;

public class CPlayerCardViewHandler extends CTweenViewHandler{

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : PlayerCardMainViewUI;
    private var m_pCloseHandler : Handler;

    /** 小酌一番view */
    private var m_pCommonView:CPlayerCardBaseView;
    /** 嗨翻全场view */
    private var m_pBetterView:CPlayerCardBaseView;
    /** 活动畅饮view */
    private var m_pActiveView:CPlayerCardBaseView;

    public function CPlayerCardViewHandler()
    {
        super(false);
    }

    override public function get viewClass() : Array
    {
        return [ PlayerCardMainViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_playerCard_pump.swf","frameclip_playerCard_result.swf"];
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new PlayerCardMainViewUI();

                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pCommonView = new CPlayerCardCommonView(system);
                m_pCommonView.viewUI = m_pViewUI.view_left;
                m_pCommonView.viewType = ECardViewType.Type_Common;

                m_pBetterView = new CPlayerCardBetterView(system);
                m_pBetterView.viewUI = m_pViewUI.view_mid;
                m_pBetterView.viewType = ECardViewType.Type_Better;

                m_pActiveView = new CPlayerCardActiveView(system);
//                m_pActiveView.viewUI = m_pViewUI.view_right;
//                m_pActiveView.viewType = ECardViewType.Type_Active;

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        setTweenData(KOFSysTags.CARDPLAYER);
        showDialog(m_pViewUI, false, _onShowEnd);

        m_pViewUI.visible = true;
    }

    private function _onShowEnd():void
    {
        _initView();
        _addListeners();

        if(!CPlayerCardUtil.HasOpenRequested)// 只需第一次打开的时候请求
        {
            _reqInfo();
            CPlayerCardUtil.HasOpenRequested = true;
        }
    }

    public function removeDisplay() : void
    {
        closeDialog(_removeDisplayB);
    }

    private function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            m_pCommonView.dispose();
            m_pBetterView.dispose();
//            m_pActiveView.dispose();

            var effectView:CPlayerCardEffectViewHandler = system.getHandler(CPlayerCardEffectViewHandler) as CPlayerCardEffectViewHandler;
            if(effectView && effectView.isViewShow)
            {
                effectView.removeDisplay();
            }

            var resultView:CPlayerCardResultViewHandler = system.getHandler(CPlayerCardResultViewHandler) as CPlayerCardResultViewHandler;
            if(resultView && resultView.isViewShow)
            {
                resultView.removeDisplay();
            }

            CPlayerCardUtil.IsInPumping = false;
            CGameStatus.unSetStatus(CGameStatus.Status_PlayerCard);
        }
    }

    private function _initView():void
    {
        updateDisplay();

        // 暂时屏蔽欧气商店入口
//        m_pViewUI.btn_eurShop.visible = false;
//        m_pViewUI.box_top.x = 360;
//        m_pViewUI.img_eur.visible = false;
//        m_pViewUI.txt_ownEurNum.visible = false;
//        m_pViewUI.img_euroBg.visible = false;
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_addCommonCard.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_addBetterCard.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_eurShop.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        m_pCommonView.addListeners();
        m_pBetterView.addListeners();
//        m_pActiveView.addListeners();

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.PLAYER_HERO_CARD,_onPlayerInfoUpdateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_addCommonCard.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_addBetterCard.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_eurShop.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        m_pCommonView.removeListeners();
        m_pBetterView.removeListeners();
//        m_pActiveView.removeListeners();

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.PLAYER_HERO_CARD,_onPlayerInfoUpdateHandler);
    }

    private function _reqInfo():void
    {
        (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).cardPlayerOpenRequest();
    }

    override protected function updateDisplay():void
    {
        _updateOwnTicketInfo();
        _updateCurrCount();
        _updateHeroImg();
        _updatePos();

        m_pCommonView.updateDisplay();
        m_pBetterView.updateDisplay();
//        m_pActiveView.updateDisplay();
    }

    /**
     * 拥有的酒券和欧比信息
     */
    private function _updateOwnTicketInfo():void
    {
        var commonNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Common_Card_Id);
        var betterNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Better_Card_Id);
        var pCPlayerData : CPlayerData = (_playerSystem.getBean( CPlayerManager ) as CPlayerManager).playerData;

        m_pViewUI.txt_ownCommonNum.text = commonNum.toString();
        m_pViewUI.txt_ownBetterNum.text = betterNum.toString();
        m_pViewUI.txt_ownEurNum.text = pCPlayerData.currency.euro.toString();

        if(m_pViewUI.img_commonCard.toolTip == null)
        {
            m_pViewUI.img_commonCard.toolTip = new Handler( _showTips, [m_pViewUI.img_commonCard,CPlayerCardConst.Common_Card_Id] );
        }

        if(m_pViewUI.img_betterCard.toolTip == null)
        {
            m_pViewUI.img_betterCard.toolTip = new Handler( _showTips, [m_pViewUI.img_betterCard,CPlayerCardConst.Better_Card_Id] );
        }

        if(m_pViewUI.img_eur.toolTip == null)
        {
            m_pViewUI.img_eur.toolTip = new Handler( _showTips, [m_pViewUI.img_eur,CPlayerCardConst.Currency_Ou_Id] );
        }
    }

    /**
     * 当前次数
     */
    private function _updateCurrCount():void
    {
        m_pViewUI.txt_currCount_common.visible = false;
        m_pViewUI.txt_currCount_better.visible = false;
        m_pViewUI.txt_currCount_active.visible = false;

        CONFIG::debug
        {
            var currNumMap:CMap = (system.getHandler(CPlayerCardManager ) as CPlayerCardManager).currNumMap;

            var commonNum:int = currNumMap.find(ECardPoolType.Type_Common) ? currNumMap.find(ECardPoolType.Type_Common) : 0;
            var betterNum:int = currNumMap.find(ECardPoolType.Type_Better) ? currNumMap.find(ECardPoolType.Type_Better) : 0;
            var activeNum:int = currNumMap.find(ECardPoolType.Type_Active) ? currNumMap.find(ECardPoolType.Type_Active) : 0;

            m_pViewUI.txt_currCount_common.text = "普通次数：" + commonNum.toString();
            m_pViewUI.txt_currCount_better.text = "高级次数：" + betterNum.toString();
            m_pViewUI.txt_currCount_active.text = "活动次数：" + activeNum.toString();
        }
    }

    /**
     * 琼的靓照
     */
    private function _updateHeroImg():void
    {
//        m_pViewUI.img_joan.url = CPlayerPath.getPeakUIHeroFacePath(108);
    }

    private function _updatePos():void
    {
        if(CPlayerCardUtil.isInActiveTime())
        {
//            m_pCommonView.viewUI.x = 108;
//            m_pBetterView.viewUI.x = 379;
//            m_pActiveView.viewUI.x = 651;
//            m_pActiveView.viewUI.visible = true;
        }
        else
        {
//            m_pCommonView.viewUI.x = 365;
//            m_pBetterView.viewUI.x = 655;
//            m_pActiveView.viewUI.visible = false;
        }
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem ).getHandler(CShopBuyViewHandler )
                as CShopBuyViewHandler;
        if( e.target == m_pViewUI.btn_addCommonCard)
        {
            var shopData:CShopItemData = CPlayerCardUtil.getShopData(CPlayerCardConst.Common_Card_Id);
            if(shopData == null)
            {
                _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
                return;
            }

            buyViewHandler.show(0, shopData);
        }

        if( e.target == m_pViewUI.btn_addBetterCard)
        {
            shopData = CPlayerCardUtil.getShopData(CPlayerCardConst.Better_Card_Id);
            if(shopData == null)
            {
                _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
                return;
            }

            buyViewHandler.show(0, shopData);
        }

        if( e.target == m_pViewUI.btn_eurShop)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
            bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_12]);
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }
    }

    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            _updateOwnTicketInfo();
        }
    }

    /**
     * 欧币更新
     * @param e
     */
    private function _onPlayerInfoUpdateHandler(e:CPlayerEvent):void
    {
        var pCPlayerData : CPlayerData = (_playerSystem.getBean( CPlayerManager ) as CPlayerManager).playerData;

        m_pViewUI.txt_ownEurNum.text = pCPlayerData.currency.euro.toString();
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:Component,itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item,[itemId]);
    }

    protected function _showTipInfo(str:String, type:int):void
    {
        (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    /**
     * 当前抽卡次数
     */
    public function updateCurrCount():void
    {
        _updateCurrCount();
        m_pCommonView.updateNumInfo();
        m_pBetterView.updateNumInfo();
    }

    private function get _playerSystem():CPlayerSystem
    {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function set isShow(value:Boolean):void
    {
        if(m_pViewUI)
        {
            m_pViewUI.visible = value;
        }
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
