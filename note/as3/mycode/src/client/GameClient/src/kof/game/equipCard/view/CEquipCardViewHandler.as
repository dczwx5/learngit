//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import QFLib.Foundation.CMap;
import QFLib.Framework.CTweener;

import com.greensock.TweenMax;

import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.events.Event;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CTweenViewHandler;
import kof.game.equipCard.CEquipCardManager;
import kof.game.equipCard.CEquipCardNetHandler;
import kof.game.equipCard.util.CEquipCardConst;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.equipCard.EquipCardWinUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.components.List;
import morn.core.components.List;

import morn.core.handlers.Handler;

public class CEquipCardViewHandler extends CTweenViewHandler{

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : EquipCardWinUI;
    private var m_pCloseHandler : Handler;
    private var m_pListArr:Array = [];

    public function CEquipCardViewHandler()
    {
        super(false);
    }

    override public function get viewClass() : Array
    {
        return [ EquipCardWinUI ];
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
                m_pViewUI = new EquipCardWinUI();

//                m_pViewUI.list_item1.renderHandler = new Handler(_renderItem);
//                m_pViewUI.list_item2.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_item1.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_item2.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_item1.mask = m_pViewUI.img_mask;
                m_pViewUI.list_item2.mask = m_pViewUI.img_mask2;

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
            invalidate();
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
//        uiCanvas.addDialog( m_pViewUI );
        setTweenData(KOFSysTags.EQUIP_CARD);
        showDialog(m_pViewUI);
        m_pViewUI.visible = true;

        _initView();
        _addListeners();

        _reqInfo();
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

            var resultView:CEquipCardResultViewHandler = system.getHandler(CEquipCardResultViewHandler) as CEquipCardResultViewHandler;
            if(resultView && resultView.isViewShow)
            {
                resultView.removeDisplay();
            }

//            unschedule(_rollItems);
            TweenMax.killTweensOf(m_pViewUI.list_item1);
            TweenMax.killTweensOf(m_pViewUI.list_item2);

            CEquipCardUtil.IsInPumping = false;
            CGameStatus.unSetStatus(CGameStatus.Status_EquipCard);
        }
    }

    private function _initView():void
    {
        m_pViewUI.list_item1.x = 11;
        m_pViewUI.list_item2.x = 347;

        // 暂时屏蔽扭蛋币和扭蛋商店
        m_pViewUI.box_coin.visible = false;
        m_pViewUI.btn_shop.visible = false;
        m_pViewUI.btn_tip.x = m_pViewUI.btn_shop.x;
    }

    private function _onClose( type : String = null) : void
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

    private function _onCloseHandler(e:MouseEvent):void
    {
        if(CEquipCardUtil.IsInPumping)
        {
            _showTipInfo(CLang.Get("equipCard_zznd"),CMsgAlertHandler.WARNING);
            return;
        }

        if(closeHandler)
        {
            closeHandler.execute();
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_addCommonCard.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_tip.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_shop.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_one.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_ten.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_must.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_close.addEventListener(MouseEvent.CLICK, _onCloseHandler);
        m_pViewUI.list_item1.addEventListener(MouseEvent.ROLL_OVER,_onRollOverHandler);
        m_pViewUI.list_item2.addEventListener(MouseEvent.ROLL_OVER,_onRollOverHandler);
        m_pViewUI.list_item1.addEventListener(MouseEvent.ROLL_OUT,_onRollOutHandler);
        m_pViewUI.list_item2.addEventListener(MouseEvent.ROLL_OUT,_onRollOutHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.PLAYER_EQUIP_CARD,_onPlayerInfoUpdateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_addCommonCard.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_tip.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_shop.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_one.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_ten.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_must.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_close.removeEventListener(MouseEvent.CLICK, _onCloseHandler);
        m_pViewUI.list_item1.removeEventListener(MouseEvent.ROLL_OVER,_onRollOverHandler);
        m_pViewUI.list_item2.removeEventListener(MouseEvent.ROLL_OVER,_onRollOverHandler);
        m_pViewUI.list_item1.removeEventListener(MouseEvent.ROLL_OUT,_onRollOutHandler);
        m_pViewUI.list_item2.removeEventListener(MouseEvent.ROLL_OUT,_onRollOutHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.PLAYER_EQUIP_CARD,_onPlayerInfoUpdateHandler);
    }

    private function _reqInfo():void
    {
        (system.getHandler(CEquipCardNetHandler) as CEquipCardNetHandler).equipCardOpenRequest();
    }

    override protected function updateDisplay():void
    {
        _updateOwnTicketInfo();
        _updateCurrCount();
        _updateHeroImg();
        _updateGoodItems();
        _updateNumInfo();
    }

    /**
     * 拥有的酒券和欧比信息
     */
    private function _updateOwnTicketInfo():void
    {
        var commonNum:int = CEquipCardUtil.getOwnTicketNum(CEquipCardConst.Common_Card_Id);
        var pCPlayerData : CPlayerData = (_playerSystem.getBean( CPlayerManager ) as CPlayerManager).playerData;

        m_pViewUI.txt_ownCommonNum.text = commonNum.toString();
        m_pViewUI.txt_ownCurrencyNum.text = pCPlayerData.currency.eggCoin.toString();

        if(m_pViewUI.img_commonCard.toolTip == null)
        {
            m_pViewUI.img_commonCard.toolTip = new Handler( _showTips, [m_pViewUI.img_commonCard,CEquipCardConst.Common_Card_Id] );
        }

        if(m_pViewUI.img_currency.toolTip == null)
        {
            m_pViewUI.img_currency.toolTip = new Handler( _showTips, [m_pViewUI.img_currency,CEquipCardConst.Currency_Ou_Id] );
        }

        m_pViewUI.txt_one.color = commonNum >= CEquipCardConst.Consume_Num_One ? 0xffffff : 0xf54d4d;
        m_pViewUI.txt_ten.color = commonNum >= CEquipCardConst.Consume_Num_Ten ? 0xffffff : 0xf54d4d;
        m_pViewUI.img_dian1.visible = commonNum >= CEquipCardConst.Consume_Num_One;
        m_pViewUI.img_dian2.visible = commonNum >= CEquipCardConst.Consume_Num_Ten;
    }

    /**
     * 当前次数
     */
    private function _updateCurrCount():void
    {
        CONFIG::debug
        {
            var currNumMap:CMap = (system.getHandler(CEquipCardManager ) as CEquipCardManager).currNumMap;

            var commonNum:int = currNumMap.find(ECardPoolType.Type_Common) ? currNumMap.find(ECardPoolType.Type_Common) : 0;
            var betterNum:int = currNumMap.find(ECardPoolType.Type_Better) ? currNumMap.find(ECardPoolType.Type_Better) : 0;
            var activeNum:int = currNumMap.find(ECardPoolType.Type_Active) ? currNumMap.find(ECardPoolType.Type_Active) : 0;

//            m_pViewUI.txt_currCount_common.visible = true;
//            m_pViewUI.txt_currCount_common.text = "当前次数：" + commonNum.toString();
        }
    }

    /**
     * 琼的靓照
     */
    private function _updateHeroImg():void
    {
    }

    private var m_iCurrPage:int;
    /**
     * 展示价值含量高的物品
     */
    private function _updateGoodItems():void
    {
        var itemArr:Array = CEquipCardUtil.getDisplayItemsInPool();
        m_pViewUI.list_item1.dataSource = itemArr;
        m_pViewUI.list_item2.dataSource = CEquipCardUtil.getDisplayItemsInPool(itemArr[itemArr.length - 1]);

        m_pListArr.length = 0;
        m_pListArr.push(m_pViewUI.list_item1);
        m_pListArr.push(m_pViewUI.list_item2);

        schedule(1/1500,_onScheduleHandler);
    }

    private function _updateNumInfo():void
    {
        var currNumMap:CMap = (system.getHandler(CEquipCardManager) as CEquipCardManager).currNumMap;
        var currNum:int = currNumMap.find(ECardPoolType.Type_Common) ? currNumMap.find(ECardPoolType.Type_Common) : 0;
        if(currNum == 0)
        {
            currNum = CEquipCardUtil.getFirstBeginCount(ECardPoolType.Type_Common);
        }
        var leftNum:int = 10 - int(currNum % 10);
        m_pViewUI.txt_numInfo.text = leftNum + "次必得装备觉醒石";

        m_pViewUI.box_must.visible = leftNum == 1;
        m_pViewUI.box_notMust.visible = leftNum != 1;
    }

    private var m_pTween1:TweenMax;
    private var m_pTween2:TweenMax;
    private function _rollItems(num:Number = 0):void
    {
        var durTime:Number = 8;
        m_pTween1 = TweenMax.to(m_pListArr[0],durTime,{x:-167,ease:Linear.easeNone});
        m_pTween2 = TweenMax.to(m_pListArr[1],durTime,{x:64,ease:Linear.easeNone,onComplete:_onRollComplHandler});
    }

    private function _onRollComplHandler():void
    {
        var list:List = m_pListArr.shift();
        m_pListArr.push(list);

        m_iCurrPage++;

        m_pListArr[1 ].x = 347;
//        m_pListArr[1].dataSource = CEquipCardUtil.getNextItemsOnRoll(m_iCurrPage+1);

//        schedule(5,_rollItems);
        _rollItems();
    }

    private function _onTimerHandler(e:TimerEvent):void
    {
        _updateListPos();

        if(m_pListArr[0].x <= -325)
        {
            var list:List = m_pListArr.shift();
            m_pListArr.push(list);

//            m_iCurrPage++;

            m_pListArr[1].x = 347;
            var arr:Array = m_pListArr[0 ].dataSource as Array;
            m_pListArr[1].dataSource = CEquipCardUtil.getDisplayItemsInPool(arr[arr.length - 1]);
        }
    }

    private function _onEnterFrameHandler(e:Event):void
    {
        _updateListPos();

        if(m_pListArr[0].x <= -325)
        {
            var list:List = m_pListArr.shift();
            m_pListArr.push(list);

//            m_iCurrPage++;

            m_pListArr[1].x = 347;
            var arr:Array = m_pListArr[0 ].dataSource as Array;
            m_pListArr[1].dataSource = CEquipCardUtil.getDisplayItemsInPool(arr[arr.length - 1]);
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        _updateListPos();

        if(m_pListArr[0].x <= -325)
        {
            var list:List = m_pListArr.shift();
            m_pListArr.push(list);

//            m_iCurrPage++;

            m_pListArr[1].x = 347;
            var arr:Array = m_pListArr[0 ].dataSource as Array;
            m_pListArr[1].dataSource = CEquipCardUtil.getDisplayItemsInPool(arr[arr.length - 1]);
        }
    }

    private function _updateListPos():void
    {
        m_pListArr[0].x -= 1;
        m_pListArr[1].x -= 1;
    }

    private function _renderItem( item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData:CItemData = rewardItem.dataSource as CItemData;
        if(null != itemData)
        {
            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
        }
        else
        {
            rewardItem.icon_image.url = "";
            rewardItem.bg_clip.index = 0;
        }

        rewardItem.num_lable.text = "";
        if(itemData)
        {
            rewardItem.toolTip = new Handler( _showTips, [rewardItem,itemData.ID] );
        }

    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_addCommonCard)// 购买扭扭卡
        {
            _showQuickBuyShop(CEquipCardConst.Common_Card_Id,1,true);
        }

        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;

        if( e.target == m_pViewUI.btn_shop)// 打开装备商店
        {
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
            bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_10]);
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }


        if( e.target == m_pViewUI.btn_tip)// 预览物品
        {
            var poolView:CEquipCardPoolViewHandler = system.getHandler(CEquipCardPoolViewHandler) as CEquipCardPoolViewHandler;
            poolView.cardPoolType = ECardPoolType.Type_Common;
            poolView.addDisplay();
        }

        if( e.target == m_pViewUI.btn_one || e.target == m_pViewUI.btn_must)// 扭一下
        {
            pumpingEquip(CEquipCardConst.Consume_Num_One);
        }

        if( e.target == m_pViewUI.btn_ten)// 扭十下
        {
            pumpingEquip(CEquipCardConst.Consume_Num_Ten);
        }
    }

    /**
     * 抽装备
     * @times 一次/十次
     */
    public function pumpingEquip(times:int):void
    {
        var poolId:int;
        var consumeNum:int;

        if(times == CEquipCardConst.Consume_Num_One)// 扭一下
        {
            if(!CEquipCardUtil.isTicketEnough(CEquipCardConst.Common_Card_Id,CEquipCardConst.Consume_Num_One))
            {
                _showTipInfo(CLang.Get("equipCard_nnkbgl"),CMsgAlertHandler.WARNING);
                _showQuickBuyShop(CEquipCardConst.Common_Card_Id);
                return;
            }

            if(CEquipCardUtil.IsInPumping)
            {
                _showTipInfo(CLang.Get("equipCard_zznd"),CMsgAlertHandler.WARNING);
                return;
            }

            if(!CGameStatus.checkStatus(system))
            {
                return;
            }

            poolId = CEquipCardUtil.getCurrPoolId();
            consumeNum = CEquipCardConst.Consume_Num_One;

            CEquipCardUtil.IsInPumping = true;
            CGameStatus.setStatus(CGameStatus.Status_EquipCard);

            if(CEquipCardUtil.IsSkipAnimation)
            {
                (system.getHandler(CEquipCardNetHandler) as CEquipCardNetHandler).pumpingCardRequest(poolId,consumeNum);
            }
            else
            {
                m_pViewUI.clip_egg.playFromTo(null,null,new Handler(_onAnimationComplHandler));
            }

            function _onAnimationComplHandler():void
            {
                (system.getHandler(CEquipCardNetHandler) as CEquipCardNetHandler).pumpingCardRequest(poolId,consumeNum);
                delayCall(0.2,gotoFirstFrame);
            }

            function gotoFirstFrame():void
            {
                m_pViewUI.clip_egg.gotoAndStop(1);
            }
        }

        if(times == CEquipCardConst.Consume_Num_Ten)// 扭十下
        {
            if(!CEquipCardUtil.isTicketEnough(CEquipCardConst.Common_Card_Id,CEquipCardConst.Consume_Num_Ten))
            {
//                _showTipInfo(CLang.Get("equipCard_nnkbgl"),CMsgAlertHandler.WARNING);
                var ownNum:int = CEquipCardUtil.getOwnTicketNum(CEquipCardConst.Common_Card_Id);
                var buyNum:int = CPlayerCardConst.Consume_Num_Ten - ownNum;
                _showQuickBuyShop(CEquipCardConst.Common_Card_Id,buyNum,true);
                return;
            }

            if(CEquipCardUtil.IsInPumping)
            {
                _showTipInfo(CLang.Get("equipCard_zznd"),CMsgAlertHandler.WARNING);
                return;
            }

            if(!CGameStatus.checkStatus(system))
            {
                return;
            }

            poolId = CEquipCardUtil.getCurrPoolId();
            consumeNum = CEquipCardConst.Consume_Num_Ten;

            CEquipCardUtil.IsInPumping = true;
            CGameStatus.setStatus(CGameStatus.Status_EquipCard);

            if(CEquipCardUtil.IsSkipAnimation)
            {
                (system.getHandler(CEquipCardNetHandler) as CEquipCardNetHandler).pumpingCardRequest(poolId,consumeNum);
            }
            else
            {
                m_pViewUI.clip_egg.playFromTo(null,null,new Handler(_onAnimationComplHandler2));
            }

            function _onAnimationComplHandler2():void
            {
                (system.getHandler(CEquipCardNetHandler) as CEquipCardNetHandler).pumpingCardRequest(poolId,consumeNum);
                delayCall(0.2,gotoFirstFrame2);
            }

            function gotoFirstFrame2():void
            {
                m_pViewUI.clip_egg.gotoAndStop(1);
            }
        }
    }

    /**
     * 快速购买
     */
    private function _showQuickBuyShop(itemId:int,buyNum:int = 1,isShowRecharge:Boolean = true):void
    {
        var shopData:CShopItemData = CEquipCardUtil.getShopData(itemId);
        if(shopData == null)
        {
            _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
            return;
        }


        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem ).getHandler(CShopBuyViewHandler )
                as CShopBuyViewHandler;
        buyViewHandler.show(0,shopData,buyNum,isShowRecharge);
    }

    private function _flyItem():void
    {
        var len:int = m_pViewUI.list_item1.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = m_pViewUI.list_item1.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
//        m_pTween1.pause();
//        m_pTween2.pause();
//        m_pTimer.stop();
//        m_pViewUI.removeEventListener(Event.ENTER_FRAME,_onEnterFrameHandler);

        unschedule(_onScheduleHandler);
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
//        m_pTween1.resume();
//        m_pTween2.resume();
//        m_pTimer.start();
//        m_pViewUI.addEventListener(Event.ENTER_FRAME,_onEnterFrameHandler);

        schedule(1/1500,_onScheduleHandler);
    }

    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if ( e.type == CBagEvent.BAG_UPDATE )
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

        m_pViewUI.txt_ownCurrencyNum.text = pCPlayerData.currency.eggCoin.toString();
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
     * XX次必得装备觉醒石
     */
    public function updateNumInfo():void
    {
        if(m_bViewInitialized && isViewShow)
        {
            _updateNumInfo();
        }
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

//    public function get isPlaying():Boolean
//    {
//        return CEquipCardUtil.IsInPumping;
//    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
