//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package view {

import kof.ui.master.BattleTutor.BTDefense2UI;

public class CDefend2IntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CDefend2IntroViewHandler() {
        super(BTDefense2UI);
    }
    override public function get viewClass():Array {
        return [BTDefense2UI];
    }
    public function get ui():BTDefense2UI {
        return getUI() as BTDefense2UI;
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
