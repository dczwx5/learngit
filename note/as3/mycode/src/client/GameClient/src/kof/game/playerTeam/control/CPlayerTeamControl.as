//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/26.
 */
package kof.game.playerTeam.control {

import kof.game.player.enum.EPlayerWndResType;
import kof.game.player.enum.EPlayerWndType;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.playerTeam.view.team_new.CTeamNewViewHandler;
import kof.ui.master.player_team.PlayerTeamUI;

public class CPlayerTeamControl extends CPlayerTeamControlerBase {
    public function CPlayerTeamControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent as String;
        switch (uiEvent) {
            case EPlayerViewEventType.EVENT_CHANGE_ICON_CLICK:
                uiHandler.show(EPlayerWndType.WND_PLAYER_TEAM_CHANGE_IMAGE, [EPlayerWndResType.TYPE_CHANGE_ICON], null, playerData);
                break;
            case EPlayerViewEventType.EVENT_CHANGE_NAME_CLICK:
                if (playerData.teamData.firstModifyName == 0) {
                    // first
                    uiHandler.show(EPlayerWndType.WND_PLAYER_TEAM_FIRST_CHANGE_NAME, null, null, playerData);
                } else {
                    uiHandler.show(EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME, null, null, playerData);
                }
                break;
            case EPlayerViewEventType.EVENT_CHANGE_ROLE_MODEL_CLICK :
//                    netHandler.sendChangeTeamModel();
                uiHandler.show(EPlayerWndType.WND_PLAYER_TEAM_CHANGE_IMAGE, [EPlayerWndResType.TYPE_CHANGE_MODEL], null, playerData);
                break;
        }

    }
    private function _onHide(e:CViewEvent) : void {
        if ((_wnd as CTeamNewViewHandler).baseView.isSelf == false) {
            return ;
        }

        var ui:PlayerTeamUI = _wnd.rootUI as PlayerTeamUI;
        var sign:String = ui.base_view.sign_input_label.text;
        if ((_wnd as CTeamNewViewHandler).baseView.isDefaultSign == false && sign.length > 0 && sign != playerData.teamData.sign) {
            netHandler.sendModifySighRequest(sign);
        }
    }

}
}
