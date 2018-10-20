//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {

import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceNoteDetailUI;

public class CInstanceScenarioDetailIntroView extends CChildView {
    public function CInstanceScenarioDetailIntroView() {
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

//        _ui.power_txt.num = data.curInstanceData.powerRecommend;
        _ui.battle_value_txt.text = data.curInstanceData.powerRecommend.toString();
        _ui.recommon_box.visible = data.curInstanceData.isCompleted == false;

//        _ui.detail_txt.text = data.curInstanceData.desc;

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
