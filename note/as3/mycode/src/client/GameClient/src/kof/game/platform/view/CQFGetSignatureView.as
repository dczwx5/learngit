//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/2/6.
 */
package kof.game.platform.view {

import flash.display.DisplayObject;

import kof.framework.CAbstractHandler;
import kof.ui.imp_common.SignatureQFUI;

public class CQFGetSignatureView extends CAbstractHandler implements IPlatformGetSignatureView {
    public function CQFGetSignatureView() {

    }

    public function createView() : DisplayObject {
        return new SignatureQFUI();
    }

    public function get viewClass() : Array {
        return [SignatureQFUI];
    }
}
}
