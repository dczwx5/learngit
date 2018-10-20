//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package view {

import kof.ui.master.BattleTutor.BTDefense1UI;

public class CDefend1IntroViewHandler extends CBattleTutorViewHandlerBase {
    public function CDefend1IntroViewHandler() {
        super(BTDefense1UI);
    }
    override public function get viewClass():Array {
        return [BTDefense1UI];
    }
    public function get ui():BTDefense1UI {
        return getUI() as BTDefense1UI;
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
