//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.view.reward {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1RewardDataUtil;
import kof.game.peak1v1.data.CPeak1v1RewardRecordData;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1RewardItemUI;
import kof.ui.master.peak1v1.Peak1v1RewardUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CPeak1v1RewardView extends CRootView {

    public function CPeak1v1RewardView() {
        super(Peak1v1RewardUI, null, EPeak1v1WndResType.PEAK_1V1_REWARD, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.tab.labels = CLang.Get("peak1v1_reward_tab");
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.tab.selectHandler = new Handler(_onTab);
    }

    protected override function _onHide() : void {
        _ui.tab.selectHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }
        _onTab(_ui.tab.selectedIndex);
        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function _onTab(idx:int) : void {
        switch (idx) {
            case 0 :
                _ui.item_list.renderHandler = new Handler(_onRenderItem);
                _ui.item_list.dataSource = _Data.rewardUtil.damageRewardList;
                break;
            case 1 :
                _ui.item_list.renderHandler = new Handler(_onRenderItem);
                _ui.item_list.dataSource = _Data.rewardUtil.joinRewardList;
                break;
            case 2 :
                _ui.item_list.renderHandler = new Handler(_onRenderItem);
                _ui.item_list.dataSource = _Data.rewardUtil.winRewardList;
                break;
        }
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        var item:Peak1v1RewardItemUI = com as Peak1v1RewardItemUI;
        if (!item) return ;

        var data:CPeak1v1RewardRecordData = item.dataSource as CPeak1v1RewardRecordData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        // 信息
        item.has_get_img.visible = false;
        item.ok_btn.visible = true;

        item.unit_clip.visible = false; // 单位不要
        if (data.type == CPeak1v1RewardDataUtil.TYPE_REWARD_DAMAGE) {
            item.unit_clip.index = 0;
            item.type_txt.text = CLang.Get("peak1v1_damage_tips");
            if (_Data.totalDamage >= data.startValue) {
                ObjectUtils.gray(item.ok_btn, false);
                if (_Data.isDamageRewardHasGet(data.ID)) {
                    item.has_get_img.visible = true;
                    item.ok_btn.visible = false;
                }
            } else {
                ObjectUtils.gray(item.ok_btn, true);
            }
            item.num.num = data.startValue/10000;
        } else if (data.type == CPeak1v1RewardDataUtil.TYPE_REWARD_JOIN){
            item.unit_clip.index = 1;
            item.type_txt.text = CLang.Get("peak1v1_join_tips");
            if (_Data.fightCount >= data.startValue) {
                ObjectUtils.gray(item.ok_btn, false);
                if (_Data.isJoinRewardHasGet(data.ID)) {
                    item.has_get_img.visible = true;
                    item.ok_btn.visible = false;
                }
            } else {
                ObjectUtils.gray(item.ok_btn, true);
            }
            item.num.num = data.startValue;
        } else {
            item.unit_clip.index = 1;
            item.type_txt.text = CLang.Get("peak1v1_win_tips");
            if (_Data.winCount >= data.startValue) {
                ObjectUtils.gray(item.ok_btn, false);
                if (_Data.isWinRewardHasGet(data.ID)) {
                    item.has_get_img.visible = true;
                    item.ok_btn.visible = false;
                }
            } else {
                ObjectUtils.gray(item.ok_btn, true);
            }
            item.num.num = data.startValue;
        }

        // 奖励
        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = item.reward_list;
        rewardViewExternal.show();
        rewardViewExternal.setData(data.reward);
        rewardViewExternal.updateWindow();

        item.ok_btn.clickHandler = new Handler(function () : void {
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.REWARD_CLICK, data.ID));
        });
    }

    // ====================================event=============================

    //===================================get/set======================================

    [Inline]
    private function get _ui() : Peak1v1RewardUI {
        return rootUI as Peak1v1RewardUI;
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
