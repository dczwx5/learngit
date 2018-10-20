//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/24.
 */
package kof.game.playerTeam.view {

import kof.game.common.CLang;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.CRootView;
import kof.ui.CUISystem;
import kof.ui.master.messageprompt.MPReconfirmUI;

import morn.core.handlers.Handler;


public class CPlayerTeamChangeNameConfirmViewHandler extends CRootView {

    public function CPlayerTeamChangeNameConfirmViewHandler() {
        super(MPReconfirmUI, null, null, false);
    }

    protected override function _onShow():void {
        // do thing when show
        super._onShow();

        var ui:MPReconfirmUI = rootUI as MPReconfirmUI;
        ui.btn_ok.clickHandler = new Handler(_onOk);
    }

    protected override function _onHide() : void {
        var ui:MPReconfirmUI = rootUI as MPReconfirmUI;
        ui.btn_ok.clickHandler = null;
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var ui:MPReconfirmUI = rootUI as MPReconfirmUI;
        var playerData:CPlayerData = _data as CPlayerData;
        ui.txt1_lable.text = CLang.Get("player_team_cost_ask");
        ui.txt_cont.text = CLang.Get("player_team_cost_confirm", {v1:playerData.getChangeNameCost()});

        this.addToPopupDialog();

        return true;
    }


    private function _onOk() : void {
        this.dispatchEvent(new CViewEvent(CViewEvent.OK));
        this.close();
    }

}
}

