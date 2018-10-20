//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.view {

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.im.data.CIMFriendsData;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkViewEventType;
import kof.game.peakpk.enum.EPeakpkWndResType;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.peakpk.peakPKItemUI;
import kof.ui.master.peakpk.peakPKUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeakpkView extends CRootView {

    public function CPeakpkView() {
        super(peakPKUI, null, EPeakpkWndResType.PEAK_PK_MAIN, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.player_list.renderHandler = new Handler(_onRenderPlayerItem);
        _ui.refresh_btn.clickHandler = new Handler(_onClickReset);
    }

    protected override function _onHide() : void {
        _ui.player_list.renderHandler = null;
        _ui.refresh_btn.clickHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        _ui.online_txt.text = CLang.Get("im_online_desc", {v1:_Data.pFriendList.length});

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
        _ui.player_list.dataSource = _Data.pFriendList;

    }

    private function _onRenderPlayerItem(com:Component, idx:int) : void {
        var item:peakPKItemUI = com as peakPKItemUI;
        var data:CIMFriendsData = item.dataSource as CIMFriendsData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var pPlayerSystem:CPlayerSystem = ((uiCanvas as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem);
        pPlayerSystem.platform.signatureRender.renderSignature(data.vipLevel, data.platformData, item.signature, data.name);

        item.icon_img.cacheAsBitmap = true;
        item.icon_mask_img.cacheAsBitmap = true;
        item.icon_img.mask = item.icon_mask_img;
        item.icon_img.url = CPlayerPath.getHeroSmallIconPath(data.headID);
        item.txt_name.text = CLang.Get("common_peak_level_title") + "：";

        var findScoreLevelRecord:PeakScoreLevel = CPeakGameData.findScoreLevelRecordByScore(_Data.scoreLevelDataList, data.fairPeakScore);

        item.peak_lv_txt.text = findScoreLevelRecord.levelName;
        item.pk_btn.clickHandler = new Handler(_onClickPk, [data]);
        item.level_txt.text = data.level.toString(); // CLang.Get("common_level_en", {v1:data.level});

        item.toolTip = new Handler(addTips, [CPeakpkPlayerTips, item]);
    }

    private function _onClickPk(data:CIMFriendsData) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.MAIN_CLICK_ITEM_PK_BTN, data));

    }

    // ====================================event=============================
    private function _onClickReset() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakpkViewEventType.MAIN_CLICK_REFRESH_BTN));
    }

    //===================================get/set======================================

    [Inline]
    private function get _ui() : peakPKUI {
        return rootUI as peakPKUI;
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

}
}
