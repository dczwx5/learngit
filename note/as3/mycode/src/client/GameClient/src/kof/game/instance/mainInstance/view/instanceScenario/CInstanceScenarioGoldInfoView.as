//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.player.data.CPlayerData;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.handlers.Handler;

public class CInstanceScenarioGoldInfoView extends CChildView {
    public function CInstanceScenarioGoldInfoView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        var ui:InstanceScenarioUI = rootUI as InstanceScenarioUI;
        ui.buy_vit_btn.clickHandler = new Handler(_onBuyVit);
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        var ui:InstanceScenarioUI = rootUI as InstanceScenarioUI;
        ui.buy_vit_btn.clickHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var ui:InstanceScenarioUI = rootUI as InstanceScenarioUI;
        ui.gold_txt.text = data.instanceDataManager.playerData.currency.gold.toString();
        ui.vit_txt.text = data.instanceDataManager.playerData.vitData.physicalStrength.toString();
        ui.blueDiamond_txt.text = data.instanceDataManager.playerData.currency.blueDiamond.toString();
        ui.purpleDiamond_txt.text = data.instanceDataManager.playerData.currency.purpleDiamond.toString();


        return true;
    }

    private function _onBuyVit() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_ADD_VIT))
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

}
}
