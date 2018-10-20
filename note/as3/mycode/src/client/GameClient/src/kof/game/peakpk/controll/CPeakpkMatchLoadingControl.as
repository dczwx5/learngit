//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakpk.controll {

import kof.game.common.loading.*;


import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;

public class CPeakpkMatchLoadingControl extends CPeakpkControler {
    public function CPeakpkMatchLoadingControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CLoadingEvent.LOADING_PROCESS_UPDATE, _onUIEvent);
        _wnd.removeEventListener(CLoadingEvent.LOADING_PROCESS_FINISH, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CLoadingEvent.LOADING_PROCESS_UPDATE, _onUIEvent);
        _wnd.addEventListener(CLoadingEvent.LOADING_PROCESS_FINISH, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CLoadingEvent) : void {
        var type:String = e.type;
        var errorData:CErrorData = null;
        var win:CViewBase;
        switch (type) {
            case CLoadingEvent.LOADING_PROCESS_UPDATE :
                var process:int = e.data as int;
                system.netHandler.sendSyncLoading(process);
                break;
            case CLoadingEvent.LOADING_PROCESS_FINISH :
                var instanceID:int = (e.data as CMatchData).instanceID;
                (_system.stage.getSystem(CInstanceSystem) as CInstanceSystem).enterInstance(instanceID);
                (_system.stage.getSystem(CInstanceSystem) as CInstanceSystem).listenEvent(_onInstanceEvent);
                break;
        }
    }
    private function _onHide(e:CViewEvent) : void {

    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            (_system.stage.getSystem(CInstanceSystem) as CInstanceSystem).unListenEvent(_onInstanceEvent);
            _wnd.sendEvent(new CLoadingEvent(CLoadingEvent.LOADING_REQUIRE_TO_END)); // do something by listen this event
            _wnd.viewManagerHandler.hideAllSystem();
        }
    }


}
}
