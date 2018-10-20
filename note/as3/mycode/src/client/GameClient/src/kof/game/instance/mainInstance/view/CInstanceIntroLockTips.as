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
import kof.ui.instance.InstanceLevelLockTipsUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CInstanceIntroLockTips extends CViewHandler implements ITips {

    public function CInstanceIntroLockTips() {
        super();

    }
    public function addTips(box:Component, params:Array = null) : void {
        if (_ui == null) {
            _ui = new InstanceLevelLockTipsUI();
            _ui.open_txt.text = CLang.Get("common_square_brackets", {v1:CLang.Get("common_not_open")});
        }
        var openLlist:Array = params[0];
        var power:String = params[1];
        var sInstanceName:String = params[2];

        m_tipsObj = box;

        if(m_tipsObj.dataSource){
//            _ui.star_list.visible = false;
            _ui.open_title_txt.text = CLang.Get("common_open_title");
            _ui.power_title_txt.text = CLang.Get("recommend_battle_value_title");
            _ui.power_txt.text = power;
            _ui.name_txt.text = sInstanceName;

            this._ui.width = 1;
            _ui.cond_list.renderHandler = new Handler(_onRenderConditionItem);
            _ui.cond_list.dataSource = openLlist;

            App.tip.addChild(_ui);
        }
    }

    private function _onRenderConditionItem(com:Component, idx:int) : void {
        var openTxt:Label = (com as Box).getChildByName("open_txt") as Label;
        if (_ui.cond_list.array && (idx < _ui.cond_list.array.length)) {
            com.visible = true;
            openTxt.text = com.dataSource as String;
        } else {
            com.visible = false;
        }

        var uiSize:int = openTxt.width + 60 + _ui.cond_list.x;
        if (uiSize > _ui.width) {
            this._ui.width = uiSize;
        }

    }

    public function hideTips():void{
        _ui.remove();
    }

    private var _ui:InstanceLevelLockTipsUI;
    private var m_tipsObj:Component;

}
}
