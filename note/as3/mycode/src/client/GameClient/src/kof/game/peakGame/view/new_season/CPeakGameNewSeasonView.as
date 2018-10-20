//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/31.
 */
package kof.game.peakGame.view.new_season {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameNewSeasonUI;

import morn.core.handlers.Handler;
// 段位奖励
public class CPeakGameNewSeasonView extends CRootView {

    public function CPeakGameNewSeasonView() {
        super(PeakGameNewSeasonUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _ui.desc_txt.text = CLang.Get("peak_new_season_level_desc");
        _ui.tips_txt.text = CLang.Get("peak_new_season_level_reward_title");
        _ui.rank_num.visible = false;
        _ui.rank_test_img.visible = false;
    }
    protected override function _onDispose() : void {
        _coundDownComponent .dispose();
        _coundDownComponent = null;
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _ui.ok_btn.clickHandler = new Handler(_onClickOk);
        _coundDownComponent = new CCountDownCompoent(this,
                _ui.ok_btn, 30000, _onCountDownEnd,
                CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));

    }

    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _coundDownComponent.tick();
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var levelRecord:PeakScoreLevel = _peakGameData.getLevelRecordByID(_peakGameData.lastScoreLevelID);

        var externalUtilLevel : CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
        (externalUtilLevel.view as CRewardItemListView).ui = _ui.reward_list;
        externalUtilLevel.show();
        externalUtilLevel.setData(_peakGameData.lastLevelRewards);
        externalUtilLevel.updateWindow();


        if (levelRecord) {
            CPeakGameLevelItemUtil.setValueBig(_ui.level_item, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);
        }

        this.addToPopupDialog();

        return true;
    }


    // ====================================event=============================
    private function _onClickOk() : void {
        this.close();
    }
    private function _onCountDownEnd() : void {
        this.close();
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameNewSeasonUI {
        return rootUI as PeakGameNewSeasonUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _coundDownComponent:CCountDownCompoent;

}
}
