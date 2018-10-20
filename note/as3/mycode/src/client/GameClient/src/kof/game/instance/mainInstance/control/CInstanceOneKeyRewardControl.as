//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/3.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.CLang;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;

public class CInstanceOneKeyRewardControl extends CInstanceControler{
    public function CInstanceOneKeyRewardControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var dataCollection:CInstanceDataCollection;
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_ONE_KEY_REWARD_OK_CLICK :
                var isScenarioNotify:Boolean = system.instanceData.chapterList.isScenarioHasReward();
                if (isScenarioNotify) {
                    dataCollection = e.data as CInstanceDataCollection;
                    mainNetHandler.sendGetOneKeyReward(dataCollection.instanceType);
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("instance_no_reward"));
                }
                break;
        }

    }

//    private function _onHide(e:CViewEvent) : void {
//        var dataManager:CInstanceDataManager = system.instanceManager.dataManager;
//        var rewardData:CRewardListData = dataManager.instanceData.lastOneKeyReward.getRewardListFull();
//        if (!rewardData) return ;
//
//        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardData);
//    }
}
}
