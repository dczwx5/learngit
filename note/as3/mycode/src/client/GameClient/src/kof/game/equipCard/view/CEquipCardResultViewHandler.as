//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import com.greensock.TweenMax;

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.equipCard.CEquipCardManager;
import kof.game.equipCard.CEquipCardNetHandler;
import kof.game.equipCard.util.CEquipCardConst;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.data.CPlayerHeroData;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.data.CPlayerCardData;
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

public class CEquipCardResultViewHandler extends CViewHandler {
    private var m_pViewUI : PlayerCardResultUI;
    private var m_bViewInitialized : Boolean;
    private var m_iViewType:int;
    private var m_iResultType:int;
    private var m_listResultData:Array = [];
    private var m_listTempArr:Array = [];
    private var m_pCardItem:PlayerCardHeroRenderUI;
    private var m_pTransformSpr:CTransformSpr;
    private var m_iCurrFlyIndex:int;

    public function CEquipCardResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [PlayerCardResultUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override  protected function get additionalAssets() : Array
    {
        return ["frameclip_item.swf"];
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

        clear();
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
        }
    }

    private function _removeDisplay():void
    {
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }

        m_pViewUI.clip_bgEffect.gotoAndStop(1);
        m_pViewUI.clip_bgEffect.visible = false;

        _removeListeners();
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
            CEquipCardUtil.IsSkipAnimation = m_pViewUI.checkBox_skip.selected;
            return;
        }

        if(CEquipCardUtil.IsInPumping)
        {
            _showTipInfo(CLang.Get("equipCard_zznd"),CMsgAlertHandler.WARNING);
            return;
        }

        if( e.target == m_pViewUI.btn_again)
        {
            var consumeNum:int;
            switch (m_iResultType)
            {
                case ECardResultType.Type_One:
                case ECardResultType.Type_Free:
                    consumeNum = CEquipCardConst.Consume_Num_One;
                    break;
                case ECardResultType.Type_Ten:
                    consumeNum = CEquipCardConst.Consume_Num_Ten;
                    break;
                case ECardResultType.Type_Fifty:
                    consumeNum = CEquipCardConst.Consume_Num_Fifty;
                    break;
            }

            if(m_iResultType == ECardResultType.Type_Free)
            {
                if(!CPlayerCardUtil.isCanFreeTry())
                {
                    _showTipInfo(CLang.Get("playerCard_timeOver"),CMsgAlertHandler.WARNING);
                    return;
                }

                if(CPlayerCardUtil.isInCD())
                {
                    _showTipInfo(CLang.Get("playerCard_timeCD"),CMsgAlertHandler.WARNING);
                    return;
                }

                if(m_pViewUI.txt_consumeNum.color == 0xff0000)
                {
                    _showTipInfo(CLang.Get("playerCard_prop_notEnough"),CMsgAlertHandler.WARNING);
                    _removeDisplay();
                    return;
                }
            }
            else
            {
                if(m_pViewUI.txt_consumeNum.color == 0xff0000)
                {
                    _showQuickBuyShop(CEquipCardConst.Common_Card_Id);
                    return;
                }

                if(!CEquipCardUtil.IsSkipAnimation)
                {
                    _removeDisplay();
                }
                (system.getHandler(CEquipCardViewHandler) as CEquipCardViewHandler).pumpingEquip(consumeNum);
            }
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
                m_listResultData = (system.getHandler(CEquipCardManager) as CEquipCardManager).cardResultData.slice();
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
                num = CEquipCardConst.Consume_Num_One;
                break;
            case ECardResultType.Type_Ten:
                num = CEquipCardConst.Consume_Num_Ten;
                break;
            case ECardResultType.Type_Fifty:
                num = CEquipCardConst.Consume_Num_Fifty;
                break;
        }
//        m_pViewUI.txt_succGetInfo.text = CLang.Get("equipCard_hdwp");
//        m_pViewUI.txt_succGetInfo.x = m_pViewUI.width - m_pViewUI.txt_succGetInfo.width >> 1;

        m_pViewUI.img_title_getHero.visible = false;
        m_pViewUI.img_title_notHero.visible = false;
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
        var consumeNum:int = m_iResultType == ECardResultType.Type_One ? CEquipCardConst.Consume_Num_One:
                CEquipCardConst.Consume_Num_Ten;

        switch (m_iViewType)
        {
            case ECardViewType.Type_Common:
                var ownCommonNum:int = CEquipCardUtil.getOwnTicketNum(CEquipCardConst.Common_Card_Id);

                m_pViewUI.txt_consumeNum.color = ownCommonNum >= consumeNum ? 0xffffff : 0xff0000;
                break;
            case ECardViewType.Type_Better:
            case ECardViewType.Type_Active:
//                var ownBetterNum:int = CEquipCardUtil.getOwnTicketNum(CEquipCardConst.Better_Card_Id);
//                m_pViewUI.txt_consumeNum.color = ownBetterNum >= consumeNum ? 0xffffff : 0xff0000;
                break;
        }
    }

    private function _updateBtnState():void
    {
        switch (m_iResultType)
        {
            case ECardResultType.Type_One:
            case ECardResultType.Type_Free:
                m_pViewUI.btn_again.label = CLang.Get("equipCard_znyc");
                m_pViewUI.txt_consumeNum.text = "1";
                break;
            case ECardResultType.Type_Ten:
                m_pViewUI.btn_again.label = CLang.Get("equipCard_znsc");
                m_pViewUI.txt_consumeNum.text = "10";
                break;
            case ECardResultType.Type_Fifty:
                m_pViewUI.btn_again.label = CLang.Get("playerCard_zlwsb");
                m_pViewUI.txt_consumeNum.text = "50";
                break;
        }

//        m_pViewUI.btn_exit.label = CLang.Get("equipCard_lk");

        switch (m_iViewType)
        {
            case ECardViewType.Type_Common:
                m_pViewUI.img_currency.skin = "png.equipCard.img_ticket_common";
                break;
            case ECardViewType.Type_Better:
            case ECardViewType.Type_Active:
                m_pViewUI.img_currency.skin = "png.equipCard.img_ticket_better";
                break;
        }
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
        m_pViewUI.checkBox_skip.selected = CEquipCardUtil.IsSkipAnimation;
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

            if(CEquipCardUtil.isDouSoul(cardData.itemId))// 斗魂
            {
                heroItem.aptitude_lock_cliip.visible = false;
                heroItem.list_star.dataSource = [];
            }
//            else if(CPlayerCardUtil.isHeroCardItem(cardData.itemId))
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
//                heroItem.item.circle_effect.visible = true;
//                heroItem.item.circle_effect.playFromTo(null,null,new Handler(_onAnimationComplHandler));
//
//                function _onAnimationComplHandler():void
//                {
//                    heroItem.item.circle_effect.gotoAndStop(1);
//                    heroItem.item.circle_effect.visible = false;
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
            var cardData:CPlayerCardData = m_listResultData.shift();

            if(cardData)
            {
                CEquipCardUtil.IsInPumping = true;
                CGameStatus.setStatus(CGameStatus.Status_EquipCard);

                var fromX:int = m_pViewUI.width >> 1;
                var fromY:int = 0;
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

//                m_pTransformSpr.transformObj = m_pCardItem;
//                m_pViewUI.addChild(m_pTransformSpr);

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
            }
        }
    }

    private function _flyItem2():void
    {
        if(m_iCurrFlyIndex < m_listResultData.length)
        {
            var cardItem:PlayerCardHeroRenderUI = m_pViewUI.list_item.getCell(m_iCurrFlyIndex) as PlayerCardHeroRenderUI;
            if(cardItem)
            {
                CEquipCardUtil.IsInPumping = true;
                CGameStatus.setStatus(CGameStatus.Status_EquipCard);

                var fromX:int = ((m_pViewUI.list_item.spaceX + 80) * m_pViewUI.list_item.repeatX - m_pViewUI.list_item.spaceX >> 1) - 10;
                var fromY:int = -132;
                var toX:int = (m_pViewUI.list_item.spaceX + 80) * int(m_iCurrFlyIndex % 5);
                var toY:int = (m_pViewUI.list_item.spaceY + 80) * int(m_iCurrFlyIndex / 5);

                cardItem.visible = true;
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
            cardItem.visible = true;
            cardItem.item.circle_effect.visible = true;
            cardItem.item.circle_effect.mouseEnabled = false;
            cardItem.item.circle_effect.interval = 10;
            cardItem.item.circle_effect.playFromTo(null,null,new Handler(_onAnimationComplHandler));

            function _onAnimationComplHandler():void
            {
                cardItem.item.circle_effect.gotoAndStop(1);
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
                CPlayerCardUtil.showHeroGetView(card);
                playerUIHandler.hideCallBack = _continueFlyItem;
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
            CEquipCardUtil.IsInPumping = false;
            CGameStatus.unSetStatus(CGameStatus.Status_EquipCard);
            m_iCurrFlyIndex = 0;
        }
    }

    /**
     * 快速购买
     */
    private function _showQuickBuyShop(isShowRecharge:Boolean = false):void
    {
        var itemId:int = CEquipCardConst.Common_Card_Id;
        var shopData:CShopItemData = CEquipCardUtil.getShopData(itemId);
        if(shopData == null)
        {
            _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
            return;
        }

        var buyNum:int;
        if(m_iResultType == ECardResultType.Type_One)
        {
            buyNum = CEquipCardConst.Consume_Num_One;
        }
        else if(m_iResultType == ECardResultType.Type_Ten)
        {
            var ownNum:int = CEquipCardUtil.getOwnTicketNum(CEquipCardConst.Common_Card_Id);
            buyNum = CPlayerCardConst.Consume_Num_Ten - ownNum;
        }

        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem ).getHandler(CShopBuyViewHandler )
                as CShopBuyViewHandler;
        buyViewHandler.show(0,shopData,buyNum,isShowRecharge);
    }

    public function set viewType(value:int):void
    {
        m_iViewType = value;
    }

    public function set resultType(value:int):void
    {
        m_iResultType = value;
    }

    public function clear():void
    {
        m_pViewUI.list_item.dataSource = [];
        m_listResultData.length = 0;
        m_listTempArr.length = 0;
        m_iCurrFlyIndex = 0;
        CEquipCardUtil.IsInPumping = false;
        CGameStatus.unSetStatus(CGameStatus.Status_EquipCard);
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
