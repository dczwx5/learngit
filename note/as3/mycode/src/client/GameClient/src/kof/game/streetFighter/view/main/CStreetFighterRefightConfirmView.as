//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/31.
 */
package kof.game.streetFighter.view.main {

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.ui.master.StreetFighter.StreetFighterTipsUI;

import morn.core.handlers.Handler;


public class CStreetFighterRefightConfirmView extends CRootView {

    public function CStreetFighterRefightConfirmView() {
        super(StreetFighterTipsUI, null, null, false);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.ok_btn.clickHandler = new Handler(_onOk);
        _ui.cancel_btn.clickHandler = new Handler(_onCancel);
    }
    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;
        _ui.cancel_btn.clickHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onOk() : void {
        sendEvent( new CViewEvent( CViewEvent.UI_EVENT, EStreetFighterViewEventType.REFIGHT_OK ) );
        close();
    }
    private function _onCancel() : void {
        close();
    }

    //===================================get/set======================================
    [Inline]
    private function get _ui() : StreetFighterTipsUI {
        return rootUI as StreetFighterTipsUI;
    }
    [Inline]
    private function get _Data() : CStreetFighterData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStreetFighterData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }

}
}
