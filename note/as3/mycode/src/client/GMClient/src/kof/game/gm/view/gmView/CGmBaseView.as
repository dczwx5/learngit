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

public class CGmBaseView extends CGmChildView {
    public function CGmBaseView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
        _ui.base_call_hero_count_txt.text = "1";

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
        _ui.base_select_btn.clickHandler = new Handler(_onSelect);
        _ui.base_open_all_AI_btn.clickHandler = new Handler(_onOpenAI);
        _ui.base_close_all_AI_btn.clickHandler = new Handler(_onCloseAI);
        _ui.base_killall_btn.clickHandler = new Handler(_onKillAll);
        _ui.base_call_hero_btn.clickHandler = new Handler(_onCallHero);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.base_select_btn.clickHandler = null;
        _ui.base_open_all_AI_btn.clickHandler = null;
        _ui.base_close_all_AI_btn.clickHandler = null;
        _ui.base_killall_btn.clickHandler = null;
        _ui.base_call_hero_btn.clickHandler = null;
    }
    private function _onSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_PANEL, 1));
    }
    private function _onOpenAI() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_BASE_OPEN_ALL_AI));
    }
    private function _onCloseAI() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_BASE_CLOSE_ALL_AI));
    }
    private function _onKillAll() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_BASE_KILL_ALL));
    }
    private function _onCallHero() : void {
        var heroID:int = (int)(_ui.base_call_hero_id_txt.text);
        var count:int = (int)(_ui.base_call_hero_count_txt.text);
        var camp:int = (int)(_ui.base_call_hero_camp_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_BASE_CALL_HERO, [heroID, count, camp]));
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        return true;
    }
    public override function set enable(v:Boolean) : void {
        //if (enable == v) return ;
        super.enable = v;
        _ui.base_sub_box.visible = enable;
    }
    public override function get panel() : Component { return _ui.base_box; }

    private function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }
}
}
