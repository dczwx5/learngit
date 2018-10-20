//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform.view {

import kof.framework.CAbstractHandler;
import kof.game.platform.data.CPlatformBaseData;
import kof.ui.imp_common.SignatureQFUI;

import morn.core.components.Box;

public class CQFSignatureRender extends CAbstractHandler implements IPlatformSignatureRender {
    public function CQFSignatureRender() {
    }

    public function get autoSortItem() : Boolean {
        return true;
    }

    public function renderSignature(signatureBox:Box, platformData:CPlatformBaseData, vipLevel:int) : void {
        var qfSignatureUI:SignatureQFUI;
        if (signatureBox.numChildren > 0) {
            qfSignatureUI = signatureBox.getChildAt(0) as SignatureQFUI;
            renderSignatureB(qfSignatureUI, platformData, vipLevel);
        }
    }
    public function renderSignatureB(signatureBox:SignatureQFUI, platformData:CPlatformBaseData, vipLevel:int) : void {
        if ( !signatureBox ) return;
        signatureBox.clipVip.visible = vipLevel > 0;
        if( signatureBox.clipVip.visible )
            signatureBox.clipVip.index = vipLevel;
    }
}
}
