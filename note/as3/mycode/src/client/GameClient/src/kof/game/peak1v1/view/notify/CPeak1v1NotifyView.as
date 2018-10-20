//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/27.
 */
package kof.game.peak1v1.view.notify {

import QFLib.Foundation.CTime;

import flash.utils.getTimer;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1NotifyUI;

import morn.core.handlers.Handler;

public class CPeak1v1NotifyView extends CRootView {

    public function CPeak1v1NotifyView() {
        super(Peak1v1NotifyUI, null, EPeak1v1WndResType.PEAK_1V1_NOTIFY, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        listEnterFrameEvent = true;
        _startTime = getTimer();

        _ui.join_btn.clickHandler = new Handler(_onJoin);
    }

    protected override function _onHide() : void {
        _startTime = 0;
        _ui.join_btn.clickHandler = null;
    }

    protected override function _onEnterFrame(delta:Number) : void {
        if (_startTime == 0) return ;

        var curTime:int = getTimer();
        var endTime:int = _startTime + _Data.showNotifyStillTime;
        if (curTime > endTime) {
            _ui.open_count_down_txt.visible = false;
            _ui.auto_close_count_down_txt.visible = false;
            close();
        } else {
            _ui.auto_close_count_down_txt.visible = true;
            var leftTime:int = (endTime - curTime)/1000;
            _ui.auto_close_count_down_txt.text = CLang.Get("peak1v1_notify_close_tips", {v1:leftTime});

            _ui.open_count_down_txt.visible = true;
            var fCurTime:Number = CTime.getCurrServerTimestamp();
            var fTimeDelta:Number = _Data.startTime - fCurTime;
            var strStartLeftTime:String;
            if (fTimeDelta > 0) {
                strStartLeftTime = CTime.toDurTimeString(fTimeDelta);
                _ui.open_count_down_txt.text = CLang.Get("peak1v1_notify_start_tips", {v1:strStartLeftTime});
            } else {
                _ui.open_count_down_txt.text = CLang.Get("peak1v1_notify_start_tips_2");
            }
        }
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = _ui.reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(_Data.rewardUtil.winReward);
        rewardViewExternal.updateWindow();

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onJoin() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.NOTIFY_CLICK_OK));
    }
    //===================================get/set======================================
    [Inline]
    private function get _ui() : Peak1v1NotifyUI {
        return rootUI as Peak1v1NotifyUI;
    }
    [Inline]
    private function get _Data() : CPeak1v1Data {
        if (_data && _data.length > 0) {
            return super._data[0] as CPeak1v1Data;
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
    private var _startTime:int = 0;
}
}
