//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.report {

import QFLib.Foundation.CTime;

import kof.game.GMReport.CGMReportSystem;

import kof.game.common.CLang;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameReportItemData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameReportItemUI;
import kof.ui.master.PeakGame.PeakGameReportUI;
import morn.core.components.Box;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CPeakGameReportView extends CRootView {

    public function CPeakGameReportView() {
        super(PeakGameReportUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _heroItemRender = new CHeroListItemRender();

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.item_list.renderHandler = new Handler(_onRenderItem);
        _curPage = 0;
    }

    protected override function _onHide() : void {
        _ui.item_list.renderHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var peakSystem:CPeakGameSystem = system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem;

        _heroItemRender.isShowQuality = peakSystem.isShowQuality;
        _heroItemRender.isShowLevel = peakSystem.isShowLevel;

        var dataList:Array = _peakGameData.reportData.list;
        _ui.item_list.dataSource = dataList;
        _ui.item_list.visible = dataList && dataList.length > 0;

        this.addToPopupDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
    }

    // ====================================event=============================

    private function _onRenderItem(box:Box, idx:int) : void {
        var item:PeakGameReportItemUI = box as PeakGameReportItemUI;
        if (item == null) return ;
        if (item.dataSource == null) return ;

        var reportData:CPeakGameReportItemData = item.dataSource as CPeakGameReportItemData;
        var levelRecord:PeakScoreLevel;

        ObjectUtils.gray(item.hero1_list, false);
        ObjectUtils.gray(item.hero2_list, false);
        // self
        item.hero1_list.renderHandler = new Handler(_heroItemRender.renderItemFlatSmall);
        item.hero1_list.dataSource = reportData.selfData.list;
        item.hero1_name_txt.text = _playerData.teamData.name;

        var myScoreLevelID:int = reportData.scoreLevelID;
        if (myScoreLevelID == 0) {
            myScoreLevelID = _peakGameData.scoreLevelID;
        }
        levelRecord = _peakGameData.getLevelRecordByID(myScoreLevelID);
        CPeakGameLevelItemUtil.setValue(item.level_item1, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);

        // enemy
        item.hero2_list.renderHandler = new Handler(_heroItemRender.renderItemFlatSmall);
        // 右边的要反过来显示, 不满3个人的时候，显示会有问题
        var heroList2:Array = new Array(3);
        var heroList2Temp:Array = reportData.enemyData.heroList.list;
        {
            for (var i:int = 0; i < 3; i++) {
                if (i < heroList2Temp.length) {
                    heroList2[i] = heroList2Temp[i];
                } else {
                    heroList2[i] = null;
                }
            }
            heroList2 = heroList2.reverse();
        }
        item.hero2_list.dataSource = heroList2;
        item.hero2_name_txt.text = reportData.enemyData.name;

        levelRecord = _peakGameData.getLevelRecordByID(reportData.enemyData.peakLevel);
        CPeakGameLevelItemUtil.setValue(item.level_item2, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);

        item.date_txt.text = reportData.time.toString(); // test todo : fix it
        // reportData.result 0：失败 1：成功 2: 战平 3：完胜
        // ui : 0胜, 1平, 2负, 3完胜
        if (0 == reportData.result) {
            // 负
            item.result_clip.index = 2;
            item.bg_clip.index = 2;
            ObjectUtils.gray(item.hero1_list, true);
        } else if (1 == reportData.result) {
            // 胜
            item.bg_clip.index = 1;
            item.result_clip.index = 0;
            ObjectUtils.gray(item.hero2_list, true);
        } else if (2 == reportData.result) {
            // 平
            item.bg_clip.index = 2;
            item.result_clip.index = 1;
        } else if (3 == reportData.result) {
            // 完胜
            item.bg_clip.index = 0;
            ObjectUtils.gray(item.hero2_list, true);
            item.result_clip.index = 3;
        }
        item.score_title_txt.text = CLang.Get("common_score"); //
        if (reportData.updateScore > 0) {
            item.score_txt.text = CLang.Get("peak_score_add", {v1:reportData.updateScore});
            item.arrow_clip.index = 0;
        } else if (reportData.updateScore < 0) {
            item.score_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(reportData.updateScore)});
            item.arrow_clip.index = 1;

        } else {
            // == 0
            if (0 == reportData.result) {
                item.score_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(reportData.updateScore)});
                item.arrow_clip.index = 1;
            } else {
                item.arrow_clip.index = 0;
                item.score_txt.text = CLang.Get("peak_score_add", {v1:reportData.updateScore});
            }
        }

        var dateSub:int = CTime.dateSub(CTime.getCurrServerTimestamp(), reportData.time); // Math.abs();
        dateSub = Math.abs(dateSub);
        if (dateSub == 0) {
            item.date_txt.text = CLang.Get("common_today");
        } else {
            item.date_txt.text = CLang.Get("common_last_day", {v1:dateSub});
        }
        item.gm_report_btn.clickHandler = new Handler(_gmReport, [item]);
    }
    private function _gmReport(item:PeakGameReportItemUI) : void {
        var reportData:CPeakGameReportItemData = item.dataSource as CPeakGameReportItemData;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.REPORT_GM_REPORT_CLICK, reportData));
    }
    //===================================get/set======================================
    [Inline]
    private function get _ui() : PeakGameReportUI {
        return rootUI as PeakGameReportUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _curPage:int;
    private var _heroItemRender:CHeroListItemRender;

}
}
