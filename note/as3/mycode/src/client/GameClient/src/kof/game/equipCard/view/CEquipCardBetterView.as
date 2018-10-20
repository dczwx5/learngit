//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import kof.framework.CAppSystem;

public class CEquipCardBetterView extends CEquipCardBaseView {
    public function CEquipCardBetterView( system : CAppSystem )
    {
        super( system );
    }

    /*
    override protected function initializeView():void
    {
        _viewUI.img_bg.skin = "png.playerCard.img_cardBg2";
        _viewUI.img_wine.skin = "png.playerCard.img_wine2";
        (_viewUI.getChildByName("btn_tip") as Button).skin = "png.playerCard.btn_knhd_ck02";

        _viewUI.img_currency1.skin = "png.playerCard.img_ticket_better";
        _viewUI.img_currency2.skin = "png.playerCard.img_ticket_better";
    }

    override public function addListeners():void
    {
        super.addListeners();

        _viewUI.btn_one.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
    }

    override public function removeListeners():void
    {
        super.removeListeners();

        _viewUI.btn_one.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        _viewUI.btn_ten.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
    }

    override public function updateDisplay():void
    {
        updateTicketState();
        updateTipInfo();
        // TODO update other
    }

    override protected function updateTicketState():void
    {
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(CPlayerCardConst.Better_Card_Id);
        _viewUI.txt_costOne.color = ownNum >= CPlayerCardConst.Consume_Num_One ? 0xffffff : 0xf54d4d;
        _viewUI.txt_costTen.color = ownNum >= CPlayerCardConst.Consume_Num_Ten ? 0xffffff : 0xf54d4d;
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
                return;
            }

            var poolId:int = ECardPoolType.Type_Better;
            var itemNum:int = CPlayerCardConst.Consume_Num_One;
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,itemNum);
        }

        if( e.target == _viewUI.btn_ten)
        {
            if(!CPlayerCardUtil.isTicketEnough(CPlayerCardConst.Better_Card_Id,CPlayerCardConst.Consume_Num_Ten))
            {
                _showTipInfo(CLang.Get("playerCard_better_notEnough"),CMsgAlertHandler.WARNING);
                return;
            }

            poolId = ECardPoolType.Type_Better;
            itemNum = CPlayerCardConst.Consume_Num_Ten;
            (m_pSystem.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,itemNum);
        }
    }

    private function get _viewUI():PlayerCardBetterViewUI
    {
        return m_pViewUI as PlayerCardBetterViewUI;
    }
    */
}
}
