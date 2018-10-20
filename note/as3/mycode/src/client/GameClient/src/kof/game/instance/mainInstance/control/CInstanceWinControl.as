//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.control.CControlBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.dataLog.CDataLog;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;


public class CInstanceWinControl extends CInstanceControler{
    public function CInstanceWinControl() {
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


    }
    private function _onHide(e:CViewEvent) : void {
        CDataLog.logInstanceResultClickGetReward(system, system.instanceData, system.instanceContent);

        system.exitInstance();
        ((system.stage.getSystem(CLevelSystem) as CLevelSystem).getHandler(CLevelManager ) as CLevelManager).levelID = 10000;
        _wnd.uiCanvas.showSceneLoading();
    }
}
}
