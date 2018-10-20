//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.control {

import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.peak1v1.data.CPeak1v1ReportData;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;

public class CPeak1v1ReportControl extends CPeak1v1Controler {
    public function CPeak1v1ReportControl() {
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
            case EPeak1v1ViewEventType.REPORT_GM_REPORT_CLICK :
                var peakReportData:CPeak1v1ReportData = e.data as CPeak1v1ReportData;
                var gmReportData:CGMReportData = new CGMReportData();
                gmReportData.playerName = peakReportData.enemyName;
                gmReportData.fightUUID = peakReportData.fightUUID;
                gmReportData.instanceType = EInstanceType.TYPE_PEAK_1V1;
                (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, gmReportData));
                break;
        }
    }

}
}
