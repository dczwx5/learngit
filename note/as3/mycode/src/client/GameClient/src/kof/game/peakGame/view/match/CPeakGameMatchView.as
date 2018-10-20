//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.match {


import flash.utils.getTimer;

import kof.game.bootstrap.CNetDelayHandler;
import kof.game.common.CLang;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameMatchUI;

import morn.core.handlers.Handler;

public class CPeakGameMatchView extends CRootView {

    public function CPeakGameMatchView() {
        super(PeakGameMatchUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _ui.title_txt.text = CLang.Get("peak_matching_title");
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        listEnterFrameEvent = true;
        _startTime = getTimer();
        _ui.cancel_btn.clickHandler = new Handler(_onCancel);
    }
    protected override function _onHide() : void {
        _ui.cancel_btn.clickHandler = null;
    }

    protected override function _onEnterFrame(delta:Number) : void {
        var passMin:int = 0;
        var passSecond:int = 0;
        var predictTime:int = 0;
        var sTime:String = CLang.Get("common_time_second");
        if (_peakGameData) {
            predictTime = _peakGameData.predictMatchTime;
            if (predictTime >= 60) {
                sTime = CLang.Get("common_time_min");
                predictTime /= 60;
            }
        }

        var passTimeSecond:int = (getTimer() - _startTime)/1000;
        passSecond = passTimeSecond % 60;
        passMin = passTimeSecond / 60;

        var strMatching:String = CLang.Get("peak_matching_desc", {v3:predictTime, v4:sTime});
        var strCountDown:String = CLang.Get("peak_matching_count_down_desc", {v1:passMin, v2:passSecond});
        _ui.matching_txt.text = strMatching;
        _ui.count_down_txt.text = strCountDown;
    }
    private function _onCancel() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MATCHING_CLICK_CANCEL));
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();

        if (_peakGameData.lastNetDelay > CNetDelayHandler.NET_DELAY_BAD) {
            _ui.tips_txt.text = CLang.Get("peak_matching_bad");
        } else {
            _ui.tips_txt.text = CLang.Get("peak_matching_normal");
        }

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        // this.setChildrenData(v as CPeakGameData);
    }

    // ====================================event=============================

    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameMatchUI {
        return rootUI as PeakGameMatchUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _startTime:int;
}
}
