//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.level {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.IUICanvas;
import kof.ui.master.PeakGame.PeakGameLevelItemUI;
import kof.ui.master.PeakGame.PeakGameLevelUI;

import morn.core.components.Button;

import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CPeakGameLevelView extends CRootView {

    public function CPeakGameLevelView() {
        super(PeakGameLevelUI, null, null, false);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _curLevelRecord = null;
        var box:Button;
        var func:Function;
        for (var i:int = 0; i < 7; i++) {
            box = _ui["level_" + (i+1) + "_box"];
            func = this["_onLevelClick" + (i+1)];
            box.clickHandler = new Handler(func);
        }
    }

    protected override function _onHide() : void {
        var box:Button;
        var func:Function;
        for (var i:int = 0; i < 7; i++) {
            box = _ui["level_" + (i+1) + "_box"];
            func = this["_onLevelClick" + (i+1)];
            box.clickHandler = null;
        }
    }



    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        // levelname做到ui上了
        var list:Vector.<Object> = _peakGameData.peakLevelTable.toVector();
        var levelItem:PeakGameLevelItemUI;
        var record:PeakScoreLevel;
        for (var i:int = 0; i < 7 && i < list.length; i++) {
            levelItem = _ui["level_item" + (i+1)] as PeakGameLevelItemUI;
            record = _peakGameData.getLevelRecordByLevelID(i+1);
            if (record) {
                CPeakGameLevelItemUtil.setValue(levelItem, record.levelId, 3, record.levelName, false, false);
            }
        }

        _curLevelRecord = _peakGameData.peakLevelRecord;
        _updateDesc();

        this.addToPopupDialog();
        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        // this.setChildrenData(v as CPeakGameData);
    }

    private function _updateDesc() : void {
        if (_curLevelRecord == null) return ;
        // _ui.info_level_name_txt.text = _curLevelRecord.peakLevelName;
        var subLvNameTxt:Label;
        var subLvScoreTxt:Label;
        var subLevelItem:PeakGameLevelItemUI;
        var i:int = 0;
        for (i = 0; i < 3; i++) {
            var subLevel:PeakScoreLevel = _peakGameData.getLevelRecordByLevelNSubID(_curLevelRecord.levelId, 3-i);
            subLvNameTxt = _ui["sub_level_name" + (i+1) + "_txt"];
            subLvScoreTxt = _ui["sub_level_score" + (i+1) + "_txt"];
            subLevelItem = _ui["sub_level_item" + (i+1)] as PeakGameLevelItemUI;
            subLvNameTxt.text = subLevel.levelName;
            var sTopLimit:String;
            var iTopLimit:int = subLevel.scoreTopLimit;
            if (iTopLimit == -1) {
                sTopLimit = CLang.Get("peak_sub_score_range_limit");
            } else {
                sTopLimit = iTopLimit.toString();
            }
            subLvScoreTxt.text = CLang.Get("peak_sub_score_range", {v1:subLevel.scoreBottomLimit, v2:sTopLimit});
            CPeakGameLevelItemUtil.setValue(subLevelItem, subLevel.levelId, subLevel.subLevelId, subLevel.levelName, false);
        }

        for (i = 0; i < 7; i++) {
            var btn:Button = _ui["level_" + (i+1) + "_box"] as Button;
            if (i == (_curLevelRecord.levelId-1)) {
                btn.selected = true;
            } else {
                btn.selected = false;
            }
        }
    }
    // ====================================event=============================
    private function _onLevelClick1() : void { _onLevelClickB(1); }
    private function _onLevelClick2() : void { _onLevelClickB(2); }
    private function _onLevelClick3() : void { _onLevelClickB(3); }
    private function _onLevelClick4() : void { _onLevelClickB(4); }
    private function _onLevelClick5() : void { _onLevelClickB(5); }
    private function _onLevelClick6() : void { _onLevelClickB(6); }
    private function _onLevelClick7() : void { _onLevelClickB(7); }

    private function _onLevelClickB(id:int) : void {
        _curLevelRecord = _peakGameData.getLevelRecordByLevelID(id);
        _updateDesc();
    }

    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameLevelUI {
        return rootUI as PeakGameLevelUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _curLevelRecord:PeakScoreLevel;
}
}
