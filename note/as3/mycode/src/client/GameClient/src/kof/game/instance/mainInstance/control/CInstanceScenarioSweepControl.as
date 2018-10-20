//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;

public class CInstanceScenarioSweepControl extends CInstanceControler{
    public function CInstanceScenarioSweepControl() {
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
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_SWEEP_MORE:
                (system as CInstanceSystem).instanceData.resetSweepData();

                var instanceID:int = e.data[0];
                var fightCount:int = e.data[1] as int;
                mainNetHandler.sendSweepInstance(instanceID, fightCount);

                break;
        }

    }
}
}
