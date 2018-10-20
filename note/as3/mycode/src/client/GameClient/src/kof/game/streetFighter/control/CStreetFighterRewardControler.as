//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.table.StreetFighterReward;

public class CStreetFighterRewardControler extends CStreetFighterControler {
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
        switch (subType) {
            case EStreetFighterViewEventType.REWARD_GET_REWARD :
                var record:StreetFighterReward = e.data as StreetFighterReward;
                if (canGetReward(record)) {
                    netHandler.sendGetRewardRequest( record.ID );
                }
                break;

        }
    }

    private function _onHide(e:CViewEvent) : void {

    }

}
}
