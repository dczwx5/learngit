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
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkViewEventType;
import kof.game.peakpk.enum.EPeakpkWndResType;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.peakpk.peakPKReceiveInviteUI;

import morn.core.handlers.Handler;

public class CPeakpkReceiveInviteView extends CRootView {

    public function CPeakpkReceiveInviteView() {
        super(peakPKReceiveInviteUI, null, EPeakpkWndResType.PEAK_PK_RECEIVE_INVITE, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.refuse_btn.label = CLang.Get("common_refuse_invite");
        _ui.access_btn.label = CLang.Get("common_access_invite");
    }

    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        listEnterFrameEvent = true;
        _startTime = getTimer();
        _isEnd = false;
        _ui.refuse_btn.clickHandler = new Handler(_onRefuse);
        _ui.access_btn.clickHandler = new Handler(_onAccess);
        _ui.checkBox_refuseAll.clickHandler = new Handler(_onRefuseAll);
        _hasProcess = false;
    }

    protected override function _onHide() : void {
        _ui.refuse_btn.clickHandler = null;
        _ui.access_btn.clickHandler = null;
        _ui.checkBox_refuseAll.clickHandler = null;
    }
    protected override function _onEnterFrame(delta:Number) : void {
        if (_isEnd) {
            return ;
        }

        const COUNT_DOWN_MAX:int = 30;
        var leftTime:int = COUNT_DOWN_MAX - ((getTimer() - _startTime)/1000);
        if (leftTime < 0) {
            leftTime = 0;
        }
        var strCountDown:String = CLang.Get("peak_pk_refuse_count_down_tips", {v1:leftTime});
        _ui.count_down_txt.text = strCountDown;

        if (leftTime == 0) {
            _isEnd = true;
            _onRefuse();
        }
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        var findScoreLevelRecord:PeakScoreLevel = CPeakGameData.findScoreLevelRecordByScore(_Data.scoreLevelDataList, _Data.inviterData.fairPeakScore);
        var inviterLevelName:String = findScoreLevelRecord.levelName;
        _ui.desc_txt.text = CLang.Get("peak_pk_receive_tips", {v1:_Data.inviterData.name, v2:inviterLevelName});

        var gameSettingData:CGameSettingData = (system.stage.getSystem(CGameSettingSystem) as CGameSettingSystem).gameSettingData;
        if(gameSettingData)
        {
            _ui.checkBox_refuseAll.selected = gameSettingData.isRefusePeakPk;
        }

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    protected override function _onClose(): void {
        if (!_hasProcess) {
            // 只处理点X关闭。如果 是点了其他关闭的话。不发起
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.RECEIVE_INVITE_REFUSE));
        }
        super._onClose();
    }

    // ====================================event=============================
    private function _onRefuse() : void {
        _hasProcess = true;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.RECEIVE_INVITE_REFUSE));
        close();
    }
    private function _onAccess() : void {
        _hasProcess = true;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.RECEIVE_INVITE_ACCESS));
        close();
    }

    private function _onRefuseAll():void
    {
        var state:Boolean = _ui.checkBox_refuseAll.selected;
        system.stage.getSystem(CGameSettingSystem ).dispatchEvent(new CGameSettingEvent(CGameSettingEvent.PeakPkSynchUpdate, state));
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : peakPKReceiveInviteUI {
        return rootUI as peakPKReceiveInviteUI;
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
    private var _isEnd:Boolean;

    private var _hasProcess:Boolean;

}
}
