//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;

public class CInstanceEliteDetailControl extends CInstanceControler{
    public function CInstanceEliteDetailControl() {
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
        var instanceData:CChapterInstanceData;
        var dataCollection:CInstanceDataCollection;
        var sweepTimes:int = 0;
        var fightCount:int = 0;

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
            case EInstanceViewEventType.INSTANCE_SWEEP_10:
            case EInstanceViewEventType.INSTANCE_SWEEP:
                dataCollection = e.data[0] as CInstanceDataCollection;
                instanceData = e.data[1] as CChapterInstanceData;
                fightCount = e.data[2] as int;
                var isNoTimes:Boolean = e.data[3] as Boolean;
                if (isNoTimes) {
                    uiCanvas.showMsgAlert(CLang.Get("instance_not_enough_count"));
                    break;
                }
                if (fightCount == 0) {
                    // 没次数上面已经处理了, 如果有挑战次数, 但是fightCount == 0, 说明体力不足
                    uiCanvas.showMsgAlert(CLang.Get("instance_error_vit_not_enough"));
                    break;
                }

                if (instanceData.star >= 3) {
                    errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, fightCount, true, false);
                    if (errorData.isError == false) {
                        (system as CInstanceSystem).instanceData.resetSweepData();

                        uiHandler.showSweepView(instanceData, fightCount);
                        mainNetHandler.sendSweepInstance(instanceData.instanceID, fightCount);
                    } else {
                        uiCanvas.showMsgAlert(errorData.errorString);

                    }
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("instance_sweep_need_3_star"));
                }
                break;
            case EInstanceViewEventType.INSTANCE_ADD_FIGHT_COUNT:
                dataCollection = e.data[0] as CInstanceDataCollection;

                uiHandler.showEliteResetLevelView(dataCollection.curInstanceData);
                break;
        }
    }
    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            _wnd.DelayCall(0.5, uiHandler.hideAllSystem);
            system.unListenEvent(_onInstanceEvent);
            if (system.isShowViewWhenReturnMainCity) {
                system.addExitProcess(CInstanceScenarioView, CInstanceExitProcess.FLAG_INSTANCE, system.setEliteActived, [true], 9999);//uiHandler.showEliteWindow, null, 9999);
            }
        }
    }
}
}
