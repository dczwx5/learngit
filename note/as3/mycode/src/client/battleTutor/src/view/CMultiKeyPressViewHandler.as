//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28.
 */
package view {

import kof.ui.master.BattleTutor.BTMultiKeyPressUI;

public class CMultiKeyPressViewHandler extends CBattleTutorViewHandlerBase {
    public function CMultiKeyPressViewHandler() {
        super(BTMultiKeyPressUI);
    }
    override public function get viewClass():Array {
        return [BTMultiKeyPressUI];
    }
    public function get ui():BTMultiKeyPressUI {
        return getUI() as BTMultiKeyPressUI;
    }

    override public function dispose():void {
        super.dispose();
    }
}
}
