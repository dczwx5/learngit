//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.view.extraDetail {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.table.InstanceConstant;
import kof.ui.instance.InstanceExtraDetailUI;

import morn.core.handlers.Handler;

public class CInstanceScenarioExtraDetailFight extends CChildView {
    public function CInstanceScenarioExtraDetailFight() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.fight_btn.clickHandler = new Handler(_onFight);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.fight_btn.clickHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var instanceConstant:InstanceConstant = data.instanceDataManager.instanceData.constant;

        _ui.cost_vit_title_txt.text = CLang.Get("instance_vit_cost");
        _ui.cost_vit_txt.text = instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM.toString();

        _ui.fight_btn.btnLabel.text = CLang.Get("instance_fight");

        return true;
    }

    private function _onFight() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_FIGHT, [data, data.curInstanceData, 1]));
    }

    private function get _ui() : InstanceExtraDetailUI {
        return rootUI as InstanceExtraDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
