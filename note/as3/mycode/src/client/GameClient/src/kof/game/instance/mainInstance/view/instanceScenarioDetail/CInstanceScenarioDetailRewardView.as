//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceNoteDetailUI;

public class CInstanceScenarioDetailRewardView extends CChildView {
    public function CInstanceScenarioDetailRewardView() {
        super ([CRewardItemListView])

    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _ui.cond_title_txt.text = CLang.Get("common_full_star_condtion");
        _ui.reward_title_txt.text = CLang.Get("common_pass_reward_title");
        _ui.drop_title_txt.text = CLang.Get("common_drop_title");
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
        _rewardListView.setData(data.curInstanceData.reward, forceInvalid);

    }
    private function get _rewardListView() : CRewardItemListView { return getChild(0) as CRewardItemListView; }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _ui.reward_gold_txt.text = "";
        _ui.reward_exp_txt.text = "";
        if (data.curInstanceData.reward > 0) {
            var rewardDataList:CRewardListData = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, data.curInstanceData.reward);
            if (rewardDataList) {
                var gold:Number = rewardDataList.gold;
                _ui.reward_gold_txt.text = gold.toString();

                var exp:int = rewardDataList.playerExp;
                _ui.reward_exp_txt.text = exp.toString();

                _ui.hero_reward_exp_txt.text = rewardDataList.heroExp.toString();

            }
        }

        return true;
    }

    private function get _ui() : InstanceNoteDetailUI {
        return rootUI as InstanceNoteDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
