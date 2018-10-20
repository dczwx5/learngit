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
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameRewardItemLevelUI;
import kof.ui.master.PeakGame.PeakGameRewardWeekUI;

import morn.core.components.Box;
import morn.core.handlers.Handler;


public class CPeakGameRewardSeasonLevelListView extends CChildView {
    public function CPeakGameRewardSeasonLevelListView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.season_level_list.renderHandler = new Handler(_onRenderItem);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.season_level_list.renderHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 3) {
            return true;
        }

        _ui.desc_txt.visible = _ui.season_level_list.visible = true;

        _ui.season_level_list.dataSource = _peakGameData.rewardData.seasonLevelDataList;
        _ui.desc_txt.text = CLang.Get("peak_season_level_desc");

        return true;
    }
    private function _onRenderItem(box:Box, idx:int) : void {
        var item:PeakGameRewardItemLevelUI = box as PeakGameRewardItemLevelUI;
        if (!item) return ;
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var data:PeakScoreLevel = item.dataSource as PeakScoreLevel;
        CShowRewardViewUtil.show(rootView, item, data.rankingReward);


        var min:int = data.scoreBottomLimit;
        var max:int = data.scoreTopLimit;
        if (max == -1) {
            item.score_txt.text = CLang.Get("peak_week_level_max_task", {v1:min});
        } else {
            item.score_txt.text = CLang.Get("peak_week_level_task", {v1:min, v2:max});
        }
        item.title_txt.text = data.levelName;

        CPeakGameLevelItemUtil.setValue(item.level_item, data.levelId, data.subLevelId, data.levelName, false);
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
