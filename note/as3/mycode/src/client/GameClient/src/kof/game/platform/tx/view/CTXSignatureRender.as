//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform.tx.view {

import kof.framework.CAbstractHandler;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.tx.data.CTXData;
import kof.game.platform.tx.enum.ETXIdentityType;
import kof.game.platform.view.IPlatformSignatureRender;
import kof.ui.platform.qq.QQSignatureUI;

import morn.core.components.Box;

public class CTXSignatureRender extends CAbstractHandler implements IPlatformSignatureRender {
    public function CTXSignatureRender() {
    }

    public function get autoSortItem() : Boolean {
        return true;
    }

    public function renderSignature(signatureBox:Box, platformData:CPlatformBaseData, vipLevel:int) : void {
        var qqSignature:QQSignatureUI;
        if (signatureBox.numChildren > 0) {
            qqSignature = signatureBox.getChildAt(0) as QQSignatureUI;
            renderSignatureB(qqSignature, platformData, vipLevel);
        }

    }
    public function renderSignatureB(qqSignature:QQSignatureUI, platformData:CPlatformBaseData, vipLevel:int) : void {
        if ( !qqSignature ) return;

        var txData:CTXData = platformData as CTXData;
        if (txData.isQGame) {
            renderSignatureQGame(qqSignature, txData);
        } else if (txData.isQZone) {
            renderSignatureQZone(qqSignature, txData);
        }
        qqSignature.clipVip.visible = vipLevel > 0;
        if( qqSignature.clipVip.visible )
            qqSignature.clipVip.index = vipLevel;
    }
    public function renderSignatureQGame(qqSignature:QQSignatureUI, txData:CTXData) : void {
        if (!qqSignature) return ;

        var iTypeID : int = txData.getQQIdentity();
        switch ( iTypeID ) {
            case ETXIdentityType.SUPER_BLUE_YEAR:
                qqSignature.clipBlueSuper.visible = true;
                qqSignature.clipBlueYear.visible = true;
                qqSignature.clipBlueSuper.index = txData.getQQLevel() - 1;
                break;
            case ETXIdentityType.SUPER_BLUE:
                qqSignature.clipBlueSuper.visible = true;
                qqSignature.clipBlueSuper.index = txData.getQQLevel() - 1;
                break;
            case ETXIdentityType.BLUE_YEAR:
                qqSignature.clipBlue.visible = true;
                qqSignature.clipBlueYear.visible = true;
                qqSignature.clipBlue.index = txData.getQQLevel() - 1;
                break;
            case ETXIdentityType.BLUE:
                qqSignature.clipBlue.visible = true;
                qqSignature.clipBlue.index = txData.getQQLevel() - 1;
                break;
            default:
                break;
        }
    }
    public function renderSignatureQZone(qqSignature:QQSignatureUI, txData:CTXData) : void {
        if (!qqSignature) return ;

        var iTypeID : int = txData.getQQIdentity();
        switch ( iTypeID ) {
            case ETXIdentityType.YELLOW_YEAR:
                qqSignature.clipYellowYear.visible = true;
                qqSignature.clipYellowYear.index = txData.getQQLevel() - 1;
                break;
            case ETXIdentityType.YELLOW:
                qqSignature.clipYellow.visible = true;
                qqSignature.clipYellow.index = txData.getQQLevel() - 1;
                break;
            default:
                break;
        }
    }
}
}
