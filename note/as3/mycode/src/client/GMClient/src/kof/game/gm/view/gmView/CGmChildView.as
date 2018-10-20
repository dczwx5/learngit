//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmView {

import kof.game.common.view.CChildView;
import kof.ui.gm.GMViewUI;
import morn.core.components.Component;

public class CGmChildView extends CChildView {
    public function CGmChildView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();

    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        return true;
    }

    public function get enable() : Boolean { return _enable; }
    public function set enable(v:Boolean) : void { _enable = v; }
    public virtual function get panel() : Component { return null; }

    protected function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }

    private var _enable:Boolean;
}
}
