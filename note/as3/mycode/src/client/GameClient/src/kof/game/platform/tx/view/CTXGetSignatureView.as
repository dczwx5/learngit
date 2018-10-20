//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform.tx.view {

import flash.display.DisplayObject;

import kof.framework.CAbstractHandler;
import kof.game.platform.view.IPlatformGetSignatureView;
import kof.ui.platform.qq.QQSignatureUI;

public class CTXGetSignatureView extends CAbstractHandler implements IPlatformGetSignatureView {
    public function CTXGetSignatureView() {

    }

    public function createView() : DisplayObject {
        return new QQSignatureUI();
    }

    public function get viewClass() : Array {
        return [QQSignatureUI];
    }
}
}
