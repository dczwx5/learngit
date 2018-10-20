//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.control {

import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.enum.EPeakGameViewEventType;

public class CPeakGameMatchControl extends CPeakGameControler {
    public function CPeakGameMatchControl() {
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
                    CGameStatus.unSetStatus(CGameStatus.Status_PeakGameMatch);
                if (system.peakGameData.isMatching) {
                    netHandler.sendCancelMatch(system.playType);
                }
                break;
        }
    }
}
}
