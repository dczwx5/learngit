//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/22.
 */
package kof.game.peakGame.view.reward {

import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.view.reward.week.*;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.reward.daily.CPeakGameRewardDailyView;
import kof.game.peakGame.view.reward.season.CPeakGameRewardSeasonLevelListView;
import kof.game.peakGame.view.reward.season.CPeakGameRewardSeasonRankListView;
import kof.game.player.data.CPlayerData;
import kof.ui.IUICanvas;
import kof.ui.master.PeakGame.PeakGameRewardWeekUI;

import morn.core.handlers.Handler;

public class CPeakGameRewardView extends CRootView {

    public function CPeakGameRewardView() {
        super(PeakGameRewardWeekUI, [CPeakGameRewardDailyView, CPeakGameRewardWeekWinCountListView, CPeakGameRewardWeekRankListView, CPeakGameRewardSeasonLevelListView, CPeakGameRewardSeasonRankListView], null, false);
    }

    protected override function _onCreate() : void {
        _ui.tab.labels = CLang.Get("peak_week_tab");
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.tab.selectHandler = new Handler(_onTabChange);
        _first = true;
    }

    protected override function _onHide() : void {
        _ui.tab.selectHandler = null;
    }
    private function _onTabChange(tabIdx:int) : void {
        _ui.win_count_icon_image.visible = _ui.win_count_txt.visible = _ui.desc_txt.visible =
                _ui.list.visible = _ui.rank_list.visible = _ui.win_list.visible =
                        _ui.season_level_list.visible = _ui.season_rank_list.visible = false;
        invalidate();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var isDailyNotify:Boolean = (system as CPeakGameSystem).redPoint._isDailyRewardNotify(_peakGameData);
        var isWeekNotify:Boolean = (system as CPeakGameSystem).redPoint._isWeekRewardNotify(_peakGameData);
        _ui.img_red0.visible = isDailyNotify;
        _ui.img_red1.visible = isWeekNotify;
        if (_first) {
            if (isDailyNotify) {
                setTabForce(0);
            } else if (isWeekNotify) {
                setTabForce(1);
            } else {
                setTabForce(0);
            }
            _first = false;
        }

        this.addToPopupDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function setTabForce(index:int) : void {
        if (_ui.tab.selectedIndex == index) {
            _onTabChange(index);
        } else {
            _ui.tab.selectedIndex = index;
        }
    }

    // ====================================event=============================


    //===================================get/set======================================
    private function get _dailyView() : PeakGameRewardWeekUI {
        return this.getChild(0) as PeakGameRewardWeekUI;
    }
    private function get _weekWinCountView() : CPeakGameRewardWeekWinCountListView {
        return this.getChild(1) as CPeakGameRewardWeekWinCountListView;
    }
    private function get _weekRankView() : CPeakGameRewardWeekRankListView {
        return this.getChild(2) as CPeakGameRewardWeekRankListView;
    }

    private function get _seasonRankView() : CPeakGameRewardWeekRankListView {
        return this.getChild(3) as CPeakGameRewardWeekRankListView;
    }
    private function get _seasonWinCountView() : CPeakGameRewardSeasonLevelListView {
        return this.getChild(4) as CPeakGameRewardSeasonLevelListView;
    }

    [Inline]
    private function get _ui() : PeakGameRewardWeekUI {
        return rootUI as PeakGameRewardWeekUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
    private var _first:Boolean;
}
}
