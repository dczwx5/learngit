//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/27.
 */
package kof.game.player.control {

import kof.game.player.control.CPlayerControler;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.event.EPlayerViewEventType;

public class CSkillUpControl extends CPlayerControler {
    public function CSkillUpControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent;
        switch (uiEvent) {
            case EPlayerViewEventType.EVENT_LIST_SELECT_HERO :
                uiHandler.refreshPlayerMainView(EPlayerWndTabType.STACK_ID_HERO_SKILL_UP);
                break;
        }
    }
}
}
