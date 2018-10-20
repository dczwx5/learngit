//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;

public class CInstanceScenarioExtraDetailControl extends CInstanceControler {
    public function CInstanceScenarioExtraDetailControl() {
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
        var fightCount:int = 0;
        var instanceData:CChapterInstanceData;
        var dataCollection:CInstanceDataCollection;
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_FIGHT:
                if (CGameStatus.checkStatus(system)) {
                    dataCollection = e.data[0] as CInstanceDataCollection;
                    instanceData = e.data[1] as CChapterInstanceData;
                    fightCount = e.data[2] as int;
                    errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, fightCount, false, false);
                    if (errorData.isError == false) {
                        system.listenEvent(_onInstanceEvent);
                        system.enterInstance(instanceData.instanceID);
                    } else {
                        uiCanvas.showMsgAlert(errorData.errorString);

                    }
                }
                break;
        }
    }
    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            _wnd.DelayCall(0.5, uiHandler.hideAllSystem);
            system.unListenEvent(_onInstanceEvent);
            if (system.isShowViewWhenReturnMainCity) {
                system.addExitProcess(CInstanceScenarioView, CInstanceExitProcess.FLAG_INSTANCE, system.setActived, [true], 9999);
            }
        }
    }
}
}
