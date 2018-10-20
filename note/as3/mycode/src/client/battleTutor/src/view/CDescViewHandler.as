//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import kof.ui.master.BattleTutor.BTDescUI;

public class CDescViewHandler extends CBattleTutorViewHandlerBase {
    public function CDescViewHandler() {
        super(BTDescUI);
    }
    override public function get viewClass():Array {
        return [BTDescUI];
    }
    public function get ui():BTDescUI {
        return getUI() as BTDescUI;
    }

    override public function dispose():void {
        super.dispose();
    }
}
}
