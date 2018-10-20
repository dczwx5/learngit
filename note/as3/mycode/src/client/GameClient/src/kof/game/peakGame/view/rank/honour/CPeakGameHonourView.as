//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.rank.honour {

import kof.game.common.view.CChildView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameGloryData;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameHornorUI;
import kof.ui.master.PeakGame.PeakGameRankUI;

import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeakGameHonourView extends CChildView {

    public function CPeakGameHonourView() {
        super([CPeakGameHonourHeros], null);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.left_btn.clickHandler = new Handler(_onRight); // page == 0， 为最新季, 所以left和right要反过来
        _ui.right_btn.clickHandler = new Handler(_onLeft);
        _ui.num_list.renderHandler = new Handler(_onRenderSeasonNum);
        _curPage = 0;
    }

    protected override function _onHide() : void {
        _ui.left_btn.clickHandler = null;
        _ui.right_btn.clickHandler = null;
        _ui.num_list.renderHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_rootUI.tab.selectedIndex != 2) return true;

        if (_peakGameData.gloryData.hasData() == false) {
            _ui.team1_box.visible = false;
            _ui.team2_box.visible = false;
            _ui.team3_box.visible = false;
            _ui.title_box.visible = false;
            _ui.left_btn.visible = false;
            _ui.right_btn.visible = false;
            _ui.none_1_img.visible = _ui.none_2_img.visible = _ui.none_3_img.visible = true;

            return true;
        }

        _onChangeB(true);

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        _herosView.setArgs([_curPage]); // season
        _herosView.setData(v, forceInvalid);

    }

    // ====================================event=============================
    private function _onLeft() : void {
        _curPage--;
        _onChangeB(false);
    }
    private function _onRight() : void {
        _curPage++;
        _onChangeB(false);
    }
    private function _onChangeB(updateBtnOnly:Boolean) : void {
        if (_peakGameData.gloryData.hasData() == false) {
            return ;
        }


        var total:int = _peakGameData.gloryData.list.length;
        if (_curPage < 0) _curPage = 0;
        if (_curPage >= total) _curPage = total - 1;
        if (_curPage == 0) {
            _ui.right_btn.visible = false;
        } else {
            _ui.right_btn.visible = true;
        }

        if (_curPage == total - 1) {
            _ui.left_btn.visible = false;
        } else {
            _ui.left_btn.visible = true;
        }
        if (!updateBtnOnly) {
            _herosView.setArgs([_curPage]); // season
            _herosView.setData(_data);
        }
        var gloryData:CPeakGameGloryData = _peakGameData.gloryData.getGloryDataByIndex(_curPage); // 每赛季数据
        if (!gloryData) {
            return ;
        }

        var strSeason:String;
        if (gloryData.season < 10) {
            strSeason = "0" + gloryData.season;
        } else {
            strSeason = gloryData.season.toString();
        }
        var seasonNumList:Array = new Array(strSeason.length);
        for (var i:int = 0; i < strSeason.length; i++) {
            seasonNumList[i] = (int)(strSeason.charAt(i));
        }
        _ui.num_list.dataSource = seasonNumList;
//        _ui.num_clip.index = gloryData.season;
//        _ui.title_txt.text = CLang.Get("peak_glory_title", {v1:gloryData.season});
    }

    private function _onRenderSeasonNum(item:Component, idx:int) : void {
        if (item && item.dataSource != null) {
            var num:int = item.dataSource as int;
            var numClip:Clip = (item.getChildByName("num_clip") as Clip);
            numClip.index = num;
        }
    }
    //===================================get/set======================================

    private function get _herosView() : CPeakGameHonourHeros { return this.getChild(0) as CPeakGameHonourHeros; }

    [Inline]
    private function get _ui() : PeakGameHornorUI {
        return (rootUI as PeakGameRankUI).honorView;
    }
    [Inline]
    private function get _rootUI() : PeakGameRankUI {
        return (rootUI as PeakGameRankUI);
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _curPage:int; // page, 0对应最新的一季数据
}
}
