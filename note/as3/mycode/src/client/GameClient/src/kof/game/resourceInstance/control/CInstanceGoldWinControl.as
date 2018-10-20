//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/2.
 */
package kof.game.resourceInstance.control {

import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.control.CInstanceControler;

public class CInstanceGoldWinControl extends CInstanceControler {
    public function CInstanceGoldWinControl() {
        super();
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {

    }
    private function _onHide(e:CViewEvent) : void {
         system.exitInstance();
    }
}
}
