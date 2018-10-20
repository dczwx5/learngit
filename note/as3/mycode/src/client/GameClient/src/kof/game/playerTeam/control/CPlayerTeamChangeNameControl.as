//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/26.
 */
package kof.game.playerTeam.control {

import QFLib.Utils.StringUtil;

import kof.game.common.CLang;
import kof.game.player.enum.EPlayerWndType;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.playerTeam.view.CPlayerTeamChangeNameConfirmViewHandler;
import kof.game.playerTeam.view.CPlayerTeamChangeNameViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.master.player_team.ChangeNameUI;

public class CPlayerTeamChangeNameControl extends CPlayerTeamControlerBase {
    public function CPlayerTeamChangeNameControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.OK, _onOk);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.OK, _onOk);
    }
    private function _onOk(e:CViewEvent) : void {
        var iCost:int = playerData.getChangeNameCost();
        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if (false == pReciprocalSystem.isEnoughToPay(iCost)) {
            pReciprocalSystem.showCanNotBuyTips();
            return ;
        }

        var ui:ChangeNameUI = _wnd.rootUI as ChangeNameUI;
        var name:String = ui.name_input_label.text;
        name = StringUtil.trimAll(name);
        if (name == null || name == "") {
            uiCanvas.showMsgAlert(CLang.Get("player_team_change_name_empty"));
            return ;
        }

        if (name && (_wnd as CPlayerTeamChangeNameViewHandler)._lastSendName != name &&
                name != playerData.teamData.getNoneServerName())
        {
            var showFunc:Function = function (view:CPlayerTeamChangeNameConfirmViewHandler) : void {
                if (view) {
                    var hideFunc:Function = function (e:CViewEvent) : void {
                        view.removeEventListener(CViewEvent.HIDE, hideFunc);
                        view.removeEventListener(CViewEvent.OK, okFunc);
                    };
                    var okFunc:Function = function (e:CViewEvent) : void {
                        (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox(iCost, function () : void {
                            view.removeEventListener(CViewEvent.HIDE, hideFunc);
                            view.removeEventListener(CViewEvent.OK, okFunc);
                            (_wnd as CPlayerTeamChangeNameViewHandler)._lastSendName = name;
                            netHandler.sendModifyPlayerName(name);
                        });

                    };
                    view.addEventListener(CViewEvent.HIDE, hideFunc);
                    view.addEventListener(CViewEvent.OK, okFunc);
                }
            };
            uiHandler.show(EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME_CONFIRM, null,
                    showFunc, playerData);
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
