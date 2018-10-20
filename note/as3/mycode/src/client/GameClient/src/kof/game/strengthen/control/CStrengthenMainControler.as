//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.control {

import kof.game.common.view.event.CViewEvent;
import kof.game.strengthen.enum.EStrengthenViewEventType;
import kof.game.switching.CSwitchingJump;
import kof.table.StrengthItem;

public class CStrengthenMainControler extends CStrengthenControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
     }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var strengthenItemData:StrengthItem = e.data as StrengthItem;
        switch (subType) {
            case EStrengthenViewEventType.MAIN_GREW_UP_CLICK :
            case EStrengthenViewEventType.MAIN_GOTO_CLICK :
                var sysTag:String = strengthenItemData.jumpSysTag;
                CSwitchingJump.jump(system, sysTag, strengthenItemData.shopType);
                break;
        }
    }
}
}
