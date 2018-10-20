//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/31.
 */
package kof.game.streetFighter.control {

import kof.game.common.view.event.CViewEvent;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;

public class CStreetFighterRefightControler extends CStreetFighterControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        switch (subType) {
            case EStreetFighterViewEventType.REFIGHT_OK :
                if (streetFighterData.alreadyStartFight) {
                    netHandler.sendRefight();
                }
                break;

        }
    }


}
}
