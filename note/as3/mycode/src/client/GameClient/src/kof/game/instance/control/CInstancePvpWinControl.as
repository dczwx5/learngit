//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/8.
 */
package kof.game.instance.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.control.CControlBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.control.CInstanceControler;


public class CInstancePvpWinControl extends CInstanceControler{
    public function CInstancePvpWinControl() {
    }
    public override function dispose() : void {
        // _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        // _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {

    }
    private function _onHide(e:CViewEvent) : void {
        // system.exitInstance();
    }
}
}
