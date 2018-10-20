//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view.report {

import QFLib.Foundation.CTime;

import kof.game.common.CLang;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.report.CStreetFighterReportItemData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.ui.master.StreetFighter.StreetFighterRecordItemUI;
import kof.ui.master.StreetFighter.StreetFighterRecordUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;


public class CStreetFighterReportView extends CRootView {

    public function CStreetFighterReportView() {
        super(StreetFighterRecordUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _heroItemRender = new CHeroListItemRender();

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.list.renderHandler = new Handler(_onRenderItem);
    }
    protected override function _onHide() : void {

    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        _heroItemRender.isShowQuality = false;
        _heroItemRender.isShowLevel = false;

        var dataList:Array = _streetData.reportData.list;
        _ui.list.dataSource = dataList;
        _ui.list.visible = dataList && dataList.length > 0;

        this.addToPopupDialog();

        return true;
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:StreetFighterRecordItemUI = box as StreetFighterRecordItemUI;
        if (item == null) return ;
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var reportData:CStreetFighterReportItemData = item.dataSource as CStreetFighterReportItemData;

        ObjectUtils.gray(item.hero1_view, false);
        ObjectUtils.gray(item.hero2_view, false);
        // self
        item.hero1_view.dataSource = reportData.selfData;
        _heroItemRender.renderItemFlatSmall(item.hero1_view, 0);
        item.hero1_name_txt.text = reportData.name;

        // enemy
        item.hero2_view.dataSource = reportData.enemyData.heroData;
        _heroItemRender.renderItemFlatSmall(item.hero2_view, 0);
        item.hero2_name_txt.text = reportData.enemyData.name;


        item.date_txt.text = reportData.time.toString(); // test todo : fix it
        // reportData.result 0：失败 1：成功 2: 战平 3：完胜
        // ui : 0胜, 1平, 2负, 3完胜
        if (0 == reportData.result) {
            // 负
            item.result_clip.index = 2;
            item.bg_clip.index = 2;
            ObjectUtils.gray(item.hero1_view, true);
        } else if (1 == reportData.result) {
            // 胜
            item.bg_clip.index = 1;
            item.result_clip.index = 0;
            ObjectUtils.gray(item.hero2_view, true);
        } else if (2 == reportData.result) {
            // 平
            item.bg_clip.index = 2;
            item.result_clip.index = 1;
        } else if (3 == reportData.result) {
            // 完胜
            item.bg_clip.index = 0;
            ObjectUtils.gray(item.hero2_view, true);
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

        var dateSub:Number = CTime.dateSub(CTime.getCurrServerTimestamp(), reportData.time);
        dateSub = Math.abs(dateSub);
        if (dateSub == 0) {
            item.date_txt.text = CLang.Get("common_today");
        } else {
            item.date_txt.text = CLang.Get("common_last_day", {v1:dateSub});
        }
        item.gm_report_btn.clickHandler = new Handler(_gmReport, [item]);
    }
    private function _gmReport(item:StreetFighterRecordItemUI) : void {
        var reportData:CStreetFighterReportItemData = item.dataSource as CStreetFighterReportItemData;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.REPORT_GM_REPORT_CLICK, reportData));
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : StreetFighterRecordUI {
        return rootUI as StreetFighterRecordUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStreetFighterData;
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
