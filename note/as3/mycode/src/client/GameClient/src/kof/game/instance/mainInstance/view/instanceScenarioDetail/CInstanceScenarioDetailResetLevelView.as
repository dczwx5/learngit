//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {


import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.ui.instance.InstanceResetLevelUI;

import morn.core.handlers.Handler;


public class CInstanceScenarioDetailResetLevelView extends CRootView {

    public function CInstanceScenarioDetailResetLevelView() {
        super(InstanceResetLevelUI, null, null, false)
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.ok_btn.clickHandler = new Handler(_onOk);
    }
    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var resetCount:int = data.resetNum;
        _ui.txt1_lable.text = CLang.Get("instance_elite_reset_ask");
        _ui.txt2_lable.text = CLang.Get("instance_elite_reset_ask2", {v1:resetCount});

        var index:int = resetCount;
        var cost:int = 0;
        if (index >= data.constant.ELITE_RESET_COST.length) {
            cost = data.constant.ELITE_RESET_COST[data.constant.ELITE_RESET_COST.length - 1];
        } else {
            cost = data.constant.ELITE_RESET_COST[index];
        }
        _ui.cost_lable.text = cost.toString();

        this.addToPopupDialog();

        return true;
    }

    private function _onOk() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CONFIRM_ADD_FIGHT_COUNT, data));
        this.close();
    }
    private function get data() : CChapterInstanceData {
        return _data as CChapterInstanceData;
    }

    private function get _ui() : InstanceResetLevelUI {
        return rootUI as InstanceResetLevelUI;
    }
}
}
