//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import kof.ui.master.BattleTutor.BTKeyDescUI;

public class CKeyDescViewHandler extends CBattleTutorViewHandlerBase {
    public function CKeyDescViewHandler() {
        super(BTKeyDescUI);
    }
    override public function get viewClass():Array {
        return [BTKeyDescUI];
    }
    public function get ui():BTKeyDescUI {
        return getUI() as BTKeyDescUI;
    }

    override public function dispose():void {
        super.dispose();
    }
}
}
