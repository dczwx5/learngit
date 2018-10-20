//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28/.
 */
package view {
import kof.ui.master.BattleTutor.BTMultiKeyDescUI;

public class CMultiKeyDescViewHandler extends CBattleTutorViewHandlerBase {
    public function CMultiKeyDescViewHandler() {
        super(BTMultiKeyDescUI);
    }
    override public function get viewClass():Array {
        return [BTMultiKeyDescUI];
    }
    public function get ui():BTMultiKeyDescUI {
        return getUI() as BTMultiKeyDescUI;
    }
    protected override function get additionalAssets() : Array {
        return []; // 加载战斗引导的其他资源
    }
    override public function dispose():void {
        super.dispose();
    }
    protected override function _onAdded() : void {
        super._onAdded();
    }
}
}
