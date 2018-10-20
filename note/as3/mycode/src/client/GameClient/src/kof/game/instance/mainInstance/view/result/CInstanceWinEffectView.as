//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result {

import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceWinEffectUI;
import kof.ui.instance.InstanceWinUI;


public class CInstanceWinEffectView extends CChildView {
    public function CInstanceWinEffectView() {
    }

    protected override function _onCreate() : void {


    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        this.setNoneData();
    }

    protected override function _onHide() : void {

    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;


        return true;
    }


    public function get _ui() : InstanceWinEffectUI {
        return (rootUI as InstanceWinUI).effect_view;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }
}
}
