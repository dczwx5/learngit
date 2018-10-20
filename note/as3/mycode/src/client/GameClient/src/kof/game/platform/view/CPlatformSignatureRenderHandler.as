//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/28.
 */
package kof.game.platform.view {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import kof.game.common.CDisplayUtil;
import kof.game.platform.CPlatformFunctionData;
import kof.game.platform.CPlatformModuleHandler;
import kof.game.platform.data.CPlatformBaseData;
import kof.ui.imp_common.SignatureUI;

import morn.core.components.Box;
import morn.core.components.Label;

public class CPlatformSignatureRenderHandler extends CPlatformModuleHandler {
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    public function renderSignature(vipLevel:int, platformData:CPlatformBaseData, ui:SignatureUI, playerName:String) : void {
        if ( !ui ) return;
        var signaturBox:Box = ui.signature;

        if ( signaturBox.numChildren > 0 ) {
            _renderSignatureB(vipLevel, platformData, ui, playerName);
        } else {
            var functionData:CPlatformFunctionData = platformHandler.functionMap.getByType(platformData.platform);
            if (functionData.getSignatureViewClass) {
                var _onGetViewFinish:Function = function (displayObject:DisplayObject) : void {
                    signaturBox.addChild(displayObject);
                    _renderSignatureB(vipLevel, platformData, ui, playerName)
                };
                platformHandler.getSignatureViewHandler.getView(functionData.getSignatureViewClass, _onGetViewFinish);
            } else {
                // 不需要signature组件
                _renderSignatureB(vipLevel, platformData, ui, playerName);
            }
        }
    }

    private function _renderSignatureB(vipLevel:int, platformData:CPlatformBaseData, ui:SignatureUI, playerName:String) : void {

        var lblPlayerName:Label = ui.lblPlayerName;
        var signaturBox:Box = ui.signature;

        if (lblPlayerName && playerName && playerName.length > 0) {
            lblPlayerName.text = playerName;
        }

        var signatureView:DisplayObjectContainer;
        if (signaturBox.numChildren > 0) {
            signatureView = signaturBox.getChildAt(0) as DisplayObjectContainer;
            for (var i:int = 0; i < signatureView.numChildren; i++) {
                signatureView.getChildAt(i).visible = false;
            }
        }

        // 各个平台render
        var functionData:CPlatformFunctionData = platformHandler.functionMap.getByType(platformData.platform);
        var signatureRender:IPlatformSignatureRender = getBean(functionData.signatureRenderClass) as IPlatformSignatureRender;
        if (signatureRender) {
            signatureRender.renderSignature(signaturBox, platformData, vipLevel);

            // 自动布局平台标记
            if (signatureRender.autoSortItem && signatureView) {
                CDisplayUtil.autoSortChildrenX(signatureView);
            }
        }
        CDisplayUtil.autoSortChildrenX(ui); // 自动布局平台标记和名字
    }


}
}
