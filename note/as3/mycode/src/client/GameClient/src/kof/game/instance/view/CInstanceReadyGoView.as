//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/19.
 */
package kof.game.instance.view {

import kof.game.common.view.CRootView;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.ui.IUICanvas;
import kof.ui.master.level.ReadyGoUI;

import morn.core.handlers.Handler;

public class CInstanceReadyGoView extends CRootView {
    public function CInstanceReadyGoView() {
        super(ReadyGoUI, [], EInstanceWndResType.INSTANCE_READY_GO, false)
    }

    protected override function _onCreate() : void {
    }

    protected override function _onDispose() : void {
    }

    protected override function _onShow() : void {
        this.listEnterFrameEvent = true;

        _ui.clip_readyGo.gotoAndStop(0);
        _ui.clip_readyGo.playFromTo(null,null,new Handler(_onFlyComplete));

        this.setNoneData();
        this.invalidate();

    }

    protected override function _onHide() : void {

    }

    private function _onFlyComplete() : void {
        this.close();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();
        return true;
    }


    private function get _ui() : ReadyGoUI {
        return rootUI as ReadyGoUI;
    }
}
}
