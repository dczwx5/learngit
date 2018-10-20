//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/1.
 */
package kof.game.teaching {

import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.control.CInstanceControler;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;

public class CTeachingAccountControl extends CInstanceControler {
    public function CTeachingAccountControl() {
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
        ((system.stage.getSystem(CLevelSystem) as CLevelSystem).getHandler(CLevelManager ) as CLevelManager).levelID = 10000;
        _wnd.uiCanvas.showSceneLoading();
        system.exitInstance();
    }
}
}
