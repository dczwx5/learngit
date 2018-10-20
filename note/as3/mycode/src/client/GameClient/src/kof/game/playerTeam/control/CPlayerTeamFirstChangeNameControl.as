//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/26.
 */
package kof.game.playerTeam.control {

import QFLib.Utils.StringUtil;

import kof.game.common.CLang;

import kof.game.player.data.CPlayerData;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.playerTeam.view.CPlayerTeamFirstChangeNameViewHandler;
import kof.ui.master.player_team.ChangeNameUI;

public class CPlayerTeamFirstChangeNameControl extends CPlayerTeamControlerBase {
    public function CPlayerTeamFirstChangeNameControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.OK, _onOK);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.OK, _onOK);
    }
    private function _onOK(e:CViewEvent) : void {
        var ui:ChangeNameUI = _wnd.rootUI as ChangeNameUI;
        var name:String = ui.name_input_label.text;
        var playerData:CPlayerData = system.playerData;
        name = StringUtil.trimAll(name);
        if (name == null || name == "") {
            uiCanvas.showMsgAlert(CLang.Get("player_team_change_name_empty"));
            return ;
        }
        if (name && name.length > 0 && (_wnd as CPlayerTeamFirstChangeNameViewHandler)._lastSendName != name && name != playerData.teamData.getNoneServerName()) {
            (_wnd as CPlayerTeamFirstChangeNameViewHandler)._lastSendName = name;
            netHandler.sendModifyPlayerName(name);
        } else {
            uiCanvas.showMsgAlert(CLang.Get("player_team_change_name_same_name"));
        }
    }
    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent as String;
        switch (uiEvent) {
            case EPlayerViewEventType.EVENT_RANDOM_NAME_CLICK:
                netHandler.sendRandomName();
                break;
        }

    }
}
}
