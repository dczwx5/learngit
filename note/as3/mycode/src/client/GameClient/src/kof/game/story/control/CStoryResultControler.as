//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/17.
 */
package kof.game.story.control {

import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.story.enum.EStoryViewEventType;

public class CStoryResultControler extends CStoryControler {
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
        var win:CViewBase;
        switch (subType) {
            case EStoryViewEventType.RESULT_EXIT_CLICK :
                var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                pInstanceSystem.exitInstance();
                ((pInstanceSystem.stage.getSystem(CLevelSystem) as CLevelSystem).getHandler(CLevelManager ) as CLevelManager).levelID = 10000;
                _wnd.uiCanvas.showSceneLoading();
                break;
        }
    }

    private function _onHide(e:CViewEvent) : void {

    }
}
}
