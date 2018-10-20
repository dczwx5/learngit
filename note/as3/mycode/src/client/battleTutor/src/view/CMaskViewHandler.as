//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/6.
 */
package view {

import kof.ui.master.BattleTutor.BTMaskUI;

public class CMaskViewHandler extends CBattleTutorViewHandlerBase {
    public function CMaskViewHandler() {
        super(BTMaskUI);
    }
    override public function get viewClass():Array {
        return [BTMaskUI];
    }
    public function get ui():BTMaskUI {
        return getUI() as BTMaskUI;
    }

    override public function dispose():void {
        super.dispose();
    }
}
}
