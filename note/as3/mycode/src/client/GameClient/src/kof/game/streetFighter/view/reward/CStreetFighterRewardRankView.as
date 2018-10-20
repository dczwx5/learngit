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
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterRewardData;
import kof.table.StreetFighterReward;
import kof.ui.master.StreetFighter.StreetFighetAwardItemUI;
import kof.ui.master.StreetFighter.StreetFighterAwardUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;


public class CStreetFighterRewardRankView extends CChildView {
    public function CStreetFighterRewardRankView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {


    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.rank_list.renderHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 0) {
            return true;
        }
        _ui.tips.visible = true;
        _ui.rank_list.renderHandler = new Handler(_onRenderItem);

        _ui.rank_list.visible = true;
        _ui.item_list.visible = false;
        var datalist:Array = _streetData.rewardData.getRewardRecordListByType([CStreetFighterRewardData.TYPE_SCORE_RANK_COUNT]);
        _ui.rank_list.dataSource = datalist;

        return true;
    }

    private function _onRenderItem(comp:Component, idx:int) : void {
        var item:StreetFighetAwardItemUI = comp as StreetFighetAwardItemUI;
        var dataSource:StreetFighterReward = item.dataSource as StreetFighterReward;
        if (!dataSource) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var minRanking:int = dataSource.param[0] as int;
        var maxRanking:int = dataSource.param[1] as int;
        if (dataSource.index <= 3) {
            item.rank_txt.visible = false;
            item.rank_clip.visible = true;
            item.rank_clip.index = dataSource.index - 1;
            item.bg_clip.index = dataSource.index - 1;
        } else {
            item.bg_clip.index = 3;

            item.rank_clip.visible = false;
            item.rank_txt.visible = true;
            if (maxRanking == -1) {
                // 最后一条
                item.rank_txt.text = CLang.Get("street_fighter_ranking_last_desc", {v1:minRanking});
            } else {
                item.rank_txt.text = CLang.Get("street_fighter_ranking_desc", {v1:minRanking, v2:maxRanking});
            }
        }

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = item.reward_list;
        (rewardViewExternal.view as CRewardItemListView).forceAlign = 2;
        rewardViewExternal.show();
        rewardViewExternal.setData(dataSource.reward);
        rewardViewExternal.updateWindow();
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
