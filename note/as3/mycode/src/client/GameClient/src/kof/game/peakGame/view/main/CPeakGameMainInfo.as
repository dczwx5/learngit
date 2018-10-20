//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.view.main {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameUI;


public class CPeakGameMainInfo extends CChildView {
    public function CPeakGameMainInfo() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _ui.info_score_title_txt.text = CLang.Get("common_score");
        _ui.info_fight_count_title_txt.text = CLang.Get("common_fight2");
        _ui.info_win_count_title_txt.text = CLang.Get("peak_win_count_title");
        _ui.info_win_rate_title_txt.text = CLang.Get("common_win_rate");
        // _ui.info_rank_txt.visible = false;
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        if (!_peakGameData) return true;

        if (_peakGameData.isServerData == false) {
            return true;
        }

        if(_peakGameData.peakLevelRecord)
        {
//            _ui.info_score_txt.text = _peakGameData.score.toString();
            var bottomLimit:int = _peakGameData.peakLevelRecord.scoreBottomLimit == 0 ? 1000 : _peakGameData.peakLevelRecord.scoreBottomLimit;
            var curr:String = HtmlUtil.color((_peakGameData.score - bottomLimit)+"", "#7bff47");

            var total:String;
            if(_peakGameData.peakLevelRecord.scoreTopLimit - bottomLimit < 0)
            {
                total = HtmlUtil.color("∞", "#fffce9");
            }
            else
            {
                total = HtmlUtil.color((_peakGameData.peakLevelRecord.scoreTopLimit - bottomLimit)+"", "#fffce9");
            }

            _ui.info_score_txt.isHtml = true;
            _ui.info_score_txt.text = curr + "/" + total;
            _ui.info_score_txt.stroke = "0x0f520a";
        }
        else
        {
            _ui.info_score_txt.text = "";
        }

        _ui.info_peak_value_txt.text = _peakGameData.currency.toString();

        _ui.info_fight_count_txt.text = _peakGameData.fightCount.toString();
        _ui.info_win_count_txt.text = _peakGameData.winCount.toString();
        if (_peakGameData.fightCount == 0) {
            _ui.info_win_rate_txt.text = "0%";
        } else {
            _ui.info_win_rate_txt.text = _peakGameData.winRate;
        }

        _ui.info_peak_value_title_txt.text = _peakGameData.currencyName;

        var date:Date = new Date(CTime.getCurrServerTimestamp());
        _ui.box_scoreTip.visible = (date.hours >= 0 && date.hours <= 7);

        return true;
    }


    [Inline]
    private function get _ui() : PeakGameUI {
        return rootUI as PeakGameUI;
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
