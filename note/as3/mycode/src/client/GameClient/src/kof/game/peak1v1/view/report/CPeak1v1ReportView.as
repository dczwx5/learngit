//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.view.report {

import kof.game.common.CLang;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1ReportData;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.peakGame.enum.EPeakResultType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1ReportItemUI;
import kof.ui.master.peak1v1.Peak1v1ReportUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeak1v1ReportView extends CRootView {

    public function CPeak1v1ReportView() {
        super(Peak1v1ReportUI, null, EPeak1v1WndResType.PEAK_1V1_REPORT, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.tips_txt.text = CLang.Get("peak1v1_report_tips");
        _heroItemRender = new CHeroListItemRender();

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

        _heroItemRender.isShowQuality = false;
        _heroItemRender.isShowLevel = false;

        _ui.item_list.dataSource = _Data.reportData.list;

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        var item:Peak1v1ReportItemUI = com as Peak1v1ReportItemUI;
        if (!item) {
            return ;
        }
        var data:CPeak1v1ReportData = item.dataSource as CPeak1v1ReportData;
        if (!data) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        // 结果 0：失败 1：成功 2: 战平 3：完胜 data
        // 结果 0: 胜利 1: 平局 2: 失败         ui
        switch (data.result) {
            case EPeakResultType.LOSE :
                item.result_clip.index = 2;
                break;
            case EPeakResultType.TIE :
                item.result_clip.index = 1;
                break;
            case EPeakResultType.WIN :
            case EPeakResultType.FULL_WIN :
                item.result_clip.index = 0;
                break;
        }

        // 连胜
        if (data.alwaysWin > 0) {
            var strWinningCount:String = CLang.getCommonNumber(data.alwaysWin);
            item.winning_txt.text = strWinningCount + CLang.Get("peak1v1_winning_count");
            item.winning_box.visible = true;
        } else {
            item.winning_box.visible = false;
        }

        // 第X轮
        item.round_txt.text = CLang.Get("peak1v1_round", {v1:data.round});


        // 头像
        item.my_icon.dataSource = data.myHeroData;
        _heroItemRender.renderItemFlatSmall(item.my_icon, 0);

        // 名字
        item.my_name_txt.text = data.name;
        var hpMax:int = Math.max(1, data.fightHeroHpMax);
        var iPercent100:int = (100*(data.fightHeroHp/hpMax));
        item.my_hp_percent_txt.text = iPercent100 + "%";
        var fPercent:Number = iPercent100/100;
        item.my_hp_bar.value = fPercent;

        // 积分变化
        if (data.updateScore > 0) {
            item.my_score_change_clip.index = 0;
            item.my_score_change_txt.text = CLang.Get("peak1v1_green", {v1:("+" + data.updateScore)});

        } else if(data.updateScore < 0) {
            item.my_score_change_clip.index = 1;
            item.my_score_change_txt.text = CLang.Get("peak1v1_red", {v1:(data.updateScore)});
        } else {
            item.my_score_change_clip.index = 1;
            item.my_score_change_txt.text = CLang.Get("peak1v1_red", {v1:(data.updateScore)});
        }

        // ======================= 敌人
        // 头像
        item.enemy_icon.dataSource = data.enemyHeroData;
        _heroItemRender.renderItemFlatSmall(item.enemy_icon, 0);

        // 名字
        item.enemy_name_txt.text = data.enemyName;
        hpMax = Math.max(1, data.enemyFightHeroHpMax);
        iPercent100 = (100*(data.enemyFightHeroHp/hpMax));
        item.enemy_hp_percent_txt.text = iPercent100 + "%";
        fPercent = iPercent100/100;
        item.enemy_hp_bar.value = fPercent;

        if (data.enemyUpdateScore > 0) {
            item.enemy_score_change_clip.index = 0;
            item.enemy_score_change_txt.text = CLang.Get("peak1v1_green", {v1:("+" + data.enemyUpdateScore)});
        } else if(data.enemyUpdateScore < 0) {
            item.enemy_score_change_clip.index = 1;
            item.enemy_score_change_txt.text = CLang.Get("peak1v1_red", {v1:(data.enemyUpdateScore)});
        } else {
            item.enemy_score_change_clip.index = 1;
            item.enemy_score_change_txt.text = CLang.Get("peak1v1_red", {v1:(data.enemyUpdateScore)});
        }
        item.gm_report_btn.clickHandler = new Handler(_onGmReport, [item]);

    }
    private function _onGmReport(item:Peak1v1ReportItemUI) : void {
        var data:CPeak1v1ReportData = item.dataSource as CPeak1v1ReportData;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.REPORT_GM_REPORT_CLICK, data));
    }
    // ====================================event=============================

    //===================================get/set======================================

    [Inline]
    private function get _ui() : Peak1v1ReportUI {
        return rootUI as Peak1v1ReportUI;
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
    private var _heroItemRender:CHeroListItemRender;

}
}
