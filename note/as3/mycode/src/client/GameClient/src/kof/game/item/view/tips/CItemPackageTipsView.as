//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/21.
 */
package kof.game.item.view.tips {

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.ui.imp_common.RewardPackageItemUI;
import kof.ui.imp_common.RewardPackageTipsUI;

import morn.core.components.Component;
import morn.core.components.Component;
import morn.core.handlers.Handler;

// 纵向奖励tips
public class CItemPackageTipsView extends CViewHandler  implements ITips {

    private var _ui:RewardPackageTipsUI;
    private var m_tipsObj:Component;

    public function CItemPackageTipsView() {
        super();

    }
    public function addTips(box:Component, args:Array = null):void{
        if(!_ui)
            _ui = new RewardPackageTipsUI();
        m_tipsObj = box;

        if(m_tipsObj.dataSource){
            _ui.item_list.renderHandler = new Handler(_onRenderItem);
            var rewardListData:CRewardListData = m_tipsObj.dataSource as CRewardListData;
            var itemList:Array = rewardListData.itemList;
            _ui.item_list.repeatY = itemList.length;
            _ui.item_list.dataSource = itemList;
            _ui.item_list.dataSource = "";
            App.tip.addChild(_ui);
        }
    }
    private function _onRenderItem(box:Component, idx:int) : void {
        var itemUI:RewardPackageItemUI = box as RewardPackageItemUI;
        if (box.dataSource == null) return ;
        var rewardData:CRewardData = (box.dataSource as CRewardData);

        itemUI.mc_item.img.url = rewardData.iconBig;
        itemUI.txt_name.text = CLang.Get("item_name_and_num", {v1:rewardData.nameWithColor, v2:rewardData.num});
    }


    public function hideTips():void{
        _ui.remove();
    }
}
}
