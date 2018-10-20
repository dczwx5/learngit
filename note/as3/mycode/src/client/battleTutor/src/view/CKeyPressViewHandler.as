//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import kof.ui.master.BattleTutor.BTPromptUI;

public class CKeyPressViewHandler extends CBattleTutorViewHandlerBase {
    public function CKeyPressViewHandler() {
        super(BTPromptUI);
    }
    override public function get viewClass():Array {
        return [BTPromptUI];
    }
    public function get ui():BTPromptUI {
        return getUI() as BTPromptUI;
    }

    override public function dispose():void {
        super.dispose();
    }
}
}
