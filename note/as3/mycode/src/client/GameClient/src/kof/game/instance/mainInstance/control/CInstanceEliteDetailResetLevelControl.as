//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.control {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.InstanceConstant;

public class CInstanceEliteDetailResetLevelControl extends CInstanceControler{
    public function CInstanceEliteDetailResetLevelControl() {
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
            case EInstanceViewEventType.INSTANCE_CONFIRM_ADD_FIGHT_COUNT:
                var instanceData:CChapterInstanceData = e.data as CChapterInstanceData;
                var pInstanceConstant:InstanceConstant = instanceData.constant;
                var resetCount:int = instanceData.resetNum;
                var index:int = resetCount;
                var iCost:int = 0;
                if (index >= pInstanceConstant.ELITE_RESET_COST.length) {
                    iCost = pInstanceConstant.ELITE_RESET_COST[pInstanceConstant.ELITE_RESET_COST.length - 1];
                } else {
                    iCost = pInstanceConstant.ELITE_RESET_COST[index];
                }

                var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
                if (false == pReciprocalSystem.isEnoughToPay(iCost)) {

                    var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                    var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                    bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

                    pReciprocalSystem.showCanNotBuyTips();
                    return ;
                }

                pReciprocalSystem.showCostBdDiamondMsgBox(iCost, function () : void {
                    mainNetHandler.sendBuyInstanceCount(instanceData.instanceID);
                });
                break;
        }
    }
}
}
