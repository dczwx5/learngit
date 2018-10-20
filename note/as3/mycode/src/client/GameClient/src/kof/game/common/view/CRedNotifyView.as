//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/4.
 */
package kof.game.common.view {

import kof.game.common.view.CRedNotifyView;

import morn.core.components.Component;
import morn.core.components.Image;

// 小红点, 动态添加
public class CRedNotifyView extends Image {
    public function CRedNotifyView() {
        skin = "png.common.img.dian";
        name = "redNofity";
    }
    public static function isViewHasNotify(view:Component) : Boolean {
        var nofity:CRedNotifyView = view.getChildByName("redNofity") as CRedNotifyView;
        if (nofity) {
            return true;
        }
        return false;
    }
    public static function removeViewNotify(view:Component) : void {
        if (isViewHasNotify(view)) {
            view.removeChildByName("redNofity");
        }
    }
    public static function hideViewNotify(view:Component) : void {
        var nofity:CRedNotifyView = view.getChildByName("redNofity") as CRedNotifyView;
        if (nofity) {
            nofity.visible = false;
        }
    }
    public static function showAndCreateViewNotify(view:Component) : CRedNotifyView {
        var nofity:CRedNotifyView = view.getChildByName("redNofity") as CRedNotifyView;
        if (!nofity) {
            view.addChild(nofity = new CRedNotifyView());
        }
        nofity.visible = true;
        return nofity;
    }

}
}
