//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/24.
 */
package kof.game.common.view.loading {

import flash.utils.getTimer;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.ui.imp_common.CommonLoadingUI;

public class CLoadingView extends CRootView {

    public function CLoadingView() {
        super(CommonLoadingUI, null, null, false);
    }

    protected override function _onCreate() : void {
        this.setNoneData();
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        listEnterFrameEvent = true;

        _startTime = getTimer();
        _isShow = false;
        invalidate();
    }

    protected override function _onHide() : void {

    }
    private var _frame:int = 0;
    protected override function _onEnterFrame(delta:Number) : void {
        var str:String = CLang.Get("common_loading");
        for (var i:int = 0; i < _frame; i++) {
            str += ".";
        }

        _frame++;
        if (_frame > 3) _frame = 0;
        _ui.loading_txt.text = str;

        if (!_isShow) {
            var deltaTime:int = getTimer() - _startTime;
            if (deltaTime > 1000) {
                this.addToPopupDialog();
                _isShow = true;
            }
        }
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        return true;
    }

    // ====================================event=============================


    //===================================get/set======================================

    [Inline]
    private function get _ui() : CommonLoadingUI {
        return rootUI as CommonLoadingUI;
    }

    private var _startTime:int;
    private var _isShow:Boolean;
}
}
