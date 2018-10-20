//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmView {

import kof.game.common.view.event.CViewEvent;
import kof.game.gm.event.EGmEventType;
import kof.ui.gm.GMViewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CGmSkillView extends CGmChildView {
    public function CGmSkillView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();

    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);

    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        _ui.skill_select_btn.clickHandler = new Handler(_onSelect);
        _ui.skill_show_area_btn.clickHandler = new Handler(_onShowArea);
        _ui.skill_close_area_btn.clickHandler = new Handler(_onCloseArea);
        _ui.skill_open_max_attack_power_btn.clickHandler = new Handler(_onOpenMaxAtkPower);
        _ui.skill_close_max_attack_power_btn.clickHandler = new Handler(_onCloseMaxAtkPower);
        _ui.skill_open_max_power_btn.clickHandler = new Handler(_onOpenMaxPower);
        _ui.skill_close_max_power_btn.clickHandler = new Handler(_onCloseMaxPower);
        _ui.skill_open_no_cd_btn.clickHandler = new Handler(_onOpenNoCD);
        _ui.skill_close_no_cd_btn.clickHandler = new Handler(_onCloseNoCD);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.skill_select_btn.clickHandler = null;
        _ui.skill_show_area_btn.clickHandler = null;
        _ui.skill_close_area_btn.clickHandler = null;
        _ui.skill_open_max_attack_power_btn.clickHandler = null;
        _ui.skill_close_max_attack_power_btn.clickHandler = null;
        _ui.skill_open_max_power_btn.clickHandler = null;
        _ui.skill_close_max_power_btn.clickHandler = null;
        _ui.skill_open_no_cd_btn.clickHandler = null;
        _ui.skill_close_no_cd_btn.clickHandler = null;
    }
    private function _onSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_PANEL, 3));
    }
    private function _onShowArea() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_OPEN_AREA));
    }
    private function _onCloseArea() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_CLOSE_AREA));
    }
    private function _onOpenMaxAtkPower() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_OPEN_MAX_ATK_POWER));
    }
    private function _onCloseMaxAtkPower() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_CLOSE_MAX_ATK_POWER));
    }
    private function _onOpenMaxPower() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_OPEN_POWER));
    }
    private function _onCloseMaxPower() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_CLOSE_POWER));
    }
    private function _onOpenNoCD() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_OPEN_NO_CD));
    }
    private function _onCloseNoCD() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_CLOSE_NO_CD));
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        return true;
    }
    public override function set enable(v:Boolean) : void {
        //if (enable == v) return ;
        super.enable = v;
        _ui.skill_sub_box.visible = enable;

    }
    public override function get panel() : Component { return _ui.skill_box; }

    private function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }
}
}
