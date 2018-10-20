//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view.reward {


import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterRewardData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.table.StreetFighterReward;
import kof.ui.master.StreetFighter.StreetFighterAwardItem01UI;
import kof.ui.master.StreetFighter.StreetFighterAwardUI;
import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;


public class CStreetFighterRewardFightView extends CChildView {
    public function CStreetFighterRewardFightView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.item_list.renderHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 1) {
            return true;
        }
        _ui.tips.visible = false;

        _ui.item_list.renderHandler = new Handler(_onRenderItem);
        _ui.rank_list.visible = false;
        _ui.item_list.visible = true;
        var datalist:Array = _streetData.rewardData.getRewardRecordListByType([CStreetFighterRewardData.TYPE_FIGHT_COUNT,
                                                                                CStreetFighterRewardData.TYPE_WIN_COUNT,
                                                                                CStreetFighterRewardData.TYPE_ALWAYS_WIN_COUNT]);
        datalist.sort(_compare);

        _ui.item_list.dataSource = datalist;

        return true;
    }
    private function _compare(left:StreetFighterReward, right:StreetFighterReward) : int {
        if (_streetData.rewardData.hasRewarded(left.ID)) {
            return 1;
        } else if (_streetData.rewardData.hasRewarded(right.ID)) {
            return -1;
        }
        return left.ID - right.ID;
    }

    private function _onRenderItem(comp:Component, idx:int) : void {
        var item:StreetFighterAwardItem01UI = comp as StreetFighterAwardItem01UI;
        var datasource:StreetFighterReward = item.dataSource as StreetFighterReward;
        if (!datasource) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var target:int = datasource.param[0] as int;
        var langKey:String = _getTargetLangByType(datasource.type);

        var curValue:int = _streetData.getCurValueByType(datasource.type);
        curValue = curValue > target ? target : curValue;
        var curKey:String;
        if (curValue >= target) {
            curKey = "street_reward_score_cur";
        } else {
            curKey = "street_reward_score_cur_not_finish";
        }

        item.target_txt.text = CLang.Get(langKey, {v1:target}) + CLang.Get(curKey, {v1:curValue, v2:target});

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = item.reward_list;
        (rewardViewExternal.view as CRewardItemListView).forceAlign = 1;
        rewardViewExternal.show();
        rewardViewExternal.setData(datasource.reward);
        rewardViewExternal.updateWindow();

        item.get_btn.visible = false;
        item.not_finish.visible = false;

        var hasReward:Boolean = _streetData.rewardData.hasRewarded(datasource.ID);
        var isFinish:Boolean = curValue >= target;
        if (isFinish) {
            if (hasReward) {
                item.get_btn.visible = true;
                item.get_btn.label = CLang.Get("street_has_get");
                item.get_btn.clickHandler = null;
                ObjectUtils.gray(item.get_btn, true);
            } else {
                ObjectUtils.gray(item.get_btn, false);
                item.get_btn.label = CLang.Get("street_can_get");
                item.get_btn.visible = true;
                item.get_btn.clickHandler = new Handler(_getReward, [item]);
            }
        } else {
            item.not_finish.visible = true;
            item.not_finish.text = CLang.Get("street_not_finish");
        }
    }

    private function _getReward(item:StreetFighterAwardItem01UI) : void {
        var datasource:StreetFighterReward = item.dataSource as StreetFighterReward;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.REWARD_GET_REWARD, datasource));

    }

    private function _getTargetLangByType(type:int) : String {
        if (type == CStreetFighterRewardData.TYPE_FIGHT_COUNT) {
            return "street_fighter_reward_fight_target";
        } else if (type == CStreetFighterRewardData.TYPE_WIN_COUNT) {
            return "street_fighter_reward_win_target";
        } else {
            return "street_fighter_reward_always_win_target";
        }
    }

    [Inline]
    private function get _ui() : StreetFighterAwardUI {
        return rootUI as StreetFighterAwardUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        return super._data[0] as CStreetFighterData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
