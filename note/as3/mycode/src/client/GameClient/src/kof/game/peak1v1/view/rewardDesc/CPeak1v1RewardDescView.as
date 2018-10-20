//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.view.rewardDesc {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1RewardRecordData;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1RewardDescItemUI;
import kof.ui.master.peak1v1.Peak1v1RewardDescUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeak1v1RewardDescView extends CRootView {

    public function CPeak1v1RewardDescView() {
        super(Peak1v1RewardDescUI, null, EPeak1v1WndResType.PEAK_1V1_REWARD_DESC, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.score_rank_tips.text = CLang.Get("peak1v1_reward_desc_rank_tips");
        _ui.score_rank_get_tips.text = CLang.Get("peak1v1_reward_desc_rank_get_tips");
        _ui.win_title_txt.text = CLang.Get("peak1v1_reward_desc_win_title");
        _ui.lose_title_txt.text = CLang.Get("peak1v1_reward_desc_lose_title");
        _ui.tie_title_txt.text = CLang.Get("peak1v1_reward_desc_tie_title");
        _ui.result_reward_get_tips_txt.text = CLang.Get("peak1v1_reward_desc_result_tips");

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.item_list.renderHandler = new Handler(_onRenderScoreRankItem);
    }

    protected override function _onHide() : void {
        _ui.item_list.renderHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        _ui.item_list.dataSource = _Data.rewardUtil.scoreRankRewardList;

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = _ui.win_reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(_Data.rewardUtil.winReward);
        rewardViewExternal.updateWindow();

        rewardViewExternal = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = _ui.lose_reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(_Data.rewardUtil.loseReward);
        rewardViewExternal.updateWindow();

        rewardViewExternal = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = _ui.tie_reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(_Data.rewardUtil.tieReward);
        rewardViewExternal.updateWindow();

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function _onRenderScoreRankItem(com:Component, idx:int) : void {
        var item:Peak1v1RewardDescItemUI = com as Peak1v1RewardDescItemUI;
        if (!item) return ;
        var data:CPeak1v1RewardRecordData = item.dataSource as CPeak1v1RewardRecordData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        item.rank_desc_txt.text = CLang.Get("peak1v1_reward_desc_rank_desc");
        item.rank_desc_txt.visible = true;

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = item.reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(data.reward);
        rewardViewExternal.updateWindow();

        if (data.startValue <= 3) {
            item.special_num.num = data.startValue;
            item.special_num.visible = true;
            item.rank_txt.visible = false;
        } else {
            item.special_num.visible = false;
            item.rank_txt.visible = true;

            if (data.endValue == -1) {
                item.rank_txt.text = CLang.Get("peak1v1_reward_desc_rank_more", {v1:data.startValue-1});
                item.rank_desc_txt.visible = false;
            } else {
                item.rank_txt.text = data.startValue + " - " + data.endValue;
            }
        }
    }

    // ====================================event=============================

    //===================================get/set======================================
    [Inline]
    private function get _ui() : Peak1v1RewardDescUI {
        return rootUI as Peak1v1RewardDescUI;
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

}
}
