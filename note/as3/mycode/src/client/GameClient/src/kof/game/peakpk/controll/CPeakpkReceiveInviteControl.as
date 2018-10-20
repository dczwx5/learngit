//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/28.
 */
package kof.game.peakpk.controll {

import kof.game.common.status.CGameStatus;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakpk.enum.EPeakpkViewEventType;

public class CPeakpkReceiveInviteControl extends CPeakpkControler {
    public function CPeakpkReceiveInviteControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        switch (subType) {
            case EPeakpkViewEventType.RECEIVE_INVITE_REFUSE :
                CGameStatus.unSetStatus(CGameStatus.Status_PeakPKMatch);
                netHandler.sendRefuseInvite(data.inviterData.id);
                break;
            case EPeakpkViewEventType.RECEIVE_INVITE_ACCESS :
                netHandler.sendAccessInvite(data.inviterData.id);
                break;
        }
    }
}
}
