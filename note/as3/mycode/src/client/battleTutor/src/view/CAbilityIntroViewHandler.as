//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import kof.ui.master.BattleTutor.BTAbilityUI;

public class CAbilityIntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CAbilityIntroViewHandler() {
        super(BTAbilityUI);
    }
    override public function get viewClass():Array {
        return [BTAbilityUI];
    }
    public function get ui():BTAbilityUI {
        return getUI() as BTAbilityUI;
    }

    protected override function _onAdded() : void {
        ui.img1.visible = ui.img2.visible = ui.img3.visible = false;
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
