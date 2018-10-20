//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.view.ranking {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1RankingData;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1RankingItemUI;
import kof.ui.master.peak1v1.Peak1v1RankingUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeak1v1RankingView extends CRootView {

    public function CPeak1v1RankingView() {
        super(Peak1v1RankingUI, null, EPeak1v1WndResType.PEAK_1V1_RANK, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.txt_title.text = CLang.Get("peak1v1_rank_tips");
        _ui.ranking_txt.text = CLang.Get("common_ranking");
        _ui.team_name_txt.text = CLang.Get("common_team_name");
        _ui.score_txt.text = CLang.Get("common_score");

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.item_list.renderHandler = new Handler(_onRenderItem);
    }

    protected override function _onHide() : void {
        _ui.item_list.renderHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        // 最下面自己的信息, 未始化
        _ui.img_vip.visible = false;
        _ui.my_rank_txt.text = CLang.LANG_00300;
        _ui.my_name_txt.text = _playerData.teamData.name;
        _ui.my_score_txt.text = _Data.score.toString();

        var rankingData:Array = _Data.rankingListData.list;

        _ui.item_list.dataSource = rankingData;


        if (rankingData && rankingData.length > 0) {
            for each ( var playerRankData : CPeak1v1RankingData in rankingData ) {
                if ( playerRankData.roleID == _playerData.ID ) {
                    // 最下面自己的信息
                    _ui.my_rank_txt.text = playerRankData.ranking.toString();
                    _ui.my_name_txt.text = _playerData.teamData.name;
                    _ui.my_score_txt.text = _Data.score.toString();
                }
            }
        }


        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        if (!com) return ;
        var data:CPeak1v1RankingData = com.dataSource as CPeak1v1RankingData;
        if (!data) {
            com.visible = false;
            return ;
        }
        com.visible = true;

        var item:Peak1v1RankingItemUI = com as Peak1v1RankingItemUI;
        item.img_vip.visible = false; // _playerData.vipData.vipLv > 0;
        if (data.ranking <= 3) {
            item.special_rank_clip.index = data.ranking - 1;
            item.special_rank_clip.visible = true;
            item.rank_txt.visible = false;
        } else {
            item.special_rank_clip.visible = false;
            item.rank_txt.text = data.ranking.toString();
            item.rank_txt.visible = true;
        }

        item.name_txt.text = data.name;
        item.score_txt.text = data.score.toString();
    }
    // ====================================event=============================

    //===================================get/set======================================

    [Inline]
    private function get _ui() : Peak1v1RankingUI {
        return rootUI as Peak1v1RankingUI;
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
