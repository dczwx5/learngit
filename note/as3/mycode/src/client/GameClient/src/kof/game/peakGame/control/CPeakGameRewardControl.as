//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/22.
 */
package kof.game.peakGame.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.enum.EPeakGameViewEventType;

public class CPeakGameRewardControl extends CPeakGameControler {
    public function CPeakGameRewardControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        switch (subType) {
            case EPeakGameViewEventType.REWARD_WEEK_WIN_COUNT_CLICK_REWARD :
                netHandler.sendGetReward(e.data as int, system.playType);
                break;
            case EPeakGameViewEventType.REWARD_DAILY_CLICK_REWARD :
                netHandler.sendGetReward(e.data as int, system.playType);
        }
    }
}
}
