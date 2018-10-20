//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.view.extraDetail {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceExtraDetailUI;

public class CInstanceScenarioExtraDetailIntroView extends CChildView {
    public function CInstanceScenarioExtraDetailIntroView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _ui.battle_value_title_txt.text = CLang.Get("recommend_battle_value_title");
//        _ui.power_txt.num = data.curInstanceData.powerRecommend;
        _ui.battle_value_txt.text = data.curInstanceData.powerRecommend.toString();
        _ui.intro_desc_txt.text = data.curInstanceData.desc;

//        _ui.detail_txt.text = data.curInstanceData.desc;

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
