//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/17.
 */
package kof.game.common.loading {

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.imp_common.MatchLoadingUI;
import kof.ui.imp_common.MatchProgressUI;
import kof.ui.master.PeakGame.PeakGameLevelItemUI;

import morn.core.components.Image;

import morn.core.components.Label;

import morn.core.components.ProgressBar;

public class CMatchProgressView extends CChildView {
    public function CMatchProgressView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        // can not call super._onShow in this class
        // this.listenEvent(CLoadingEvent.LOADING_PROCESS_UPDATE, _onUpdate);
        _ui.img210002.visible = false;
        _ui.img_name_210002.visible = false;
        _ui.scene_img.visible = false;
        _ui.scene_name_img.visible = false;
        _ui.left_box.visible = false;
        _ui.right_box.visible = false;
        _ui.title_img.visible = false;
        _ui.white_img.visible = false;
        _ui.all_white_img.visible = false;
        _ui.top_black_img.visible = false;
        _ui.bottom_black_img.visible = false;
        _virtualRate1 = 0;
        _virtualRate2 = 0;
        _isLoadFinish1 = false;
        _isLoadFinish2 = false;
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var isSelfP1:Boolean = _matchData.isSelfP1;
        var p1LevelBtn:PeakGameLevelItemUI;
        var p2LevelBtn:PeakGameLevelItemUI;
        if (isSelfP1) {
            p1LevelBtn = _ui.level_1_btn;
            p2LevelBtn = _ui.level_2_btn;
        } else {
            p1LevelBtn = _ui.level_2_btn;
            p2LevelBtn = _ui.level_1_btn;
        }

        var peakData:CPeakGameData = ((uiCanvas as CAppSystem).stage.getSystem(CPeakGameSystem) as CPeakGameSystem).peakGameData;
        var levelRecord:PeakScoreLevel = peakData.getLevelRecordByID(peakData.scoreLevelID);
        if (levelRecord)
            CPeakGameLevelItemUtil.setValue(p1LevelBtn, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);

        levelRecord = peakData.getLevelRecordByID(_matchData.enemyScoreLevelID);
        if (levelRecord)
            CPeakGameLevelItemUtil.setValue(p2LevelBtn, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);

        return true;
    }

    public function get curSceneImage() : Image {
        if (_matchData.instanceID == 210002 || 220002 == _matchData.instanceID || 190201 == _matchData.instanceID) {
            return _ui.img210002; // 甲子园
        } else {
            return _ui.scene_img;
        }
    }
    public function get curSceneNameImage() : Image {
        if (_matchData.instanceID == 210002 || 220002 == _matchData.instanceID || 190201 == _matchData.instanceID) {
            return _ui.img_name_210002;
        } else {
            return _ui.scene_name_img;
        }
    }

    protected override function _onEnterFrame(delta:Number) : void {
        var isSelfP1:Boolean = _matchData.isSelfP1;
        if (isSelfP1) {
            _updatePlayerProgress(1, _matchData.myProgress, _playerData.teamData.name);
            _updatePlayerProgress(2, _enemyProgressData.enemyProgress, _matchData.enemyName);
        } else {
            _updatePlayerProgress(1, _enemyProgressData.enemyProgress, _matchData.enemyName);
            _updatePlayerProgress(2, _matchData.myProgress, _playerData.teamData.name);
        }
    }

    // ran : 0 ~ 0.01 即1%
    // +0.005 , 即结果为0.5%~1.5%
    private function _randomAddRate() : Number {
        return Math.random() * 100 / 10000 + 0.005;
    }
    private function _updatePlayerProgress(pX:int, progress:int, name:String) : void {
        var reallyProgressRate:Number = progress/10000;
        if (pX == 1) {
            if (_isLoadFinish1) {
                _virtualRate1 += _randomAddRate() * 10; // 即15%
            } else {
                if (_virtualRate1 < reallyProgressRate) {
                    _virtualRate1 += _randomAddRate();
                }
            }
            if (progress >= 10000) {
                _isLoadFinish1 = true;
            }
        } else {
            if (_isLoadFinish2) {
                _virtualRate2 += _randomAddRate() * 10; // 即15%
            } else {
                if (_virtualRate2 < reallyProgressRate) {
                    _virtualRate2 += _randomAddRate();
                }
            }
            if (progress >= 10000) {
                _isLoadFinish2 = true;
            }
        }
        if (_virtualRate1 > 1) {
            _virtualRate1 = 1;
        }
        if (_virtualRate2 > 1) {
            _virtualRate2 = 1;
        }

        var progressRate:Number; //  = progress/10000;
        var progressRateString:String; //  = (_virtualRate2*100).toFixed(); // (progressRate*100).toFixed();
        var bar:ProgressBar;
        var progressTxt:Label;
        var nameTxt:Label;
        if (pX == 1) {
            progressRate = _virtualRate1;
            progressRateString = (_virtualRate1*100).toFixed();
            bar = _ui.progress_1_bar;
            progressTxt = _ui.progress_1_txt;
            nameTxt = _ui.player_name_1_txt;
        } else {
            progressRate = _virtualRate2;
            progressRateString = (_virtualRate2*100).toFixed();
            bar = _ui.progress_2_bar;
            progressTxt = _ui.progress_2_txt;
            nameTxt = _ui.player_name_2_txt;
        }

        bar.value = progressRate;
        progressTxt.text = CLang.Get("common_loading_progress", {v1:progressRateString});
        nameTxt.text = name;

        if (isLoadFinish()) {
            rootView.dispatchEvent(new CLoadingEvent(CLoadingEvent.VIRTUAL_LOAD_FINISHED));
        }
    }

    private var _virtualRate1:Number;
    private var _virtualRate2:Number; // 虚假的, 模拟进度
    private var _isLoadFinish1:Boolean;
    private var _isLoadFinish2:Boolean;

    public function isLoadFinish() : Boolean {
        return _virtualRate1 > 0.999999 && _virtualRate2 > 0.999999;
    }

    [Inline]
    public function get _ui() : MatchProgressUI {
        return (rootUI as MatchLoadingUI).progress_view;
    }
    [Inline]
    private function get _matchData() : CMatchData {
        return super._data[0] as CMatchData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
    // 对方进度数据
    [Inline]
    private function get _enemyProgressData() : CProgressData {
        return _data[2] as CProgressData;
    }

}
}
