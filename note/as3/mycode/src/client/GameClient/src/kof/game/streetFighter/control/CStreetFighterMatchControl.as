//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/29.
 */
package kof.game.streetFighter.control {

import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.enum.EPeakGameViewEventType;

public class CStreetFighterMatchControl extends CStreetFighterControler {
    public function CStreetFighterMatchControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        switch (subType) {
            case EPeakGameViewEventType.MATCHING_CLICK_CANCEL :
                if (streetFighterData.isMatching) {
                    CGameStatus.unSetStatus(CGameStatus.Status_StreetFighterMatch);
                    netHandler.sendCancelMatchRequest();
                    uiHandler.hideMatch();
                }
                break;
        }
    }
}
}
