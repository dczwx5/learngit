//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/19.
 */
package kof.game.instance.mainInstance.view.instanceSweep {

import kof.game.common.CLang;
import kof.game.common.view.reward.CShowRewardViewUtil;
import kof.game.item.data.CRewardListData;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceSweepRewardListData;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.ui.IUICanvas;
import kof.ui.instance.InstanceSweepItemUI;
import kof.ui.instance.InstanceSweepUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CInstanceSweepView extends CRootView {
    public function CInstanceSweepView() {
        super(InstanceSweepUI, [], null, false)
    }

    protected override function _onCreate() : void {

    }

    protected override function _onDispose() : void {
    }

    protected override function _onShow() : void {

        _ui.ok_btn.btnLabel.text = CLang.Get("common_ok");
        _ui.ok_btn.clickHandler = new Handler(_onOk);
        _ui.sweep_more_btn.btnLabel.text = CLang.Get("sweep_more_time");
        _ui.sweep_more_btn.clickHandler = new Handler(_onSweepMore);

        _ui.msg_list.renderHandler = new Handler(_onItemRender);

    }

    protected override function _onHide() : void {
        _ui.msg_list.renderHandler = null;
        _ui.sweep_more_btn.clickHandler = null;
        _ui.ok_btn.clickHandler = null;
        _initialArgs = null;
    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;


        var list:Array = _rewardList.list;
        _ui.msg_list.dataSource = list;
        _ui.msg_list.repeatY = list.length;
        _ui.reward_panel.refresh();
        _ui.reward_panel.scrollTo(0);


        if (_instanceData.instanceType == EInstanceType.TYPE_MAIN && _fightCount == 1) {
            _ui.sweep_more_btn.visible = true;
            _ui.ok_btn.centerX = 80;
        } else {
            _ui.sweep_more_btn.visible = false;
            _ui.ok_btn.centerX = 0;
        }
        this.addToPopupDialog();
        return true;
    }

    private function _onItemRender(item:Component, idx:int) : void {
        var sweepItem:InstanceSweepItemUI = item as InstanceSweepItemUI;
        var data:CRewardListData = sweepItem.dataSource as CRewardListData;
        if (!data) {
            sweepItem.visible = false;
            return ;
        } else {
            sweepItem.visible = true;
        }

        sweepItem.times_txt.text = CLang.Get("sweep_times", {v1:CLang.Get("common_number_china_" + (1+idx))}); // data.getRewardString();
        sweepItem.exp_add_txt.text = data.playerExp.toString();
        sweepItem.hero_exp_add_txt.text = data.heroExp.toString();
        sweepItem.gold_add_txt.text = data.gold.toString();

        CShowRewardViewUtil.show(rootView, sweepItem, data, false);

    }


    private function _onSweepMore() : void {
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_SWEEP_MORE, [_instanceData.instanceID, _fightCount]));
    }
    private function _onOk() : void {
        this.close();
    }

    private function get _ui() : InstanceSweepUI {
        return rootUI as InstanceSweepUI;
    }

    private function get _rewardList() : CInstanceSweepRewardListData {
        return _data as CInstanceSweepRewardListData;
    }

    private function get _instanceData() : CChapterInstanceData {
        return _initialArgs[0];
    }
    private function get _fightCount() : int {
        return _initialArgs[1];
    }

}
}
