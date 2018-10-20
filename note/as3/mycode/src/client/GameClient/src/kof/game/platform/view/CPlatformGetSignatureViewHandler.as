//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform.view {

import flash.display.DisplayObject;

import kof.framework.CViewHandler;


public class CPlatformGetSignatureViewHandler extends CViewHandler {
    public function CPlatformGetSignatureViewHandler() {
    }

    public function getView(handlerClass:Class, callback:Function) : void {
        if (!handlerClass) {
            if (callback) {
                callback(null);
            }
        }
        var iGetView:IPlatformGetSignatureView = getBean(handlerClass) as IPlatformGetSignatureView;

        var loadFinish:Function = function () : void {
            var display:DisplayObject = iGetView.createView();
            if (callback) {
                callback(display);
            }
        };
        loadAssetsByView(iGetView.viewClass, loadFinish);
    }
}
}
