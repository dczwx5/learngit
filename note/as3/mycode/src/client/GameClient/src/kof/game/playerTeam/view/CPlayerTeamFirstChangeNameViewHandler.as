//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.playerTeam.view {

import flash.events.Event;


import kof.game.common.CLang;
import kof.game.player.data.CPlayerData;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.CRootView;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.ui.master.player_team.ChangeNameUI;

import morn.core.handlers.Handler;


public class CPlayerTeamFirstChangeNameViewHandler extends CRootView {

    public function CPlayerTeamFirstChangeNameViewHandler() {
        super(ChangeNameUI, null, null, false);
    }

    protected override function _onShow():void {
        // do thing when show
        super._onShow();

        var ui:ChangeNameUI = rootUI as ChangeNameUI;
        ui.change_cost_box.visible = false;
        ui.name_input_label.addEventListener(Event.CHANGE, _onTextChange);
        ui.random_name_btn.clickHandler = new Handler(_onRandomName);
        ui.ok_btn.clickHandler = new Handler(_onOk);
        _lastRandomName = "";
        _lastText = "";

        ui.desc_label.text = CLang.Get("player_team_first_cost_desc2");
    }

    protected override function _onHide() : void {
        var ui:ChangeNameUI = rootUI as ChangeNameUI;
        ui.random_name_btn.clickHandler = null;
        ui.ok_btn.clickHandler = null;
        ui.name_input_label.removeEventListener(Event.CHANGE, _onTextChange);
        _lastText = "";

    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var ui:ChangeNameUI = rootUI as ChangeNameUI;
        ui.name_input_label.maxChars = (_data as CPlayerData).playerConstant.NAME_LIMIT;
        if (_lastRandomName.length == 0) {
            _lastText = ui.name_input_label.text = (_data as CPlayerData).teamData.getNoneServerName();
        } else {
            _lastText = ui.name_input_label.text = (_data as CPlayerData).randomName;
        }
        _lastRandomName = "";
        ui.tips.text = CLang.Get("player_team_change_name_tips");
        ui.ok_btn.disabled = ui.name_input_label.text.length == 0;
        this.addToPopupDialog();

        return true;
    }

    private function _onRandomName() : void {
        dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_RANDOM_NAME_CLICK));
    }

    private function _onOk() : void {
        dispatchEvent(new CViewEvent(CViewEvent.OK));
    }
    private function _onTextChange(e:Event) : void {
        var ui:ChangeNameUI = rootUI as ChangeNameUI;
        ui.ok_btn.disabled = ui.name_input_label.text.length == 0;

        var charLength:int = CLang.getStringCharLength(ui.name_input_label.text);
        if (charLength > ui.name_input_label.maxChars) {
            ui.name_input_label.text = _lastText;
            return ;
        }
        _lastText = ui.name_input_label.text;
    }
    private var _lastText:String;

    public var _lastSendName:String;
    public var _lastRandomName:String;

}
}

