//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/30.
 */
package view {

import kof.ui.master.BattleTutor.BTAutomaticFightUI;

public class CAutoFightIntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CAutoFightIntroViewHandler() {
        super(BTAutomaticFightUI);
    }
    override public function get viewClass():Array {
        return [BTAutomaticFightUI];
    }
    public function get ui():BTAutomaticFightUI {
        return getUI() as BTAutomaticFightUI;
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
