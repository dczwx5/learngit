//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/2.
 */
package kof.game.instance.mainInstance.view {


import kof.framework.CViewHandler;

import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListViewV;
import kof.ui.instance.InstanceLevelTipsUI;

import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CInstanceIntroTips extends CViewHandler implements ITips {

    public function CInstanceIntroTips() {
        super();

    }

    public function addTips(box:Component, args:Array = null) : void {
        if (!_isInitial) {
            _isInitial = true;
            _ui = new InstanceLevelTipsUI();

            _rewardRender = new CRewardItemListViewV(system, _ui.reward_list);
            _rewardRender.isShowCurrency = false;
            _rewardRender.isShowItemCount = false;
            _starDataList = new Array(3);
            _ui.star_list.renderHandler = new Handler(_onRenderItem);
        }

        var starCount:int = args[0];
        var power:String = args[1];
        var rewardListData:CRewardListData = args[2];
        var instanceName:String = args[3] as String;
        var isShowStar:Boolean = args[4] as Boolean;
        var isPass:Boolean = false;
        if (args.length > 5) {
            isPass = args[5] as Boolean;
        }

        if (!isPass) {
            _ui.reward_title_txt.text = CLang.Get("instance_first_pass_reward");
            _rewardRender.isShowCurrency = true;
        } else {
            _rewardRender.isShowCurrency = false;
            _ui.reward_title_txt.text = CLang.Get("common_drop_title");
        }

        _rewardRender.setData(rewardListData);
        _rewardRender.updateWindow();

        _ui.power_title_txt.text = CLang.Get("recommend_battle_value_title");
        _ui.power_txt.text = power;

        for (var i:int = 0; i < _starDataList.length; i++) {
            if (starCount > i) {
                _starDataList[i] = true;
            } else {
                _starDataList[i] = false;
            }
        }
        _ui.star_list.visible = isShowStar;
        _ui.star_list.dataSource = _starDataList;
        _ui.instanceName.text = instanceName;
        _ui.img1_line.y = _ui.reward_list.y + _rewardRender.uiHeight + 18;
        _ui.power_box.y = _ui.img1_line.y + _ui.img1_line.height;
        _ui.bg_img.height = _ui.power_box.y + _ui.power_box.height + 3;
        App.tip.addChild(_ui);
    }

    public function hideTips():void{
        _ui.remove();
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        var starClip:Clip = com.getChildByName("star") as Clip;
        var data:Boolean = com.dataSource as Boolean;
        if (data) {
            starClip.index = 0;
        } else {
            starClip.index = 1;
        }
    }

    private var _ui:InstanceLevelTipsUI;
    private var _isInitial:Boolean;
    private var _starDataList:Array;

    private var _rewardRender:CRewardItemListViewV;

}
}
