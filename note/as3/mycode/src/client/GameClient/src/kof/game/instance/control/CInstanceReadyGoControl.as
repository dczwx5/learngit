//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.control {

import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.control.CInstanceControler;

public class CInstanceReadyGoControl extends CInstanceControler{
    public function CInstanceReadyGoControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onHide(e:CViewEvent) : void {
//        system.onLevelStarted();
    }
}
}
