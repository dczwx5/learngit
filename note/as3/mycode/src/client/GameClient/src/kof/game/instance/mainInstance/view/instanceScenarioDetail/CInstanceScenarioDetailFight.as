//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.table.InstanceConstant;
import kof.ui.instance.InstanceNoteDetailUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceScenarioDetailFight extends CChildView {
    public function CInstanceScenarioDetailFight() {
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
        _ui.sweep_btn.clickHandler = new Handler(_onSweep1);
        _ui.sweep10_btn.clickHandler = new Handler(_onSweep10);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.fight_btn.clickHandler = null;
        _ui.sweep_btn.clickHandler = null;
        _ui.sweep10_btn.clickHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var instanceConstant:InstanceConstant = data.instanceDataManager.instanceData.constant;

        const VIT_COST:int = instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        _ui.cost_vit_title_txt.text = CLang.Get("instance_vit_cost");
        var isVitEnought:Boolean = data.instanceDataManager.playerData.vitData.physicalStrength >= VIT_COST;
        if (isVitEnought) {
            _ui.cost_vit_txt.text = VIT_COST.toString();
        } else {
            _ui.cost_vit_txt.text = CLang.Get("common_color_content_red", {v1:VIT_COST.toString()});
        }

        _ui.fight_btn.btnLabel.text = CLang.Get("instance_fight");
        _ui.sweep_btn.btnLabel.text = CLang.Get("instance_sweep_1");

        var times:int = instanceConstant.INSTANCE_MAIN_SWEEP_NUM_MAX;
        if (data.instanceDataManager.playerData.vitData.physicalStrength < times * VIT_COST) {
            times = data.instanceDataManager.playerData.vitData.physicalStrength/VIT_COST;
        }
        _ui.sweep10_btn.btnLabel.text = CLang.Get("instance_sweep_10", {v1:times});

        return true;
    }

    private function _onFight() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_FIGHT, [data, data.curInstanceData, 1]));
    }
    private function _onSweep1() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_SWEEP, [data, data.curInstanceData, 1]));

    }
    private function _onSweep10() : void {
        var instanceConstant:InstanceConstant = data.instanceDataManager.instanceData.constant;
        var times : int = instanceConstant.INSTANCE_MAIN_SWEEP_NUM_MAX;
        if (data.instanceDataManager.playerData.vitData.physicalStrength < times * instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM) {
            times = data.instanceDataManager.playerData.vitData.physicalStrength / instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        }
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_SWEEP_10, [data, data.curInstanceData, times]));
    }

    private function get _ui() : InstanceNoteDetailUI {
        return rootUI as InstanceNoteDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
