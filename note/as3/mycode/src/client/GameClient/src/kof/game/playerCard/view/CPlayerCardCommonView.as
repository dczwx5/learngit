//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/15.
 */
package kof.game.playerCard.view {

import QFLib.Foundation.CMap;
import QFLib.Foundation.CTime;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.event.CViewEvent;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.event.CPlayerCardEvent;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.playerCard.util.ECardResultType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.playerCard.util.EPlayerCardEventType;
import kof.ui.CMsgAlertHandler;
import kof.ui.master.playerCard.PlayerCardCommonViewUI;

/**
 * 小酌一番
 */
public class CPlayerCardCommonView extends CPlayerCardBaseView {

    private var m_pTimer:Timer;

    public function CPlayerCardCommonView(system:CAppSystem)
    {
        super(system);

        m_pTimer = new Timer(1000,int.MAX_VALUE);
    }

    override protected function initializeView():void
    {
        _viewUI.img_currency1.skin = "png.playerCard.icon_ticket_01";
        _viewUI.img_currency2.skin = "png.playerCard.icon_ticket_01";
        _viewUI.txt_leftTime.visible = false;

//        _viewUI.btn_one.btnLabel.align = "left";
        _viewUI.btn_one.btnLabel.left = 9;
//        _viewUI.btn_ten.btnLabel.align = "left";
        _viewUI.btn_ten.btnLabel.left = 9;
    }

    override public function addListeners():void
    {
        super.addListeners();

        _viewUI.btn_free.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_one.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(m_pTimer)
        {
            m_pTimer.addEventListener(TimerEvent.TIMER,_onTimerEventHandler);
        }

        m_pSystem.addEventListener(CViewEvent.UI_EVENT,_onUIEventHandler,false,CEventPriority.DEFAULT,true);
        m_pSystem.addEventListener(CPlayerCardEvent.PumpCard, _onPumpCardHandler);
    }

    override public function removeListeners():void
    {
        super.removeListeners();

        _viewUI.btn_free.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_one.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(m_pTimer)
        {
            m_pTimer.removeEventListener(TimerEvent.TIMER,_onTimerEventHandler);
        }

        m_pSystem.removeEventListener(CViewEvent.UI_EVENT,_onUIEventHandler);
        m_pSystem.removeEventListener(CPlayerCardEvent.PumpCard, _onPumpCardHandler);
    }

    override public function updateDisplay():void
    {
        _updateEffect();
        updateTicketState();
        _updateCDTime();
        _updateFreeTimes();
        _updateBtnState();
        updateTipInfo();
        updateNumInfo();
    }

    private function _updateEffect():void
    {
        _viewUI.clip_effect.autoPlay = true;
    }

    override protected function updateTicketState():void
    {
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Common_Card_Id);
        _viewUI.txt_costOne.color = ownNum >= CPlayerCardConst.Consume_Num_One ? 0xffffff : 0x800000;
        _viewUI.txt_costTen.color = ownNum >= CPlayerCardConst.Consume_Num_Ten ? 0xffffff : 0x800000;
        _viewUI.img_dian_one.visible = ownNum >= CPlayerCardConst.Consume_Num_One;
        _viewUI.img_dian_ten.visible = ownNum >= CPlayerCardConst.Consume_Num_Ten;
    }

    override protected function updateTipInfo():void
    {
        _viewUI.txt_tipInfo.text = CLang.Get("playerCard_sxgdj");
    }

    override public function updateNumInfo():void
    {
        if(!_isInitData)
        {
            _viewUI.box_numGet.visible = false;
            _viewUI.box_mustGet.visible = false;
            _viewUI.img_currFree.visible = false;
            return;
        }

        var currNumMap:CMap = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currNumMap;
        var commonNum:int = currNumMap.find(ECardPoolType.Type_Common) ? currNumMap.find(ECardPoolType.Type_Common) : 0;

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
        var currNum:int = int(commonNum % 10);
        if(currNum == 9)
        {
//            _viewUI.txt_heroInfo.text = "本次必出格斗家";
            if(!_viewUI.img_currFree.visible)
            {
                _viewUI.box_mustGet.visible = true;
            }
        }
        else
        {
//            _viewUI.txt_heroInfo.text = (9 - currNum) + "次后必出格斗家";
            if(!_viewUI.img_currFree.visible)
            {
                _viewUI.box_numGet.visible = true;
                _viewUI.num_heroCount.num = 9 - currNum;
            }
        }

        _viewUI.txt_heroInfo.centerX = 0;
    }

    private function _onTimerEventHandler(e:TimerEvent = null):void
    {
        var currTime:Number = CTime.getCurrServerTimestamp();
        var expiredTime:Number = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).freeExpiredTime;

        if(expiredTime == 0)
        {
            _updateFreeInfo();
            _updateBtnState();
            return;
        }

        if(currTime < expiredTime)
        {
            var leftTime:Number = expiredTime-currTime;
            var timeStr:String = CTime.toDurTimeString(leftTime);
            if(!_viewUI.txt_leftTime.visible)
            {
                _viewUI.txt_leftTime.visible = true;
            }
            _viewUI.txt_leftTime.text = timeStr+"后免费";
        }
        else
        {
            m_pTimer.stop();
            m_pTimer.reset();

            _updateFreeInfo();
            _updateBtnState();
        }
    }

    /**
     * 更新CD时间
     */
    private function _updateCDTime():void
    {
        var expiredTime:Number = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).freeExpiredTime;
        if(expiredTime)
        {
            _onTimerEventHandler();
            m_pTimer.start();
        }
        else
        {
            _updateFreeInfo();
        }
    }

    private function _updateFreeInfo():void
    {
        if(!_isInitData)
        {
            _viewUI.txt_leftTime.visible = false;
            return;
        }

        _viewUI.txt_leftTime.visible = true;
        var currNum:int = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currFreeNum;
        if(currNum == 0)
        {
            _viewUI.txt_leftTime.text = "免费次数已用完";
        }
        else
        {
            _viewUI.txt_leftTime.text = "本次免费";
        }

//        _viewUI.box_freeInfo.centerX = 0;
    }

    /**
     * 更新免费次数
     */
    private function _updateFreeTimes():void
    {
        if(!_isInitData)
        {
            _viewUI.txt_freeNum.visible = false;
            return;
        }

        var currNum:int = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currFreeNum;
        var totalNum:int = CPlayerCardUtil.getTotalFreeTimes(m_iViewType);
        _viewUI.btn_free.label = CLang.Get("playerCard_mfsj",{v1:currNum,v2:totalNum});

        _viewUI.txt_freeNum.text = "（" + currNum + "/" + totalNum + "）";

//        _viewUI.box_freeInfo.centerX = 0;
    }

    /**
     * 按钮状态:寄一封信/免费寄信
     */
    private function _updateBtnState():void
    {
        if(!_isInitData)
        {
            _viewUI.img_currFree.visible = false;
            return;
        }

        var currNum:int = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currFreeNum;
        if(currNum > 0 && !CPlayerCardUtil.isInCD())
        {
            _viewUI.box_send_one.visible = false;
            _viewUI.box_free.visible = true;
            _viewUI.img_currFree.visible = true;
            _viewUI.box_mustGet.visible = false;
            _viewUI.box_numGet.visible = false;
        }
        else
        {
            _viewUI.box_send_one.visible = true;
            _viewUI.box_free.visible = false;
            _viewUI.img_currFree.visible = false;

            updateNumInfo();
        }
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        // 免费抽
        if( e.target == _viewUI.btn_free)
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

            if(CPlayerCardUtil.IsInPumping)
            {
                _showTipInfo(CLang.Get("playerCard_zzckz"),CMsgAlertHandler.WARNING);
                return;
            }

            if(!CGameStatus.checkStatus(m_pSystem))
            {
                return;
            }

//            poolId = ECardPoolType.Type_Common;
//            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardFreeRequest(poolId);
            _freePump();
        }

        // 单抽
        if( e.target == _viewUI.btn_one)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_One))
            {
                _showTipInfo(CLang.Get("playerCard_common_notEnough"),CMsgAlertHandler.WARNING);
                _showQuickBuyShop(CPlayerCardConst.Common_Card_Id,1,true);
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

//            poolId = ECardPoolType.Type_Common;
//            consumeNum = CPlayerCardConst.Consume_Num_One;
//            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
            _singlePump();
        }

        // 十连抽
        if( e.target == _viewUI.btn_ten)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_Ten))
            {
                _showTipInfo(CLang.Get("playerCard_common_notEnough"),CMsgAlertHandler.WARNING);
                var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Common_Card_Id);
                var buyNum:int = CPlayerCardConst.Consume_Num_Ten - ownNum;
                _showQuickBuyShop(CPlayerCardConst.Common_Card_Id,buyNum,true);
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

//            poolId = ECardPoolType.Type_Common;
//            consumeNum = CPlayerCardConst.Consume_Num_Ten;
//            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
            _tenPump();
        }
    }

    /**
     * 免费抽卡
     */
    private function _freePump():void
    {
        var poolId:int = ECardPoolType.Type_Common;
        var consumeNum:int = 0;

        if(CPlayerCardUtil.IsSkipAnimation)
        {
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardFreeRequest(poolId);
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
     * 单抽
     */
    private function _singlePump():void
    {
        var poolId:int = ECardPoolType.Type_Common;
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
        var poolId:int = ECardPoolType.Type_Common;
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

    private function _onPumpCardHandler(e:CPlayerCardEvent):void
    {
        var data:Object = e.data;
        if(data.viewType == ECardViewType.Type_Common)
        {
            if(!CGameStatus.checkStatus(m_pSystem))
            {
                return;
            }

            switch (data.numType)
            {
                case ECardResultType.Type_Free:
                case ECardResultType.Type_One:
                    _singlePump();
                    break;
                case ECardResultType.Type_Ten:
                    _tenPump();
                    break;
            }
        }
    }

    private function _onUIEventHandler(e:CViewEvent):void
    {
        var uiEvent:String = e.subEvent;
        switch (uiEvent) {
            case EPlayerCardEventType.UpdateCDTime:
//                if(m_pTimer.running)
//                {
//                    m_pTimer.stop();
//                    m_pTimer.reset();
//                }
//                m_pTimer.start();

                _updateCDTime();
                _updateFreeTimes();
                _updateBtnState();
                break;
        }
    }

    private function get _viewUI():PlayerCardCommonViewUI
    {
        return m_pViewUI as PlayerCardCommonViewUI;
    }

    private function get _isInitData():Boolean
    {
        return (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).isInitData;
    }

    override public function dispose():void
    {
        super.dispose();

        if(m_pTimer)
        {
            m_pTimer.stop();
            m_pTimer.reset();
        }

        _viewUI.txt_leftTime.text = "";
        _viewUI.txt_leftTime.visible = false;
        _viewUI.clip_effect.autoPlay = false;
        _viewUI.clip_effect.stop();
    }
}
}
