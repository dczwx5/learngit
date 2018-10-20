//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.control {

import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.peakGame.data.CPeakGameReportItemData;
import kof.game.peakGame.enum.EPeakGameViewEventType;

public class CPeakGameReportControl extends CPeakGameControler {
    public function CPeakGameReportControl() {
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        switch (subType) {
            case EPeakGameViewEventType.REPORT_GM_REPORT_CLICK :
                var peakReportData:CPeakGameReportItemData = e.data as CPeakGameReportItemData;
                var gmReportData:CGMReportData = new CGMReportData();
                gmReportData.playerName = peakReportData.enemyData.name;
                gmReportData.fightUUID = peakReportData.fightUUID;
                gmReportData.instanceType = EInstanceType.TYPE_PEAK_GAME_FAIR;
                (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, gmReportData));
                break;
        }
    }
}
}
