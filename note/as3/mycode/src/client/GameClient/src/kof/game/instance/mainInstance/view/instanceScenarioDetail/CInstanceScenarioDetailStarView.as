//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.table.InstanceConstant;
import kof.table.InstanceContent;
import kof.ui.instance.InstanceNoteDetailUI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CInstanceScenarioDetailStarView extends CChildView {
    public function CInstanceScenarioDetailStarView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.cond_list.renderHandler = new Handler(_onRenderItem);

    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.cond_list.renderHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _ui.cond_list.dataSource = [CLang.Get("instance_elite_star_cond_1"), CLang.Get("instance_elite_star_cond_2"), CLang.Get("instance_elite_star_cond_3", {v1:data.curInstanceData.condStar3TimeLeft})];

        return true;
    }
    private function _onRenderItem(com:Component, idx:int) : void {
        var box:Box = com as Box;
        var condTxt:Label = box.getChildByName("cond_txt") as Label;
        condTxt.text = com.dataSource as String;

        var bgClip:Clip = box.getChildByName("bg_clip") as Clip;

    }
    private function get _ui() : InstanceNoteDetailUI {
        return rootUI as InstanceNoteDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
