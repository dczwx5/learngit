//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.control {

import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;

public class CPeak1v1NotifyControl extends CPeak1v1Controler {
    public function CPeak1v1NotifyControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
//        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
//        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
        switch (subType) {
            case EPeak1v1ViewEventType.NOTIFY_CLICK_OK :
                _wnd.close();
                system.setActived(true);
                break;
        }
    }

//    private function _onHide(e:CViewEvent) : void {
//
//    }
}
}
