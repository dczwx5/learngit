//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/22.
 */
package kof.game.peakGame.view.reward.daily {

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

public class CPeakGameRewardDailyView extends CChildView {

    public function CPeakGameRewardDailyView() {
        super(null, null);
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.list.renderHandler = new Handler(_onRenderItem);
        _ui.list.selectHandler = new Handler(_onSelectedItem);
    }

    protected override function _onHide() : void {
        _ui.list.renderHandler = null;
        _ui.list.selectHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        if (_ui.tab.selectedIndex != 0) return true;

        _ui.win_count_txt.visible = _ui.desc_txt.visible = _ui.list.visible = _ui.win_count_icon_image.visible = true;

        _ui.win_count_txt.text = CLang.Get("peak_daily_win_fighter_count", {v1:_peakGameData.rewardData.dayBeatHeroCount});
        _ui.desc_txt.text = CLang.Get("peak_daily_refresh_desc");
        _ui.list.dataSource = _peakGameData.rewardData.dailyDataList;

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
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
        item.task_txt.text = CLang.Get("peak_daily_task_desc", {v1:data.target});

        if (data.isUnReady) {
            item.reward_img.visible = false;
            item.get_reward_btn.visible = false;
        } else if (data.isCanReward) {
            item.reward_img.visible = false;
            item.get_reward_btn.visible = true;
        } else {
            item.reward_img.visible = true;
            item.get_reward_btn.visible = false;
        }

        CShowRewardViewUtil.show(rootView, item, data.record.reward);

        item.get_reward_btn.clickHandler = new Handler(function () : void {
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.REWARD_DAILY_CLICK_REWARD, data.record.ID));
        });
        item.get_reward_btn.btnLabel.text = CLang.Get("common_get_reward");
    }
    private function _onSelectedItem(idx:int) : void {
        var cells:Vector.<Box> = _ui.list.cells;
        var item:PeakGameRewardItemTaskUI;
        for (var i:int = 0, n:int = cells.length; i < n; i++) {
            item = cells[i] as PeakGameRewardItemTaskUI;
            if (idx == i + _ui.list.startIndex) {
                item.select_bg_img.visible = true;
            } else {
                item.select_bg_img.visible = false;
            }
        }
    }
    // ====================================event=============================


    //===================================get/set======================================

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
