//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.controll {

import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.im.CIMHandler;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMFriendsData;
import kof.game.peakpk.enum.EPeakpkViewEventType;

public class CPeakpkMainControl extends CPeakpkControler {
    public function CPeakpkMainControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
        switch (subType) {
            case EPeakpkViewEventType.MAIN_CLICK_ITEM_PK_BTN :
                if (CGameStatus.checkStatus(system)) {
                    var imData:CIMFriendsData = e.data as CIMFriendsData;
                    // 发起切磋请求
                    data.lastSendInviteData = imData;
                    CGameStatus.setStatus(CGameStatus.Status_PeakPKMatch);
                    netHandler.sendInvite(imData.roleID);
                }
                break;
            case EPeakpkViewEventType.MAIN_CLICK_REFRESH_BTN :
                // 刷新
                var imsystem:CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
                if (imsystem) {
                    (imsystem.getHandler(CIMHandler) as CIMHandler).onFriendInfoListRequest();
                }
                break;
        }
    }

    private function _onHide(e:CViewEvent) : void {
        _wnd.viewManagerHandler.hideAll();
    }
}
}
