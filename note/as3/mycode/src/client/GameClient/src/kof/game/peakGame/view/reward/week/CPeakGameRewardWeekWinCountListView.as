//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/23.
 */
package kof.game.peakGame.view.reward.week {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.reward.CShowRewardViewUtil;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameRewardTaskData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameRewardItemTaskUI;
import kof.ui.master.PeakGame.PeakGameRewardWeekUI;

import morn.core.components.Box;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;


public class CPeakGameRewardWeekWinCountListView extends CChildView {
    public function CPeakGameRewardWeekWinCountListView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.win_list.renderHandler = new Handler(_onRenderItem);
        _ui.win_list.selectHandler = new Handler(_onSelectedItem);

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.win_list.renderHandler = null;
        _ui.win_list.selectHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        if (_ui.tab.selectedIndex != 1) {
            return true;
        }

        _ui.desc_txt.visible = _ui.win_count_txt.visible = _ui.win_count_icon_image.visible = _ui.win_list.visible = true;

        if (_ui.win_list.content == null  || _ui.win_list.scrollBar == null) {
            _ui.win_list.dataSource = _peakGameData.rewardData.weekWinDataList;
        } else {
            _ui.win_list.dataSource = _peakGameData.rewardData.weekWinDataList;
        }

        _ui.win_count_txt.text = CLang.Get("peak_week_win_count_tips", {v1:_peakGameData.rewardData.weekWinCount});
        _ui.desc_txt.text = CLang.Get("peak_week_refresh_desc");

        return true;
    }
    private function _onRenderItem(box:Box, idx:int) : void {
        var item:PeakGameRewardItemTaskUI = box as PeakGameRewardItemTaskUI;
        if (!item) return ;
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        item.select_bg_img.visible = false;

        var data:CPeakGameRewardTaskData = item.dataSource as CPeakGameRewardTaskData;
        item.task_txt.text = CLang.Get("peak_week_win_task_desc", {v1:data.target});

        if (data.isUnReady) {
//            item.reward_state_clip.index = 1;
//            item.reward_state_clip.visible = true;
            item.reward_img.visible = false;
            item.get_reward_btn.visible = false;
        } else if (data.isCanReward) {
//            item.reward_state_clip.visible = false;
            item.reward_img.visible = false;
            item.get_reward_btn.visible = true;
        } else {

//            item.reward_state_clip.index = 0;
//            item.reward_state_clip.visible = true;
            item.get_reward_btn.visible = false;
            item.reward_img.visible = true;

        }

        CShowRewardViewUtil.show(rootView, item, data.record.reward);

        item.get_reward_btn.clickHandler = new Handler(function () : void {
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.REWARD_WEEK_WIN_COUNT_CLICK_REWARD, data.record.ID));
        });
    }

    private function _onSelectedItem(idx:int) : void {
        var cells:Vector.<Box> = _ui.win_list.cells;
        var item:PeakGameRewardItemTaskUI;
        for (var i:int = 0, n:int = cells.length; i < n; i++) {
            item = cells[i] as PeakGameRewardItemTaskUI;
            if (idx == i + _ui.win_list.startIndex) {
                item.select_bg_img.visible = true;
            } else {
                item.select_bg_img.visible = false;
            }
        }
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
