//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceEliteDetailView {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.ui.instance.InstanceEliteDetailUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceEliteDetailFightView extends CChildView {
    public function CInstanceEliteDetailFightView() {
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
        _ui.add_btn.clickHandler = new Handler(_onAddFightCount);
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.fight_btn.clickHandler = null;
        _ui.sweep_btn.clickHandler = null;
        _ui.sweep10_btn.clickHandler = null;
        _ui.add_btn.clickHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        const VIT_COST:int = instanceData.constant.INSTANCE_ELITE_PASS_COST_VT_NUM;
        _ui.recommon_box.visible = instanceData.isCompleted == false;
        _ui.battle_value_txt.text = instanceData.powerRecommend.toString();

        _ui.cost_vit_title_txt.text = CLang.Get("instance_vit_cost");
        var isVitEnought:Boolean = data.instanceDataManager.playerData.vitData.physicalStrength >= VIT_COST;
        if (isVitEnought) {
            _ui.cost_vit_txt.text = VIT_COST.toString();
        } else {
            _ui.cost_vit_txt.text = CLang.Get("common_color_content_red", {v1:VIT_COST.toString()});
        }


        _ui.times_left_title_txt.text = CLang.Get("instance_left_time");
        var fightCount:int = 0;
        if (instanceData.isServerData) {
            fightCount = instanceData.challengeCountLeft;
        } else {
            fightCount = instanceData.constant.INSTANCE_ELITE_CHALLENGE_NUM;
        }
        _ui.times_left_txt.text = (fightCount + "/" + instanceData.constant.INSTANCE_ELITE_CHALLENGE_NUM).toString();

        _ui.fight_btn.btnLabel.text = CLang.Get("instance_fight");
        _ui.sweep_btn.btnLabel.text = CLang.Get("instance_sweep_1");

        var times:int = instanceData.constant.INSTANCE_ELITE_CHALLENGE_NUM;
        if (data.instanceDataManager.playerData.vitData.physicalStrength < times * instanceData.constant.INSTANCE_ELITE_PASS_COST_VT_NUM) {
            times = data.instanceDataManager.playerData.vitData.physicalStrength/instanceData.constant.INSTANCE_ELITE_PASS_COST_VT_NUM;
        }
        _ui.sweep10_btn.btnLabel.text = CLang.Get("instance_sweep_10", {v1:times});

        return true;
    }

    private function _onFight() : void {rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_FIGHT, [data, instanceData, 1]));
    }
    private function _onSweep1() : void {
        var times : int = 1;
        if (times > instanceData.challengeCountLeft) {
            times = instanceData.challengeCountLeft;
        }
        var isNoTimes:Boolean = instanceData.challengeCountLeft == 0;
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_SWEEP, [data, instanceData, times, isNoTimes]));
    }
    private function _onSweep10() : void {
        var times : int = instanceData.constant.INSTANCE_ELITE_SWEEP_NUM_MAX;
        if (data.instanceDataManager.playerData.vitData.physicalStrength < times * instanceData.constant.INSTANCE_ELITE_PASS_COST_VT_NUM) {
            times = data.instanceDataManager.playerData.vitData.physicalStrength / instanceData.constant.INSTANCE_ELITE_PASS_COST_VT_NUM;
        }
        if (times > instanceData.challengeCountLeft) {
            times = instanceData.challengeCountLeft;
        }
        var isNoTimes:Boolean = instanceData.challengeCountLeft == 0;
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_SWEEP_10, [data, instanceData, times, isNoTimes]));

    }
    private function _onAddFightCount() : void {
        if (instanceData == null) return ;
        if (instanceData.isServerData) {
            if (instanceData.challengeCountLeft > 0) {
                // 还有次数
                (uiCanvas.showMsgAlert(CLang.Get("instance_need_not_buy_elite_count")));
                return ;
            }
            var resetCountLeft:int = data.instanceDataManager.playerData.vipHelper.resetEliteTotalCount - instanceData.resetNum;
            if (resetCountLeft <= 0) {
                // 没重置次数了
                (uiCanvas.showMsgAlert(CLang.Get("instance_buy_elite_count_limit")));
                return ;
            }
            rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_ADD_FIGHT_COUNT, [data]));
        } else {
            (uiCanvas.showMsgAlert(CLang.Get("instance_elite_alawys_need_not_buy")));
        }

    }

    private function get _ui() : InstanceEliteDetailUI {
        return rootUI as InstanceEliteDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
}
}
