//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceEliteDetailView {

import kof.game.common.view.CChildView;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceEliteDetailUI;

public class CInstanceEliteDetailIntroView extends CChildView {
    public function CInstanceEliteDetailIntroView() {
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

        _ui.instance_name_txt.text = instanceData.name;
        //_ui.instance_intro_txt.text = instanceData.desc;

        return true;
    }

    private function get _ui() : InstanceEliteDetailUI {
        return rootUI as InstanceEliteDetailUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
}
}
