//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/26.
 */
package kof.game.playerTeam.control {

import QFLib.Utils.StringUtil;

import flash.events.Event;

import kof.game.common.CLang;

import kof.game.common.view.event.CViewEvent;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.game.playerTeam.view.CPlayerTeamCreateViewHandler;
import kof.ui.master.player_team.TeamSetUpUI;

public class CPlayerTeamCreateControl extends CPlayerTeamControlerBase {
    public function CPlayerTeamCreateControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.OK, _onOK);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.OK, _onOK);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
    }
    private function _onHide(e:CViewEvent) : void {
        // (_system as CPlayerSystem).showPlayerTeam(); // 会有问题
//        (_system as CAppSystemImp).isActived = true;
    }
    private function _onOK(e:CViewEvent) : void {
        var ui:TeamSetUpUI = _wnd.rootUI as TeamSetUpUI;
        var name:String = ui.team_name_input_label.text;
        name = StringUtil.trimAll(name);
        if (name == null || name == "") {
            uiCanvas.showMsgAlert(CLang.Get("player_team_change_name_empty"));
            return ;
        }
        if (name && name.length > 0 && (_wnd as CPlayerTeamCreateViewHandler)._lastSendName != name && name != playerData.teamData.getNoneServerName()) {
            (_wnd as CPlayerTeamCreateViewHandler)._lastSendName = name;
            netHandler.sendModifyPlayerName(name);
            _system.dispatchEvent( new Event( CPlayerTeamSystem.EVENT_PLAYER_TEAM_CREATION_COMPLETE ) );
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
