//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.control {

import kof.game.common.view.event.CViewEvent;

public class CPeakGameNewSeasonControl extends CPeakGameControler {
    public function CPeakGameNewSeasonControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onHide(e:CViewEvent) : void {
        peakGameData.seasonComingFlag = false;
        if (peakGameData.lastRanking > 0) {
            uiHandler.showNewSeasonRankView();
        }
    }
}
}
