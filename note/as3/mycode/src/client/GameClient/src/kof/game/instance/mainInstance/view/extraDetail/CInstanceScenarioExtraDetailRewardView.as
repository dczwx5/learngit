//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.view.extraDetail {

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceExtraDetailUI;

public class CInstanceScenarioExtraDetailRewardView extends CChildView {
    public function CInstanceScenarioExtraDetailRewardView() {
        super ([CRewardItemListView])

    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _ui.intro_title_txt.text = CLang.Get("common_play_intro");
        _ui.reward_title_txt.text = CLang.Get("common_pass_reward_title");
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _rewardListView.isShowCurrency = false;
        _rewardListView.isShowItemCount = false;
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
        if (data.curInstanceData.isCompleted) {
            _rewardListView.setData(data.curInstanceData.reward, forceInvalid);
        } else {
            _rewardListView.setData(data.curInstanceData.rewardFirst, forceInvalid);
        }

    }
    private function get _rewardListView() : CRewardItemListView { return getChild(0) as CRewardItemListView; }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _ui.reward_gold_txt.text = "";
        _ui.reward_exp_txt.text = "";

        var isPass:Boolean = data.curInstanceData.isCompleted;
        var rewardDataList:CRewardListData;
        if (isPass) {
            _ui.drop_title_txt.text = CLang.Get("common_drop_title");
            if (data.curInstanceData.reward > 0) {
                rewardDataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, data.curInstanceData.reward);
                if (rewardDataList) {
                    _ui.reward_gold_txt.text = rewardDataList.gold.toString();
                    _ui.reward_exp_txt.text = rewardDataList.playerExp.toString();
                }
            }
        } else {
            _ui.drop_title_txt.text = CLang.Get("instance_first_pass_reward");
            if (data.curInstanceData.rewardFirst > 0) {
                rewardDataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, data.curInstanceData.rewardFirst);
                if (rewardDataList) {
                    _ui.reward_gold_txt.text = rewardDataList.gold.toString();
                    _ui.reward_exp_txt.text = rewardDataList.playerExp.toString();
                }
            }
        }


        return true;
    }

    private function get _ui() : InstanceExtraDetailUI {
        return rootUI as InstanceExtraDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
