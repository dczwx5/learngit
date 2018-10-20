//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/24.
 */
package kof.game.peakGame.view.reward.season {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.reward.CShowRewardViewUtil;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameRewardTaskData;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameRewardItemRankUI;
import kof.ui.master.PeakGame.PeakGameRewardWeekUI;

import morn.core.components.Box;

import morn.core.handlers.Handler;


public class CPeakGameRewardSeasonRankListView extends CChildView {
    public function CPeakGameRewardSeasonRankListView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.season_rank_list.renderHandler = new Handler(_onRenderItem);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.season_rank_list.renderHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 4) {
            return true;
        }

        _ui.desc_txt.visible = _ui.season_rank_list.visible = true;
        _ui.season_rank_list.dataSource = _peakGameData.rewardData.seasonRankDataList;
        _ui.desc_txt.text = CLang.Get("peak_season_rank_desc");

        return true;
    }

    private function _onRenderItem(box:Box, idx:int) : void {
        var item:PeakGameRewardItemRankUI = box as PeakGameRewardItemRankUI;
        if (!item) return ;
        var data:CPeakGameRewardTaskData = item.dataSource as CPeakGameRewardTaskData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var min:int = data.min;
        var max:int = data.max;
        if (min == max) {
            item.num_clip.visible = true;
            item.num_clip.index = min-1;
            item.rank_txt.visible = false;
            item.RankPreix_txt.visible = false;
            // item.rank_txt.text = CLang.Get("peak_week_rank_special_task", {v1:min});peak_week_rank_task
        } else {
            item.rank_txt.visible = true;
            item.num_clip.visible = false;
            if (max >= 9999) {
                item.rank_txt.text = CLang.Get("peak_week_level_last", {v1:min-1});
                item.RankPreix_txt.visible = false;
            } else {
                item.RankPreix_txt.visible = true;
                item.rank_txt.text = CLang.Get("peak_week_rank_task", {v1:min, v2:max});
            }
        }

        CShowRewardViewUtil.show(rootView, item, data.record.reward);
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
}
}
