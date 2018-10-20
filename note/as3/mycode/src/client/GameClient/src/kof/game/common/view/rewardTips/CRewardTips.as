//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/2.
 */
package kof.game.common.view.rewardTips {

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListViewV;
import kof.ui.imp_common.RewardTipsUI;

import morn.core.components.Component;
import morn.core.components.Label;

public class CRewardTips extends CViewHandler implements ITips {

    public function CRewardTips() {
        super(false);

    }
    public override function get viewClass() : Array {
        return [RewardTipsUI];
    }
    public function addTips(box:Component, args:Array = null) : void {
        _sourceItem = box;
        _data = args;
        this.loadAssetsByView(viewClass, _showDisplay);
    }
    protected function _showDisplay():void {
        if (onInitializeView()) {
            updateData();
            App.tip.addChild(_ui);
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg("Initialized \"" + viewClass + "\" failed by requesting display shown.");
        }
    }
    override protected function onInitializeView():Boolean {
        if (!super.onInitializeView())
            return false;

        if (!_isInitial) {
            _isInitial = true;
            _ui = new RewardTipsUI();

            _ui.reward_status0_img.text = CLang.Get("common_square_brackets", {v1:CLang.Get("common_not_pass")});
            _ui.reward_status1_img.text = CLang.Get("common_square_brackets", {v1:CLang.Get("common_can_reward")});
            _ui.reward_status2_img.text = CLang.Get("common_square_brackets", {v1:CLang.Get("common_had_reward")});
            _ui.reward_status3_img.text = CLang.Get("common_square_brackets", {v1:CLang.Get("common_not_finish")});
            _rewardRender = new CRewardItemListViewV(system, _ui.reward_list);
        }

        return _isInitial;
    }

    override protected virtual function updateData():void {
        super.updateData();

        var tipsTitle:String = _data[0];
        var tipsStatus:int = _data[1];

        if(_sourceItem.dataSource){
            _rewardRender.setData(_sourceItem.dataSource);
            _rewardRender.updateWindow();

            _ui.tips_txt.text = tipsTitle;

            for (var i:int = 0; i < 4; i++) {
                var img:Label = _ui["reward_status" + (i) + "_img"] as Label;
                img.visible = (i == tipsStatus);
            }

            _ui.bg_img.height = _ui.reward_list.y + _rewardRender.uiHeight;
        }
    }

    public function hideTips():void{
        _ui.remove();
    }

    public static const REWARD_STATUS_NOT_COMPLETED:int = 0;
    public static const REWARD_STATUS_CAN_REWARD:int = 1;
    public static const REWARD_STATUS_HAS_REWARD:int = 2;
    public static const REWARD_STATUS_OTHER_1:int = 3;

    private var _ui:RewardTipsUI;
    private var _sourceItem:Component;
    private var _isInitial:Boolean;
    private var _rewardRender:CRewardItemListViewV;
    private var _data:Array;


}
}
