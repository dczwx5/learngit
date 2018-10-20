//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package view {

import kof.ui.master.BattleTutor.BTQEUI;

public class CQEIntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CQEIntroViewHandler() {
        super(BTQEUI);
    }
    override public function get viewClass():Array {
        return [BTQEUI];
    }
    public function get ui():BTQEUI {
        return getUI() as BTQEUI;
    }

    protected override function _onAdded() : void {
        ui.img1.visible = ui.img2.visible = false;
    }
    override protected function onInitializeView():Boolean {
        var ret:Boolean = super.onInitializeView();
        if (!ret) return ret;

        isShowMask = true;
        return true;

    }
    override public function dispose():void {
        super.dispose();
    }
}
}
