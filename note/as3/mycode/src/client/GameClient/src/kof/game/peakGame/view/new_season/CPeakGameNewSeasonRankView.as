//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/28.
 */
package kof.game.peakGame.view.new_season {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.IUICanvas;
import kof.ui.master.PeakGame.PeakGameNewSeasonUI;

import morn.core.handlers.Handler;
// 排名奖励
public class CPeakGameNewSeasonRankView extends CRootView {

    public function CPeakGameNewSeasonRankView() {
        super(PeakGameNewSeasonUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _ui.desc_txt.text = CLang.Get("peak_new_season_rank_desc");
        _ui.tips_txt.text = CLang.Get("peak_new_season_rank_reward_title");
        _ui.level_item.visible = false;
    }
    protected override function _onDispose() : void {
        _coundDownComponent .dispose();
        _coundDownComponent = null;
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _ui.ok_btn.clickHandler = new Handler(_onClickOk);
        _coundDownComponent = new CCountDownCompoent(this,
                _ui.ok_btn, 30000, _onCountDownEnd,
                CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));
    }

    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _coundDownComponent.tick();
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_peakGameData.lastRanking > 0) {
            var externalUtil:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
            (externalUtil.view as CRewardItemListView).ui = _ui.reward_list;
            externalUtil.show();
            externalUtil.setData(_peakGameData.lastRankRewards);
            externalUtil.updateWindow();
            _ui.reward_list.visible = true;
            _ui.rank_num.num = _peakGameData.lastRanking;
        }

        this.addToPopupDialog();

        return true;
    }


    // ====================================event=============================
    private function _onClickOk() : void {
        this.close();
    }
    private function _onCountDownEnd() : void {
        this.close();
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameNewSeasonUI {
        return rootUI as PeakGameNewSeasonUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _coundDownComponent:CCountDownCompoent;

}
}
