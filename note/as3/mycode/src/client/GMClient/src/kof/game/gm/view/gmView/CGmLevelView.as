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

public class CGmLevelView extends CGmChildView {
    public function CGmLevelView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
        _ui.level_instance_id_txt.text = "10001";
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
        _ui.level_select_btn.clickHandler = new Handler(_onSelect);
        _ui.level_enter_instance_btn.clickHandler = new Handler(_onEnterInstance);
        _ui.level_pass_btn.clickHandler = new Handler(_onPassInstance);
        _ui.level_next_btn.clickHandler = new Handler(_onNextLevel);
        _ui.level_open_all_chapter_btn.clickHandler = new Handler(_onOpenAllChapter);
        _ui.level_exit_btn.clickHandler = new Handler(_onExitInstance);
        _ui.level_killAllDiffCamp.clickHandler = new Handler(_onKill,["removeAllDiffCampObject"]);
        _ui.level_killOneDiffCamp.clickHandler = new Handler(_onKill,["removeOneDiffCampObject"]);
        _ui.level_killAllCamp.clickHandler = new Handler(_onKill,["removeAllCampObject"]);
        _ui.level_killOneCamp.clickHandler = new Handler(_onKill,["removeOneCampObject"]);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.level_select_btn.clickHandler = null;
        _ui.level_enter_instance_btn.clickHandler = null;
        _ui.level_pass_btn.clickHandler = null;
        _ui.level_next_btn.clickHandler = null;
        _ui.level_exit_btn.clickHandler = null;
        _ui.level_killAllDiffCamp.clickHandler = null;
        _ui.level_killOneDiffCamp.clickHandler = null;
        _ui.level_killAllCamp.clickHandler = null;
        _ui.level_killOneCamp.clickHandler = null;
    }

    private function _onKill(... args):void{
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MENU_CMD, args));
    }

    private function _onSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_PANEL, 0));
    }
    private function _onEnterInstance() : void {
        var instanceContentID:int = (int)(_ui.level_instance_id_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_LEVEL_ENTER_INSTANCE, instanceContentID));
    }
    private function _onPassInstance() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_LEVEL_PASS_INSTANCE));
    }
    private function _onExitInstance() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MENU_CMD, ["exit_instance", ""]));
    }
    private function _onNextLevel() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_LEVEL_NEXT_LEVEL));
    }
    private function _onOpenAllChapter() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.ENVENT_LEVEL_OPEN_ALL_CHAPTER));

    }
    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        return true;
    }
    public override function set enable(v:Boolean) : void {
        //if (enable == v) return ;
        super.enable = v;
        _ui.level_sub_box.visible = enable;

    }
    public override function get panel() : Component { return _ui.level_box; }

    private function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }
}
}
