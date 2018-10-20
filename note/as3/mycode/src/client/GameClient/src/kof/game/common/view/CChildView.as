//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.common.view {

public class CChildView extends CViewBase {

    // uisystem : set in viewbase, root : 根ui, childListClass : 子成类数组, 子系统需要的资源列表
    public function CChildView(childListClass:Array = null, swfRes:Array = null) {
        super(null, childListClass, swfRes, false);
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShowing():void {
        // can not call super._onShowing in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public virtual override function updateWindow() : Boolean {
        return super.updateWindow();
    }
}
}

