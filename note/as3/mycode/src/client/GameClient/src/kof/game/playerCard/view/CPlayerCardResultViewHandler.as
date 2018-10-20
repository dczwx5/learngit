//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/13.
 */
package kof.game.playerCard.view {

import com.greensock.TweenMax;

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.heroGet.CHeroGetViewHandler;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.data.CPlayerCardData;
import kof.game.playerCard.data.CPlayerCardData;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.event.CPlayerCardEvent;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.CTransformSpr;
import kof.game.playerCard.util.ECardResultType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.playerCard.PlayerCardHeroRenderUI;
import kof.ui.master.playerCard.PlayerCardResultUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CPlayerCardResultViewHandler extends CViewHandler {

    private var m_pViewUI : PlayerCardResultUI;
    private var m_bViewInitialized : Boolean;
    private var m_iViewType:int;
    private var m_iResultType:int;
    private var m_listResultData:Array = [];
    private var m_listTempArr:Array = [];
    private var m_pCardItem:PlayerCardHeroRenderUI;
    private var m_pTransformSpr:CTransformSpr;
    private var m_iCurrFlyIndex:int;

    public function CPlayerCardResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    override public function get viewClass() : Array
    {
        return [PlayerCardResultUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["frameclip_item.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
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
                m_pViewUI = new PlayerCardResultUI();

                m_pViewUI.list_item.renderHandler = new Handler( _renderItem );

                m_bViewInitialized = true;
            }

//            if(!m_pCardItem)
//            {
//                m_pCardItem = new PlayerCardHeroRenderUI();
//                m_pViewUI.addChild(m_pCardItem);
//                m_pCardItem.visible = false;
//            }
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
        var isAddPopup:Boolean;
        if(!m_pViewUI.parent)
        {
            uiCanvas.addPopupDialog( m_pViewUI );
            m_pViewUI.visible = true;
            _addListeners();
            isAddPopup = true;
        }

        _clear();
        updateData();
        _initView();

        if(isAddPopup)
        {
            _animation();
            delayCall(0.5, _flyItem2);
        }
        else
        {
            m_pViewUI.clip_bgEffect.visible = true;
            m_pViewUI.clip_bgEffect.gotoAndStop(4);
            delayCall(0.2, _flyItem2);
//            _flyItem2();
        }
    }

    private function _removeDisplay():void
    {
        _removeListeners();

        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }

        m_pViewUI.clip_bgEffect.gotoAndStop(1);
        m_pViewUI.clip_bgEffect.visible = false;

        var effectView:CPlayerCardEffectViewHandler = system.getHandler(CPlayerCardEffectViewHandler) as CPlayerCardEffectViewHandler;
        if(effectView && effectView.isViewShow)
        {
            effectView.removeDisplay();
        }

        _clear();
    }

    public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            _removeDisplay();
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_again.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_confirm.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.checkBox_skip.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_again.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_confirm.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.checkBox_skip.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }
    }

    private function _initView():void
    {
        updateDisplay();

        m_pViewUI.box_title.visible = false;
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        if(e.target == m_pViewUI.checkBox_skip)
        {
            CPlayerCardUtil.IsSkipAnimation = m_pViewUI.checkBox_skip.selected;
            return;
        }

        if(CPlayerCardUtil.IsInPumping)
        {
            _showTipInfo(CLang.Get("playerCard_zzckz"),CMsgAlertHandler.WARNING);
            return;
        }

        if( e.target == m_pViewUI.btn_again)
        {
//            var consumeNum:int;
//            switch (m_iResultType)
//            {
//                case ECardResultType.Type_One:
//                case ECardResultType.Type_Free:
//                    consumeNum = CPlayerCardConst.Consume_Num_One;
//                    break;
//                case ECardResultType.Type_Ten:
//                    consumeNum = CPlayerCardConst.Consume_Num_Ten;
//                    break;
//                case ECardResultType.Type_Fifty:
//                    consumeNum = CPlayerCardConst.Consume_Num_Fifty;
//                    break;
//            }
//
//            if(m_iResultType == ECardResultType.Type_Free)
//            {
//                if(!CPlayerCardUtil.isCanFreeTry())
//                {
//                    _showTipInfo(CLang.Get("playerCard_timeOver"),CMsgAlertHandler.WARNING);
//                    return;
//                }
//
//                if(CPlayerCardUtil.isInCD())
//                {
//                    _showTipInfo(CLang.Get("playerCard_timeCD"),CMsgAlertHandler.WARNING);
//                    return;
//                }
//
//                if(m_pViewUI.txt_consumeNum.color == 0xff0000)
//                {
//                    _showTipInfo(CLang.Get("playerCard_prop_notEnough"),CMsgAlertHandler.WARNING);
//                    _removeDisplay();
//                    return;
//                }
//
//                (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardFreeRequest(m_iViewType);
//                CPlayerCardUtil.IsInPumping = true;
//            }
//            else
//            {
                if(m_pViewUI.txt_consumeNum.color == 0xff0000)
                {
                    _showQuickBuyShop();
                    return;
                }

                if(!CPlayerCardUtil.IsSkipAnimation)
                {
                    _removeDisplay();

                    CPlayerCardUtil.IsInPumping = true;

                    var obj:Object = {};
                    obj.viewType = m_iViewType;
                    obj.numType = m_iResultType;
                    system.dispatchEvent(new CPlayerCardEvent(CPlayerCardEvent.PumpCard, obj));
                }
                else
                {
                    (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(m_iViewType, _consumeNum);
                    CPlayerCardUtil.IsInPumping = true;
                    CGameStatus.setStatus(CGameStatus.Status_PlayerCard);
                }
//            }
        }

        if( e.target == m_pViewUI.btn_confirm)
        {
            _removeDisplay();
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
            _updateTicketState();
        }
    }

    override protected function updateDisplay():void
    {
        _updateBg();
        _updateTitleInfo();
        _updateItemList();
        _updateTicketState();
        _updateBtnState();
        _updateListPos();
        _updateCheckBox();
    }

    override protected function updateData():void
    {
        switch(m_iResultType)
        {
            case ECardResultType.Type_One:
            case ECardResultType.Type_Ten:
                m_listResultData = (system.getHandler(CPlayerCardManager) as CPlayerCardManager).cardResultData.slice();
                break;
            case ECardResultType.Type_Free:
                m_listResultData = (system.getHandler(CPlayerCardManager) as CPlayerCardManager).cardFreeResultData.slice();
                break;
        }
    }

    private function _updateBg():void
    {
        m_pViewUI.clip_bgEffect.visible = false;
        m_pViewUI.img_bg.width = system.stage.flashStage.stageWidth;
        m_pViewUI.img_bg.height = system.stage.flashStage.stageHeight;

        m_pViewUI.img_bg.x = 1000 - m_pViewUI.img_bg.width >> 1;
        m_pViewUI.img_bg.y = 600 - m_pViewUI.img_bg.height >> 1;
    }

    private function _updateTitleInfo():void
    {
        var num:int;
        switch (m_iResultType)
        {
            case ECardResultType.Type_One:
            case ECardResultType.Type_Free:
                num = CPlayerCardConst.Consume_Num_One;
                break;
            case ECardResultType.Type_Ten:
                num = CPlayerCardConst.Consume_Num_Ten;
                break;
            case ECardResultType.Type_Fifty:
                num = CPlayerCardConst.Consume_Num_Fifty;
                break;
        }

        var hasHeroCard:Boolean;
        for(var i:int = 0; i < m_listResultData.length; i++)
        {
            var cardData:CPlayerCardData = m_listResultData[i] as CPlayerCardData;
            if(cardData)
            {
                if(cardData.roleId || (cardData.itemData && CItemUtil.isHeroItem(cardData.itemData)))
                {
                    hasHeroCard = true;
                    break;
                }
            }
        }

        m_pViewUI.img_title_getHero.visible = hasHeroCard;
        m_pViewUI.img_title_notHero.visible = !hasHeroCard;
    }

    private function _updateItemList():void
    {
        m_pViewUI.list_item.dataSource = m_listResultData;
    }

    /**
     * 更新拥有酒券状态
     */
    private function _updateTicketState():void
    {
        var consumeNum:int;
        if(m_iResultType == ECardResultType.Type_Free)
        {
            consumeNum = CPlayerCardConst.Consume_Num_One;
        }
        else
        {
            consumeNum = m_iResultType == ECardResultType.Type_One ? CPlayerCardConst.Consume_Num_One:
                    CPlayerCardConst.Consume_Num_Ten;
        }

        switch (m_iViewType)
        {
            case ECardViewType.Type_Common:
                var ownCommonNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Common_Card_Id);
                m_pViewUI.txt_consumeNum.color = ownCommonNum >= consumeNum ? 0xffffff : 0xff0000;
                break;
            case ECardViewType.Type_Better:
                var ownBetterNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Better_Card_Id);
                m_pViewUI.txt_consumeNum.color = ownBetterNum >= consumeNum ? 0xffffff : 0xff0000;
                break;
            case ECardViewType.Type_Active:
                var ownActiveNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Active_Card_Id);
                m_pViewUI.txt_consumeNum.color = ownActiveNum >= consumeNum ? 0xffffff : 0xff0000;
                break;
        }
    }

    private function _updateBtnState():void
    {
        switch (m_iResultType)
        {
            case ECardResultType.Type_One:
            case ECardResultType.Type_Free:
                m_pViewUI.btn_again.label = CLang.Get("playerCard_zlyb");
                m_pViewUI.txt_consumeNum.text = "1";
                break;
            case ECardResultType.Type_Ten:
                m_pViewUI.btn_again.label = CLang.Get("playerCard_zlsb");
                m_pViewUI.txt_consumeNum.text = "10";
                break;
            case ECardResultType.Type_Fifty:
                m_pViewUI.btn_again.label = CLang.Get("playerCard_zlwsb");
                m_pViewUI.txt_consumeNum.text = "50";
                break;
        }

        switch (m_iViewType)
        {
            case ECardViewType.Type_Common:
                m_pViewUI.img_currency.skin = "png.playerCard.icon_ticket_01";
                break;
            case ECardViewType.Type_Better:
            case ECardViewType.Type_Active:
                m_pViewUI.img_currency.skin = "png.playerCard.icon_ticket_02";
                break;
        }

//        m_pViewUI.txt_consumeNum.visible = m_iResultType != ECardResultType.Type_Free;
//        m_pViewUI.img_currency.visible = m_iResultType != ECardResultType.Type_Free;
    }

    private function _updateListPos():void
    {
        if(m_iResultType == ECardResultType.Type_One || m_iResultType == ECardResultType.Type_Free)
        {
            m_pViewUI.list_item.x = m_pViewUI.width - 80 >> 1;
            m_pViewUI.list_item.y = m_pViewUI.height - 80 >> 1;
        }
        else
        {
            m_pViewUI.list_item.x = 273;
            m_pViewUI.list_item.y = 224;
        }
    }

    private function _updateCheckBox():void
    {
        m_pViewUI.checkBox_skip.selected = CPlayerCardUtil.IsSkipAnimation;
    }

    private function _renderItem(item:Component, index:int):void
    {
        if(!(item is PlayerCardHeroRenderUI))
        {
            return;
        }

        var heroItem:PlayerCardHeroRenderUI = item as PlayerCardHeroRenderUI;
        heroItem.mouseChildren = false;
        heroItem.mouseEnabled = true;
        heroItem.item.circle_effect.visible = false;
        heroItem.item.circle_effect.mouseEnabled = false;
        heroItem.visible = false;

        var cardData:CPlayerCardData = heroItem.dataSource as CPlayerCardData;
        if(cardData && cardData.itemData)
        {
            heroItem.item.img.url = cardData.itemData.iconBig;
            heroItem.item.clip_bg.index = cardData.itemData.quality;
            heroItem.item.txt_num.text = cardData.count.toString();

//            if(CPlayerCardUtil.isHeroCardItem(cardData.itemId))
//            {
            if(CItemUtil.isHeroItem(cardData.itemData))
            {
                var cardInfo:Object = CPlayerCardUtil.getHeroCardInfo(cardData.itemId);
                var heroData:CPlayerHeroData = CPlayerCardUtil.getHeroDataById(cardInfo.roleId);
                heroItem.aptitude_lock_cliip.visible = true;
                heroItem.aptitude_lock_cliip.index = heroData == null ? 0 : heroData.qualityBaseType;
                heroItem.list_star.dataSource = new Array(cardInfo.star);
                heroItem.item.txt_num.text = "";
            }
            else
            {
                heroItem.aptitude_lock_cliip.visible = false;
                heroItem.list_star.dataSource = [];
            }

            heroItem.item.box_effect.visible = cardData.itemData.effect;

//            if(index >= m_pViewUI.list_item.dataSource.length - 1)
//            {
//                heroItem.clip_effect.visible = true;
//                heroItem.clip_effect.playFromTo(null,null,new Handler(_onAnimationComplHandler));
//
//                function _onAnimationComplHandler():void
//                {
//                    heroItem.clip_effect.gotoAndStop(1);
//                    heroItem.clip_effect.visible = false;
//                }
//            }

            heroItem.toolTip = new Handler( _showTips, [heroItem,cardData.itemId] );
        }
        else
        {
            heroItem.item.img.url = "";
            heroItem.item.txt_num.text = "";
            heroItem.item.clip_bg.index = 0;
            heroItem.aptitude_lock_cliip.visible = false;
            heroItem.list_star.dataSource = [];
            heroItem.item.circle_effect.visible = false;
            heroItem.item.box_effect.visible = false;
        }
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:Component,itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item,[itemId]);
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    protected function _showTipInfo(str:String, type:int):void
    {
        (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    private function _animation():void
    {
        m_pViewUI.clip_bgEffect.visible = true;
        m_pViewUI.clip_bgEffect.playFromTo(null,null,new Handler(_onAnimationComplHandler));

        function _onAnimationComplHandler():void
        {
        }
    }

    private function _flyItem():void
    {
        if(m_listResultData.length)
        {
            m_pViewUI.box_title.visible = true;

            var cardData:CPlayerCardData = m_listResultData.shift();

            if(cardData)
            {
                var fromX:int = m_pViewUI.width - m_pCardItem.width >> 1;
                var fromY:int = 32;
                var length:int = m_pViewUI.list_item.dataSource.length;
                var toX:int = m_pViewUI.list_item.x + (m_pViewUI.list_item.spaceX + 80) * int(length % 5);
                var toY:int = m_pViewUI.list_item.y + (m_pViewUI.list_item.spaceY + 80) * int(length / 5);

                m_pCardItem.visible = true;
                m_pCardItem.dataSource = cardData;
                m_pCardItem.x = fromX;
                m_pCardItem.y = fromY;
                _renderItem(m_pCardItem,-1);

                if(m_pTransformSpr == null)
                {
                    m_pTransformSpr = new CTransformSpr();
                }

                TweenMax.fromTo(m_pCardItem, 0.15, {
                    x:fromX,
                    y:fromY,
                    scale:0.3
//                    rotation:0
                }, {
                    x:toX,
                    y:toY,
                    scale:1.5,
//                    rotation:720,
                    onComplete:_onCompleteHandler,
                    onCompleteParams:[cardData]}
                );

//                m_bIsPumping = true;
            }
        }
    }

    private function _flyItem2():void
    {
        if(m_iCurrFlyIndex < m_listResultData.length)
        {
            m_pViewUI.box_title.visible = true;
            var cardItem:PlayerCardHeroRenderUI = m_pViewUI.list_item.getCell(m_iCurrFlyIndex) as PlayerCardHeroRenderUI;
            if(cardItem)
            {
                var fromX:int = ((m_pViewUI.list_item.spaceX + 80) * m_pViewUI.list_item.repeatX - m_pViewUI.list_item.spaceX >> 1)-10;
                var fromY:int = -132;
                var toX:int = (m_pViewUI.list_item.spaceX + 80) * int(m_iCurrFlyIndex % 5);
                var toY:int = (m_pViewUI.list_item.spaceY + 80) * int(m_iCurrFlyIndex / 5);

                var cardData:CPlayerCardData = m_listResultData[m_iCurrFlyIndex] as CPlayerCardData;
                cardItem.visible = cardData && cardData.roleId == 0;
                cardItem.x = fromX;
                cardItem.y = fromY;

                TweenMax.fromTo(cardItem, 0.15, {
                            x:fromX,
                            y:fromY,
                            scale:0.3
//                    rotation:0
                        }, {
                            x:toX,
                            y:toY,
                            scale:1,
//                    rotation:720,
                            onComplete:_onCompleteHandler,
                            onCompleteParams:[m_listResultData[m_iCurrFlyIndex]]}
                );
            }
        }
    }

    private function _onCompleteHandler(card:CPlayerCardData):void
    {
//        m_pCardItem.visible = false;
//        m_listTempArr.push(card);
//        m_pViewUI.list_item.dataSource = m_listTempArr;
        var cardItem:PlayerCardHeroRenderUI = m_pViewUI.list_item.getCell(m_iCurrFlyIndex) as PlayerCardHeroRenderUI;
        if(cardItem)
        {
            cardItem.visible = card.roleId == 0;
            cardItem.item.circle_effect.visible = true;
            cardItem.item.circle_effect.mouseEnabled = false;
            cardItem.item.circle_effect.interval = 10;
            cardItem.item.circle_effect.playFromTo(null,null,new Handler(_onAnimationComplHandler));

            function _onAnimationComplHandler():void
            {
                cardItem.item.circle_effect.stop();
                cardItem.item.circle_effect.visible = false;
                cardItem.item.circle_effect.mouseEnabled = false;
            }
        }
        m_iCurrFlyIndex++;

        if(card.roleId)// 展示整卡
        {
            delayCall(0.1,function():void
            {
                var playerUIHandler:CPlayerUIHandler = system.stage.getSystem(CPlayerSystem).getHandler(CPlayerUIHandler ) as CPlayerUIHandler;
//                playerUIHandler.hideCallBack = _continueFlyItem;

                var heroGetView:CHeroGetViewHandler = (system.stage.getSystem(CPlayerSystem)
                        as CPlayerSystem).getHandler( CHeroGetViewHandler) as CHeroGetViewHandler;
                heroGetView.hideCallBack = _continueFlyItem;
                heroGetView.showCallBack = _onCallBackShow;

                CPlayerCardUtil.showHeroGetView(card);
            });
        }
        else
        {
            _continueFlyItem();
        }
    }

    private function _continueFlyItem():void
    {
        if(m_iCurrFlyIndex < m_listResultData.length)
        {
            _flyItem2();
        }
        else
        {
            CPlayerCardUtil.IsInPumping = false;
            CGameStatus.unSetStatus(CGameStatus.Status_PlayerCard);
            m_iCurrFlyIndex = 0;

//            var playerUIHandler:CPlayerUIHandler = system.stage.getSystem(CPlayerSystem).getHandler(CPlayerUIHandler ) as CPlayerUIHandler;
//            playerUIHandler.hideCallBack = null;

            var heroGetView:CHeroGetViewHandler = (system.stage.getSystem(CPlayerSystem)
                    as CPlayerSystem).getHandler( CHeroGetViewHandler) as CHeroGetViewHandler;
            heroGetView.hideCallBack = null;
            heroGetView.showCallBack = null;
        }
    }

    private function _onCallBackShow():void
    {
        var cardItem:PlayerCardHeroRenderUI = m_pViewUI.list_item.getCell(m_iCurrFlyIndex-1) as PlayerCardHeroRenderUI;
        if(cardItem)
        {
            cardItem.visible = true;
        }
    }

    private function _showQuickBuyShop():void
    {
        var shopData:CShopItemData = CPlayerCardUtil.getShopData(_consumeItemId);
        if(shopData == null)
        {
            _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
            return;
        }

        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem).getHandler(CShopBuyViewHandler)
                as CShopBuyViewHandler;
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(_consumeItemId);
        var buyNum:int = _consumeNum - ownNum;
        buyViewHandler.show(0, shopData, buyNum, false);
    }

    private function get _consumeItemId():int
    {
        var itemId:int;
        switch(m_iViewType)
        {
            case ECardViewType.Type_Common:
                itemId = CPlayerCardConst.Common_Card_Id;
                break;
            case ECardViewType.Type_Better:
                itemId = CPlayerCardConst.Better_Card_Id;
                break;
            case ECardViewType.Type_Active:
                itemId = CPlayerCardConst.Active_Card_Id;
                break;
        }

        return itemId;
    }

    private function get _consumeNum():int
    {
        var consumeNum:int;
        switch (m_iResultType)
        {
            case ECardResultType.Type_One:
            case ECardResultType.Type_Free:
                consumeNum = CPlayerCardConst.Consume_Num_One;
                break;
            case ECardResultType.Type_Ten:
                consumeNum = CPlayerCardConst.Consume_Num_Ten;
                break;
            case ECardResultType.Type_Fifty:
                consumeNum = CPlayerCardConst.Consume_Num_Fifty;
                break;
        }

        return consumeNum;
    }

    public function set viewType(value:int):void
    {
        m_iViewType = value;
    }

    public function set resultType(value:int):void
    {
        m_iResultType = value;
    }

    public function _clear():void
    {
        m_pViewUI.list_item.dataSource = [];
        m_listResultData.length = 0;
        m_listTempArr.length = 0;
        m_iCurrFlyIndex = 0;

        var playerUIHandler:CPlayerUIHandler = system.stage.getSystem(CPlayerSystem).getHandler(CPlayerUIHandler ) as CPlayerUIHandler;
        playerUIHandler.hideCallBack = null;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
