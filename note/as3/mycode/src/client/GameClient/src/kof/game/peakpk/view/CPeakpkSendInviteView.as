//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.view {

import flash.utils.getTimer;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkViewEventType;
import kof.game.peakpk.enum.EPeakpkWndResType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peakpk.peakPKSendInviteUI;

import morn.core.handlers.Handler;

public class CPeakpkSendInviteView extends CRootView {

    public function CPeakpkSendInviteView() {
        super(peakPKSendInviteUI, null, EPeakpkWndResType.PEAK_PK_SEND_INVITE, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
    }
    protected override function _onDispose() : void {
        _ui.cancel_btn.label = CLang.Get("common_cancel_invite");
    }
    protected override function _onShow():void {
        _startTime = getTimer();
        listEnterFrameEvent = true;
        _ui.cancel_btn.clickHandler = new Handler(_onClickCancelInvite);

    }

    protected override function _onEnterFrame(delta:Number) : void {
        var passTimeSecond:int = (getTimer() - _startTime)/1000;
        var passSecond:int = passTimeSecond % 60;
        var passMin:int = passTimeSecond / 60;

        var strCountDown:String = CLang.Get("peak_matching_count_down_desc", {v1:passMin, v2:passSecond});
        _ui.count_down_txt.text = strCountDown;
    }
    protected override function _onHide() : void {
        _ui.cancel_btn.clickHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        _ui.desc_txt.text = CLang.Get("peak_pk_send_tips", {v1:_Data.lastSendInviteData.name});
        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onClickCancelInvite() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.SEND_INVITE_CANCEL));
        close();
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : peakPKSendInviteUI {
        return rootUI as peakPKSendInviteUI;
    }
    [Inline]
    private function get _Data() : CPeakpkData {
        if (_data && _data.length > 0) {
            return super._data[0] as CPeakpkData;
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

    private var _isFrist:Boolean = true;
    private var _startTime:int;

}
}
