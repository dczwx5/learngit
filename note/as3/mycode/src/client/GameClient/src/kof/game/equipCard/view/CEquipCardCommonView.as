//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import flash.utils.Timer;

import kof.framework.CAppSystem;

public class CEquipCardCommonView extends CEquipCardBaseView {

    private var m_pTimer:Timer;

    public function CEquipCardCommonView(system:CAppSystem)
    {
        super(system);

        m_pTimer = new Timer(1000,int.MAX_VALUE);
    }

    /*
    override protected function initializeView():void
    {
        _viewUI.img_currency1.skin = "png.playerCard.img_ticket_common";
        _viewUI.img_currency2.skin = "png.playerCard.img_ticket_common";
        _viewUI.txt_leftTime.visible = false;
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
    }

    override public function updateDisplay():void
    {
        updateTicketState();
        _updateCDTime();
        _updateFreeTimes();
        updateTipInfo();
    }

    override protected function updateTicketState():void
    {
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Common_Card_Id);
        _viewUI.txt_costOne.color = ownNum >= CPlayerCardConst.Consume_Num_One ? 0xffffff : 0xf54d4d;
        _viewUI.txt_costTen.color = ownNum >= CPlayerCardConst.Consume_Num_Ten ? 0xffffff : 0xf54d4d;
    }

    override protected function updateTipInfo():void
    {
        _viewUI.txt_tipInfo.text = CLang.Get("playerCard_gdjsp");
    }

    private function _onTimerEventHandler(e:TimerEvent):void
    {
        _updateCDTime();

//        var currTime:Number = CTime.getCurrentTimestamp();
        var currTime:Number = CTime.getCurrServerTimestamp();
        var expiredTime:Number = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).freeExpiredTime;

        if(expiredTime == 0)
        {
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
            _viewUI.txt_leftTime.text = timeStr;
        }
        else
        {
            m_pTimer.stop();
            m_pTimer.reset();

            _viewUI.txt_leftTime.visible = false;
        }
    }
    */
    /**
     * 更新CD时间
     */
    /*
    private function _updateCDTime():void
    {
        var expiredTime:Number = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).freeExpiredTime;
        if(expiredTime)
        {
            m_pTimer.start();
        }
        else
        {
            _viewUI.txt_leftTime.visible = false;
        }
    }
    */

    /**
     * 更新免费次数
     */
    /*
    private function _updateFreeTimes():void
    {
        var currNum:int = (m_pSystem.getHandler(CPlayerCardManager) as CPlayerCardManager).currFreeNum;
        var totalNum:int = CPlayerCardUtil.getTotalFreeTimes(m_iViewType);
        _viewUI.btn_free.label = CLang.Get("playerCard_mfsj",{v1:currNum,v2:totalNum});
    }
    */

    /*
    private function _onBtnClickHandler(e:MouseEvent):void
    {
        var poolId:int;
        var consumeNum:int;

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

            poolId = ECardPoolType.Type_Common;
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardFreeRequest(poolId);
        }

        // 单抽
        if( e.target == _viewUI.btn_one)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_One))
            {
                _showTipInfo(CLang.Get("playerCard_common_notEnough"),CMsgAlertHandler.WARNING);
                return;
            }

            poolId = ECardPoolType.Type_Common;
            consumeNum = CPlayerCardConst.Consume_Num_One;
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
        }

        // 十连抽
        if( e.target == _viewUI.btn_ten)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_Ten))
            {
                _showTipInfo(CLang.Get("playerCard_common_notEnough"),CMsgAlertHandler.WARNING);
                return;
            }

            poolId = ECardPoolType.Type_Common;
            consumeNum = CPlayerCardConst.Consume_Num_Ten;
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
        }
    }

    private function _onUIEventHandler(e:CViewEvent):void
    {
        var uiEvent:String = e.subEvent;
        switch (uiEvent) {
            case EPlayerCardEventType.UpdateCDTime:
                if(m_pTimer.running)
                {
                    m_pTimer.stop();
                    m_pTimer.reset();
                }
                m_pTimer.start();

                _updateFreeTimes();
                break;
        }
    }

    private function get _viewUI():PlayerCardCommonViewUI
    {
        return m_pViewUI as PlayerCardCommonViewUI;
    }

    override public function dispose():void
    {
        super.dispose();

        if(m_pTimer)
        {
            m_pTimer.stop();
            m_pTimer.reset();
        }

        _viewUI.txt_leftTime.visible = false;
    }
    */
}
}
