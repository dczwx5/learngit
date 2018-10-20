//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.common.view {

// 继承rootView类原型
// public class CPlayerView extends CRootView {
//      public function CPlayerView(uiSystem:IUICanvas);
// }
//
public class CRootView extends CViewBase {
    // rootClass : mornUI class,
    public function CRootView(rootClass:*, childListClass:Array, swfRes:Array, closeByHide:Boolean = true) {
        super(rootClass, childListClass, swfRes, true, closeByHide);
        rootView = this;

    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class, noData
    }
    protected override function _onShowing():void {
        // can not call super._onShowing in this class, hasData
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public override function updateWindow() : Boolean {
        return super.updateWindow();
    }
}
}

