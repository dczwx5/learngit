//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.control {

import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.streetFighter.data.report.CStreetFighterReportItemData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;


public class CStreetFighterReportControler extends CStreetFighterControler {
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
//        var pSystemBundleCtx : ISystemBundleContext;
//        var pSystemBundle : ISystemBundle;
        switch (subType) {
            case EStreetFighterViewEventType.REPORT_GM_REPORT_CLICK :
                var reportData:CStreetFighterReportItemData = e.data as CStreetFighterReportItemData;
                var gmReportData:CGMReportData = new CGMReportData();
                gmReportData.playerName = reportData.enemyData.name;
                gmReportData.fightUUID = reportData.fightUUID;
                gmReportData.instanceType = EInstanceType.TYPE_STREET_FIGHTER;
                (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, gmReportData));
                break;

        }
    }

    private function _onHide(e:CViewEvent) : void {

    }

}
}
