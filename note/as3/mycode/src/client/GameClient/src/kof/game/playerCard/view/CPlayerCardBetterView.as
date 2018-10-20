//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/15.
 */
package kof.game.playerCard.view {

import QFLib.Foundation.CMap;

import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.event.CPlayerCardEvent;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.playerCard.util.ECardResultType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.master.playerCard.PlayerCardBetterViewUI;

import morn.core.components.Button;

/**
 * 嗨翻全场
 */
public class CPlayerCardBetterView extends CPlayerCardBaseView {
    public function CPlayerCardBetterView(system:CAppSystem)
    {
        super(system);
    }

    override protected function initializeView():void
    {
        _viewUI.img_bg.skin = "png.playerCard.img_floor_gdjzm_02";
        _viewUI.img_wine.skin = "png.playerCard.icon_envelope_02";
        (_viewUI.getChildByName("btn_tip") as Button).skin = "png.playerCard.btn_knhd_gdjzm_02";

        _viewUI.img_currency1.skin = "png.playerCard.icon_ticket_02";
        _viewUI.img_currency2.skin = "png.playerCard.icon_ticket_02";

//        _viewUI.btn_one.btnLabel.align = "left";
        _viewUI.btn_one.btnLabel.left = 9;
//        _viewUI.btn_ten.btnLabel.align = "left";
        _viewUI.btn_ten.btnLabel.left = 9;
    }

    override public function addListeners():void
    {
        super.addListeners();

        _viewUI.btn_one.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pSystem.addEventListener(CPlayerCardEvent.PumpCard, _onPumpCardHandler);
    }

    override public function removeListeners():void
    {
        super.removeListeners();

        _viewUI.btn_one.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pSystem.removeEventListener(CPlayerCardEvent.PumpCard, _onPumpCardHandler);
    }

    override public function updateDisplay():void
    {
        _updateEffect();
        updateTicketState();
        updateTipInfo();
        updateNumInfo();
    }

    private function _updateEffect():void
    {
        _viewUI.clip_effect.autoPlay = true;
    }

    override protected function updateTicketState():void
    {
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Better_Card_Id);
        _viewUI.txt_costOne.color = ownNum >= CPlayerCardConst.Consume_Num_One ? 0xffffff : 0x800000;
        _viewUI.txt_costTen.color = ownNum >= CPlayerCardConst.Consume_Num_Ten ? 0xffffff : 0x800000;
        _viewUI.img_dian_one.visible = ownNum >= CPlayerCardConst.Consume_Num_One;
        _viewUI.img_dian_ten.visible = ownNum >= CPlayerCardConst.Consume_Num_Ten;
    }

    override protected function updateTipInfo():void
    {
        _viewUI.txt_tipInfo.text = CLang.Get("playerCard_sxgdj");
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        if( e.target == _viewUI.btn_one)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Better_Card_Id,CPlayerCardConst.Consume_Num_One))
            {
                _showTipInfo(CLang.Get("playerCard_better_notEnough"),CMsgAlertHandler.WARNING);
                _showQuickBuyShop(CPlayerCardConst.Better_Card_Id);
                return;
            }

            if(CPlayerCardUtil.IsInPumping)
            {
                _showTipInfo(CLang.Get("playerCard_zzckz"),CMsgAlertHandler.WARNING);
                return;
            }

            if(!CGameStatus.checkStatus(m_pSystem))
            {
                return;
            }

//            var poolId:int = ECardPoolType.Type_Better;
//            var itemNum:int = CPlayerCardConst.Consume_Num_One;
//            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,itemNum);
            _singlePump();
        }

        if( e.target == _viewUI.btn_ten)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Better_Card_Id,CPlayerCardConst.Consume_Num_Ten))
            {

//                _showTipInfo(CLang.Get("playerCard_better_notEnough"),CMsgAlertHandler.WARNING);
                var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Better_Card_Id);
                var buyNum:int = CPlayerCardConst.Consume_Num_Ten - ownNum;
                _showQuickBuyShop(CPlayerCardConst.Better_Card_Id,buyNum,true);
                return;
            }

            if(CPlayerCardUtil.IsInPumping)
            {
                _showTipInfo(CLang.Get("playerCard_zzckz"),CMsgAlertHandler.WARNING);
                return;
            }

            if(!CGameStatus.checkStatus(m_pSystem))
            {
                return;
            }

//            poolId = ECardPoolType.Type_Better;
//            itemNum = CPlayerCardConst.Consume_Num_Ten;
//            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,itemNum);
            _tenPump();
        }
    }

    /**
     * 单抽
     */
    private function _singlePump():void
    {
        var poolId:int = ECardPoolType.Type_Better;
        var consumeNum:int = CPlayerCardConst.Consume_Num_One;

        if(CPlayerCardUtil.IsSkipAnimation)
        {
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
        }
        else
        {
            var effectView:CPlayerCardEffectViewHandler = m_pSystem.getHandler(CPlayerCardEffectViewHandler) as CPlayerCardEffectViewHandler;
            if(effectView)
            {
                var data:Object = {};
                data["poolId"] = poolId;
                data["consumeNum"] = consumeNum;
                effectView.data = data;
                effectView.addDisplay();
            }
        }

        CPlayerCardUtil.IsInPumping = true;
        CGameStatus.setStatus(CGameStatus.Status_PlayerCard);
    }

    /**
     * 十连抽
     */
    private function _tenPump():void
    {
        var poolId:int = ECardPoolType.Type_Better;
        var consumeNum:int = CPlayerCardConst.Consume_Num_Ten;

        if(CPlayerCardUtil.IsSkipAnimation)
        {
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
        }
        else
        {
            var effectView:CPlayerCardEffectViewHandler = m_pSystem.getHandler(CPlayerCardEffectViewHandler) as CPlayerCardEffectViewHandler;
            if(effectView)
            {
                var data:Object = {};
                data["poolId"] = poolId;
                data["consumeNum"] = consumeNum;
                effectView.data = data;
                effectView.addDisplay();
            }
        }

        CPlayerCardUtil.IsInPumping = true;
        CGameStatus.setStatus(CGameStatus.Status_PlayerCard);
    }

    override public function updateNumInfo():void
    {
        var currNumMap:CMap = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currNumMap;
        var betterNum:int = currNumMap.find(ECardPoolType.Type_Better) ? currNumMap.find(ECardPoolType.Type_Better) : 0;

        /*
        var isFirstShowA:Boolean = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).isFirstShowA;
        if(isFirstShowA)
        {
            if(betterNum == 19)
            {
                _viewUI.txt_heroInfo.text = "本次必出A级格斗家";
            }
            else
            {
                _showCommonInfo(betterNum,isFirstShowA);
            }
        }
        else
        {
            if(betterNum == 49)
            {
                _viewUI.txt_heroInfo.text = "本次必出A级格斗家";
            }
            else
            {
                _showCommonInfo(betterNum,isFirstShowA);
            }
        }
        */

        _viewUI.box_mustGet.visible = false;
        _viewUI.box_numGet.visible = false;

        if(betterNum == 0)// 首次精致抽卡
        {
            betterNum = CPlayerCardUtil.getFirstBeginCount(ECardPoolType.Type_Better);
        }

        var currNum:int = int(betterNum % 10);
        if(currNum == 9)
        {
//            _viewUI.txt_heroInfo.text = "本次必出格斗家";
            _viewUI.box_mustGet.visible = true;
        }
        else
        {
//            _viewUI.txt_heroInfo.text = (9 - currNum) + "次后必出格斗家";
            _viewUI.box_numGet.visible = true;
            _viewUI.num_HeroCount.num = 9 - currNum;
        }

//        _viewUI.txt_heroInfo.centerX = 0;
    }

    private function _showCommonInfo(pumpNum:int,isFirstShowA:Boolean):void
    {
        var currNum:int = int(pumpNum % 10);

        if(currNum == 9)
        {
            _viewUI.txt_heroInfo.text = "本次必出格斗家";
        }
        else
        {
            var infoStr:String = "";
            if(isFirstShowA)
            {
                infoStr = pumpNum >= 10 ? "次后必出A级格斗家" : "次后必出格斗家";
            }
            else
            {
                infoStr = (pumpNum >= 40 && pumpNum < 50) ? "次后必出A级格斗家" : "次后必出格斗家";
            }

//            if(currNum != 0)
//            {
                _viewUI.txt_heroInfo.text = (10 - currNum) + infoStr;
//            }
//            else
//            {
//                _viewUI.txt_heroInfo.text = "";
//            }
        }
    }

    private function _onPumpCardHandler(e:CPlayerCardEvent):void
    {
        var data:Object = e.data;
        if(data.viewType == ECardViewType.Type_Better)
        {
            if(!CGameStatus.checkStatus(m_pSystem))
            {
                return;
            }

            switch (data.numType)
            {
                case ECardResultType.Type_One:
                    _singlePump();
                    break;
                case ECardResultType.Type_Ten:
                    _tenPump();
                    break;
            }
        }
    }

    private function get _viewUI():PlayerCardBetterViewUI
    {
        return m_pViewUI as PlayerCardBetterViewUI;
    }
}
}
