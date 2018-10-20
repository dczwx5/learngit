//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.view.main {

import flash.utils.getTimer;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.rank.CStreetFighterRankItemData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.ui.master.StreetFighter.StreetFighterRankItem1UI;
import kof.ui.master.StreetFighter.StreetFighterUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;


public class CStreetFighterMainRankView extends CChildView {
    public function CStreetFighterMainRankView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.rank_list.renderHandler = new Handler(_onRenderRankItem);
        _ui.rank_refresh_btn.clickHandler = new Handler(_onRefresh);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.rank_list.renderHandler = null;
        _ui.rank_refresh_btn.clickHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;


        var baseList:Array;
        if (_streetData.rankData.list) {
            baseList = _streetData.rankData.list.list;
        }

        if (!baseList || baseList.length == 0) {
            _ui.rank_no_data_txt.visible = true;
        } else {
            _ui.rank_no_data_txt.visible = false;
        }

        var rankList:Array = new Array();
        for (var i:int = 0; i < baseList.length && i < 5; i++) {
            rankList[rankList.length] = baseList[i];
        }
        _ui.rank_list.dataSource = rankList;

        var myRankData:CStreetFighterRankItemData;
        for each (var rankData:CStreetFighterRankItemData in baseList) {
            if (rankData.roleID == _playerData.ID) {
                myRankData = rankData;
            }
        }

        _ui.my_rank_view.dataSource = myRankData;
        _onRenderRankItem(_ui.my_rank_view, 100);
        _ui.my_rank_not_in_rank_txt.visible = myRankData == null;

        return true;
    }

    private function _onRenderRankItem(comp:Component, idx:int) : void {
        var item:StreetFighterRankItem1UI = comp as StreetFighterRankItem1UI;
        var data:CStreetFighterRankItemData = item.dataSource as CStreetFighterRankItemData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        if (data.ranking <= 3) {
            item.rank_clip.visible = true;
            item.rank_txt.visible = false;
            item.rank_clip.index = data.ranking-1;
        } else {
            item.rank_clip.visible = false;
            item.rank_txt.visible = true;
            item.rank_txt.text = data.ranking.toString();
        }

        item.name_txt.text = data.name;
        item.score_txt.text = CLang.Get("common_score") + "：" + data.historyHighScore;
    }

    private function _onRefresh() : void {
        if (getTimer() - _lastRefreshTime < 1000) {
            return ;
        }
        _lastRefreshTime = getTimer();

        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_REFRESH_CLICK));
     }
    private var _lastRefreshTime:int;

    [Inline]
    private function get _ui() : StreetFighterUI {
        return rootUI as StreetFighterUI;
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
