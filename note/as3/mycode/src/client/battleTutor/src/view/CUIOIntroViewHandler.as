//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import kof.ui.master.BattleTutor.BTAdvertisementUI;

public class CUIOIntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CUIOIntroViewHandler() {
        super(BTAdvertisementUI);

        forceStopCountDown = true;
    }
    override public function get viewClass():Array {
        return [BTAdvertisementUI];
    }
    public function get ui():BTAdvertisementUI {
        return getUI() as BTAdvertisementUI;
    }

    protected override function _onAdded() : void {
        ui.img1.visible = false;
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
