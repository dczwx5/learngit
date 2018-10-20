//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/7.
 */
package kof.game.instance.view {

import flash.utils.setTimeout;

import kof.game.common.view.CRootView;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.ui.IUICanvas;
import kof.ui.master.level.TimeOverUI;

public class CInstanceTimeOverView extends CRootView {
    public function CInstanceTimeOverView() {
        super(TimeOverUI, [], null, false)
    }

    protected override function _onShow() : void {

        this.setNoneData();
        this.invalidate();
        setTimeout(close, 1000);
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();
        return true;
    }

    override public function setData( v : Object, forceInvalid:Boolean = true ) : void {
        super.setData( v, forceInvalid );
    }
}
}
