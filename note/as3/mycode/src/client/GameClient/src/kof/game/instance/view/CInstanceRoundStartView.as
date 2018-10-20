//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/6.
 */
package kof.game.instance.view {

import flash.utils.setTimeout;

import kof.game.common.view.CRootView;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.ui.IUICanvas;
import kof.ui.master.level.RoundUI;

public class CInstanceRoundStartView extends CRootView {
    public function CInstanceRoundStartView() {
        super(RoundUI, [], null, false)
    }

    protected override function _onShow() : void {

        this.setNoneData();
        this.invalidate();
        setTimeout(close, 2000);
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();
        return true;
    }

    private function get _ui() : RoundUI {
        return rootUI as RoundUI;
    }

    override public function setData( v : Object , forceInvalid:Boolean = true) : void {
        super.setData( v, forceInvalid );
        if( v.roundNum == 4){
            _ui.round_box.visible = false;
            _ui.img_zuizhonghui.visible = true;
        }else{
            _ui.round_box.visible = true;
            _ui.img_zuizhonghui.visible = false;
        }
        _ui.clip_round.index = int( v.roundNum );
    }
}
}
